import 'dart:io';

import '../../ml/coffee_detector.dart';
import '../../models/detection_result_model.dart';
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

      /// ✅ Normalize disease text (IMPORTANT)
      final diseaseRaw = result["disease"];
      final disease = diseaseRaw.toString().trim();

      final confidence =
          double.parse(result["confidence"].toString()) / 100;

      print("✅ Coffee leaf detected");
      print("🦠 Disease: $disease ($confidence)");

      /// ✅ FETCH RECOMMENDATION FROM SUPABASE
      String recommendationText = "No recommendation available";

      try {
        final rec =
            await _supabaseService.getRecommendationByDisease(disease);

        if (rec != null && rec["content"] != null) {
          recommendationText = rec["content"];
        }
      } catch (e) {
        print("⚠️ Recommendation fetch failed: $e");
      }

      /// ✅ FIX: SAVE IMAGE TO PERMANENT STORAGE
      final savedPath = await HiveService.saveImageToLocal(image);

      /// ✅ CREATE LOCAL OBJECT
      final detection = DetectionResultModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imageLocalPath: savedPath, // ✅ FIXED
        isCoffeeLeaf: true,
        leafConfidence: 1.0,
        diseaseLabel: disease,
        diseaseConfidence: confidence,
        recommendation: recommendationText,
        createdAt: DateTime.now(),
        isSynced: false,
      );

      /// 💾 SAVE LOCAL
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