import 'dart:io';

import '../../ml/coffee_detector.dart';
import '../../models/detection_result_model.dart';
import '../services/hive_service.dart';

class DetectionService {

  final CoffeeDetector _detector = CoffeeDetector();

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

      final disease = result["disease"];

      final confidence =
          double.parse(result["confidence"].toString()) / 100;

      print("✅ Coffee leaf detected");
      print("🦠 Disease: $disease ($confidence)");

      /// ✅ FIX: ADD REQUIRED ID
      final detection = DetectionResultModel(

        id: DateTime.now().millisecondsSinceEpoch.toString(),

        imageLocalPath: image.path,

        isCoffeeLeaf: true,

        leafConfidence: 1.0,

        diseaseLabel: disease,

        diseaseConfidence: confidence,

        recommendation: "Auto-generated",

        createdAt: DateTime.now(),

        isSynced: false,
      );

      /// SAVE + SYNC
      print("💾 Saving detection...");
      await HiveService.saveDetection(detection);

      return {
        "success": true,
        "disease": disease,
        "diseaseConfidence": confidence,
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