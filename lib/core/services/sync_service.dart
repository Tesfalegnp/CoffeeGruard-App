import 'dart:io';
import '../../models/detection_result_model.dart';
import 'supabase_service.dart';
import 'recommendation_service.dart';
import 'hive_service.dart';

class SyncService {
  final SupabaseService supabaseService = SupabaseService();
  final RecommendationService recommendationService = RecommendationService();

  /// =====================================================
  /// 🚀 FULL SYNC (LOCAL + CLOUD)
  /// =====================================================
  Future<void> fullSync() async {
    print("🔄 FULL SYNC STARTED");

    await syncDetections();      // push local unsynced detections
    await syncRecommendations(); // push/fetch recommendations
    await pullExpertUpdates();   // pull expert review updates

    print("✅ FULL SYNC COMPLETED");
  }

  /// =====================================================
  /// 📡 SYNC DETECTIONS (LOCAL → CLOUD)
  /// =====================================================
  Future<void> syncDetections() async {
    final unsynced = HiveService.getUnsyncedDetections();
    if (unsynced.isEmpty) return;

    for (var detection in unsynced) {
      try {
        final file = File(detection.imageLocalPath ?? "");
        if (!file.existsSync()) continue;

        final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
        final imageUrl = await supabaseService.uploadImage(file, fileName);
        if (imageUrl == null) continue;

        final record = {
          "user_id": null,
          "image_url": imageUrl,
          "image_local_path": detection.imageLocalPath,
          "is_coffee_leaf": detection.isCoffeeLeaf,
          "leaf_confidence": detection.leafConfidence,
          "disease_label": detection.diseaseLabel,
          "disease_confidence": detection.diseaseConfidence,
          "recommendation_text": detection.recommendation,
          "location_lat": detection.latitude,
          "location_lng": detection.longitude,
          "is_reviewed": detection.isReviewed,
          "expert_note": detection.expertNote,
          "severity": detection.severityLevel,
          "created_at": detection.createdAt.toIso8601String()
        };

        final success = await supabaseService.insertDetection(record);
        if (success) {
          detection.isSynced = true;
          await detection.save();
        }
      } catch (e) {
        print("🔥 Sync error: $e");
      }
    }
  }

  /// =====================================================
  /// 📥 PULL EXPERT UPDATES (CLOUD → LOCAL)
  /// =====================================================
  Future<void> pullExpertUpdates() async {
    try {
      print("📥 Pulling expert updates...");
      final cloudData = await supabaseService.fetchDetections();
      final localList = HiveService.getAllDetections();

      for (var cloud in cloudData) {
        final local = localList.firstWhere(
          (e) => e.id == cloud["id"],
          orElse: () => DetectionResultModel(
            id: cloud["id"] ?? "",
            isCoffeeLeaf: cloud["is_coffee_leaf"] ?? false,
            createdAt: DateTime.tryParse(cloud["created_at"] ?? "") ?? DateTime.now(),
          ),
        );

        // Update expert fields only
        local.isReviewed = cloud["is_reviewed"] ?? false;
        local.expertNote = cloud["expert_note"];
        local.severityLevel = cloud["severity"];

        await local.save();
      }
      print("✅ Expert updates synced");
    } catch (e) {
      print("❌ Pull error: $e");
    }
  }

  /// =====================================================
  /// 🌐 PULL DETECTIONS FOR EXPERT DASHBOARD (CLOUD ONLY)
  /// =====================================================
  Future<List<DetectionResultModel>> pullExpertDetections() async {
    final cloudData = await supabaseService.fetchDetections();

    final List<DetectionResultModel> detections = cloudData.map((d) {
      return DetectionResultModel(
        id: d["id"] ?? "",
        isCoffeeLeaf: d["is_coffee_leaf"] ?? false, // required
        imageUrl: d["image_url"],
        diseaseLabel: d["disease_label"],
        severityLevel: d["severity"],
        isReviewed: d["is_reviewed"] ?? false,
        expertNote: d["expert_note"],
        createdAt: DateTime.tryParse(d["created_at"] ?? "") ?? DateTime.now(),
        leafConfidence: d["leaf_confidence"]?.toDouble(),
        diseaseConfidence: d["disease_confidence"]?.toDouble(),
        latitude: d["location_lat"]?.toDouble(),
        longitude: d["location_lng"]?.toDouble(),
        recommendation: d["recommendation_text"],
      );
    }).toList();

    return detections;
  }

  /// =====================================================
  /// 💡 SYNC RECOMMENDATIONS
  /// =====================================================
  Future<void> syncRecommendations() async {
    try {
      await recommendationService.syncRecommendations();
    } catch (e) {
      print("❌ Recommendation sync error: $e");
    }
  }

  /// =====================================================
  /// 📥 GET LOCAL DETECTIONS HELPER
  /// =====================================================
  Future<List<DetectionResultModel>> getLocalDetections() async {
    return HiveService.getAllDetections();
  }

  /// =====================================================
  /// 🌐 UPDATE EXPERT REVIEW (CLOUD ONLY)
  /// =====================================================
  Future<bool> updateExpertReview(String detectionId, Map<String, dynamic> data) async {
    return await supabaseService.updateDetectionReview(detectionId, data);
  }
}