import 'dart:io';

import '../../ml/coffee_detector.dart';
import '../../models/detection_result_model.dart';
import '../../models/recommendation_model.dart';
import '../services/hive_service.dart';
import '../services/supabase_service.dart';

class DetectionService {
  final CoffeeDetector _detector = CoffeeDetector();
  final SupabaseService _supabaseService = SupabaseService();

  bool _initialized = false;

  /// Initialize model
  Future<void> init() async {
    if (_initialized) return;

    await _detector.loadModels();
    _initialized = true;

    print("☕ CoffeeGuard Initialized");
  }

  /// Run detection pipeline
  Future<Map<String, dynamic>> runDetection(File image) async {
    try {
      print("🧠 Running model...");

      final result = await _detector.detect(image);

      /// ❌ Stage 1 failed
      if (result["success"] == false) {
        print("❌ Not a coffee leaf");

        return {
          "success": false,
          "message": result["message"]
        };
      }

      /// ✅ Normalize disease text
      final diseaseRaw = result["disease"];
      final disease = diseaseRaw.toString().trim();

      final confidence =
          double.parse(result["confidence"].toString()) / 100;

      print("✅ Coffee leaf detected");
      print("🦠 Disease: $disease ($confidence)");

      /// =====================================================
      /// 🧠 OFFLINE-FIRST RECOMMENDATION LOGIC
      /// =====================================================

      String recommendationText = "No recommendation available";

      /// ⚠️ TEMP: default severity
      String severity = "medium";

      try {
        /// 1️⃣ Try LOCAL (Hive) FIRST
        final RecommendationModel? localRec =
            HiveService.getRecommendation(disease, severity);

        if (localRec != null) {
          print("📦 Using LOCAL recommendation");

          recommendationText = localRec.content;
        } else {
          print("🌐 No local recommendation, fetching ONLINE...");

          /// 2️⃣ FALLBACK → SUPABASE
          final rec =
              await _supabaseService.getRecommendationByDisease(disease);

          if (rec != null && rec["content"] != null) {
            recommendationText = rec["content"];
          }
        }
      } catch (e) {
        print("⚠️ Recommendation error: $e");
      }

      /// =====================================================
      /// 💾 SAVE IMAGE LOCALLY
      /// =====================================================
      final savedPath = await HiveService.saveImageToLocal(image);

      /// =====================================================
      /// 📦 CREATE DETECTION OBJECT
      /// =====================================================
      final detection = DetectionResultModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imageLocalPath: savedPath,
        isCoffeeLeaf: true,
        leafConfidence: 1.0,
        diseaseLabel: disease,
        diseaseConfidence: confidence,
        recommendation: recommendationText,
        createdAt: DateTime.now(),
        isSynced: false,
      );

      /// =====================================================
      /// 💾 SAVE TO HIVE + AUTO SYNC
      /// =====================================================
      print("💾 Saving detection...");
      await HiveService.saveDetection(detection);

      return {
        "success": true,
        "disease": disease,
        "diseaseConfidence": confidence,
        "recommendation": recommendationText,
      };

    } catch (e) {
      print("🔥 Detection Error: $e");

      return {
        "success": false,
        "message": "Detection failed"
      };
    }
  }
}