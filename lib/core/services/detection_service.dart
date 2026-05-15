import 'dart:io';

import '../../ml/coffee_detector.dart';
import '../../models/detection_result_model.dart';
import '../services/hive_service.dart';
import '../services/supabase_service.dart';

import 'cloud/cloud_detection_service.dart';
import 'cloud/network_service.dart';

class DetectionService {
  final CoffeeDetector _detector = CoffeeDetector();
  final CloudDetectionService _cloud =
      CloudDetectionService();

  final SupabaseService _supabaseService =
      SupabaseService();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    await _detector.loadModels();

    _initialized = true;
  }

  Future<Map<String, dynamic>> runDetection(
      File image) async {
    try {
      Map<String, dynamic> result;

      final online =
          await NetworkService.isOnline();

      /// ===============================
      /// CLOUD FIRST
      /// ===============================
      if (online) {
        print("☁️ Using Cloud AI...");
        result = await _cloud.detect(image);

        if (result["success"] == false) {
          print("⚠️ Cloud failed → Local AI");
          result =
              await _detector.detect(image);
        }
      }

      /// ===============================
      /// OFFLINE
      /// ===============================
      else {
        print("📱 Offline Local AI...");
        result =
            await _detector.detect(image);
      }

      if (result["success"] == false) {
        return result;
      }

      final disease =
          result["disease"].toString();

      final confidence =
          double.parse(
            result["confidence"].toString(),
          ) /
              100;

      String recommendation =
          "No recommendation";

      try {
        final rec =
            await _supabaseService
                .getRecommendationByDisease(
                    disease);

        if (rec != null) {
          recommendation =
              rec["content"] ??
                  "No recommendation";
        }
      } catch (_) {}

      final savedPath =
          await HiveService.saveImageToLocal(
              image);

      final detection =
          DetectionResultModel(
        id: DateTime.now()
            .millisecondsSinceEpoch
            .toString(),
        imageLocalPath: savedPath,
        isCoffeeLeaf: true,
        leafConfidence: 1.0,
        diseaseLabel: disease,
        diseaseConfidence: confidence,
        recommendation: recommendation,
        createdAt: DateTime.now(),
        isSynced: false,
      );

      await HiveService.saveDetection(
          detection);

      return {
        "success": true,
        "disease": disease,
        "diseaseConfidence": confidence,
        "recommendation": recommendation,
      };
    } catch (e) {
      return {
        "success": false,
        "message": "Detection failed $e"
      };
    }
  }
}