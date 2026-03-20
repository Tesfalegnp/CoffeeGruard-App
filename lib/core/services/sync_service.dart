import 'dart:io';

import 'hive_service.dart';
import 'supabase_service.dart';
import 'recommendation_service.dart'; // ✅ NEW
import '../../models/detection_result_model.dart';

class SyncService {

  final SupabaseService supabaseService = SupabaseService();
  final RecommendationService recommendationService = RecommendationService(); // ✅ NEW

  /// =====================================================
  /// 🚀 FULL SYNC (NEW)
  /// =====================================================
  Future<void> fullSync() async {

    print("🔄 FULL SYNC STARTED");

    await syncDetections();        // existing
    await syncRecommendations();   // new

    print("✅ FULL SYNC COMPLETED");
  }

  /// =====================================================
  /// 📡 SYNC DETECTIONS (UNCHANGED)
  /// =====================================================
  Future<void> syncDetections() async {

    print("🔥 SYNC FUNCTION STARTED");

    final unsynced = HiveService.getUnsyncedDetections();

    print("📦 Unsynced count: ${unsynced.length}");

    if (unsynced.isEmpty) {
      print("No unsynced detections");
      return;
    }

    print("Syncing ${unsynced.length} detections...");

    for (var detection in unsynced) {

      try {

        final imagePath = detection.imageLocalPath;

        if (imagePath == null || imagePath.isEmpty) {
          print("❌ Image path missing");
          continue;
        }

        final file = File(imagePath);

        if (!file.existsSync()) {
          print("❌ File not found: $imagePath");
          continue;
        }

        print("Uploading image...");

        final fileName =
            "${DateTime.now().millisecondsSinceEpoch}.jpg";

        final imageUrl =
            await supabaseService.uploadImage(file, fileName);

        if (imageUrl == null) {
          print("❌ Upload failed");
          continue;
        }

        print("Image uploaded: $imageUrl");

        print("Inserting detection record...");

        final record = {

          "user_id": null,
          "image_url": imageUrl,
          "image_local_path": detection.imageLocalPath,
          "is_coffee_leaf": detection.isCoffeeLeaf,
          "leaf_confidence": detection.leafConfidence,
          "disease_label": detection.diseaseLabel,
          "disease_confidence": detection.diseaseConfidence,
          "recommendation_text": detection.recommendation,
          "created_at":
              detection.createdAt?.toIso8601String() ??
              DateTime.now().toIso8601String()

        };

        final success =
            await supabaseService.insertDetection(record);

        if (success) {

          detection.isSynced = true;
          await detection.save();

          print("✅ Detection synced");

        } else {

          print("❌ Insert failed");

        }

      } catch (e) {
        print("🔥 Sync error: $e");
      }
    }
  }

  /// =====================================================
  /// 💡 SYNC RECOMMENDATIONS (NEW 🔥)
  /// =====================================================
  Future<void> syncRecommendations() async {

    try {
      print("📥 Syncing recommendations...");

      await recommendationService.syncRecommendations();

      print("✅ Recommendations updated");

    } catch (e) {
      print("❌ Recommendation sync error: $e");
    }
  }
}