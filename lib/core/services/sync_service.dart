import 'dart:io';

import '../../models/detection_result_model.dart';
import 'supabase_service.dart';
import 'recommendation_service.dart';
import 'hive_service.dart';

class SyncService {
  final SupabaseService supabaseService = SupabaseService();
  final RecommendationService recommendationService = RecommendationService();

  /// =====================================================
  /// 🚀 FULL SYNC
  /// =====================================================
  Future<void> fullSync() async {
    await syncDetections();
    await syncRecommendations();
    await pullExpertUpdates();
  }

  /// =====================================================
  /// 📡 SYNC DETECTIONS (LOCAL → CLOUD)
  /// =====================================================
  Future<void> syncDetections() async {
    final unsynced = HiveService.getUnsyncedDetections();

    for (var detection in unsynced) {
      try {
        final file = File(detection.imageLocalPath ?? "");
        if (!file.existsSync()) continue;

        final fileName =
            "${DateTime.now().millisecondsSinceEpoch}.jpg";

        final imageUrl =
            await supabaseService.uploadImage(file, fileName);

        if (imageUrl == null) continue;

        final record = {
          "image_url": imageUrl,
          "image_local_path": detection.imageLocalPath,
          "is_coffee_leaf": detection.isCoffeeLeaf,
          "leaf_confidence": detection.leafConfidence,
          "disease_label": detection.diseaseLabel,
          "disease_confidence": detection.diseaseConfidence,
          "location_lat": detection.latitude,
          "location_lng": detection.longitude,
          "is_reviewed": detection.isReviewed ?? false,
          "expert_note": detection.expertNote,
          "severity": detection.severityLevel,
          "created_at": detection.createdAt.toIso8601String(),
        };

        final success =
            await supabaseService.insertDetection(record);

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
  /// 📥 PULL EXPERT UPDATES
  /// =====================================================
  Future<void> pullExpertUpdates() async {
    final cloudData = await supabaseService.fetchDetections();
    final localList = HiveService.getAllDetections();

    for (var cloud in cloudData) {
      final local = localList.firstWhere(
        (e) => e.id == cloud["id"],
        orElse: () => DetectionResultModel(
          id: cloud["id"] ?? "",
          isCoffeeLeaf: cloud["is_coffee_leaf"] ?? false,
          createdAt: DateTime.now(),
        ),
      );

      local.isReviewed = cloud["is_reviewed"] ?? false;
      local.expertNote = cloud["expert_note"];
      local.severityLevel =
          cloud["severity"] ?? cloud["severity_level"];

      await local.save();
    }
  }

  /// =====================================================
  /// 🌐 EXPERT QUEUE (FIXED MODEL MAPPING)
  /// =====================================================
  Future<List<DetectionResultModel>> pullExpertDetections() async {
    final cloudData =
        await supabaseService.fetchPendingDetections();

    return cloudData.map((d) {
      return DetectionResultModel(
        id: d["id"] ?? "",
        isCoffeeLeaf: d["is_coffee_leaf"] ?? false,
        imageUrl: d["image_url"],
        imageLocalPath: d["image_local_path"],
        leafConfidence:
            (d["leaf_confidence"] as num?)?.toDouble(),
        diseaseLabel: d["disease_label"],
        diseaseConfidence:
            (d["disease_confidence"] as num?)?.toDouble(),
        latitude: (d["location_lat"] as num?)?.toDouble(),
        longitude: (d["location_lng"] as num?)?.toDouble(),
        isReviewed: d["is_reviewed"] ?? false,
        expertNote: d["expert_note"],
        severityLevel:
            d["severity"] ?? d["severity_level"],
        createdAt:
            DateTime.tryParse(d["created_at"] ?? "") ??
                DateTime.now(),
      );
    }).toList();
  }

  /// =====================================================
  /// 💡 SYNC RECOMMENDATIONS
  /// =====================================================
  Future<void> syncRecommendations() async {
    await recommendationService.syncRecommendations();
  }

  /// =====================================================
  /// ✅ FIXED EXPERT REVIEW UPDATE (🔥 MAIN FIX)
  /// =====================================================
  Future<bool> updateExpertReview(
    String detectionId,
    Map<String, dynamic> data,
  ) async {
    try {
      print("📡 Updating detection: $detectionId");
      print("📦 Raw data: $data");

      final safeData = Map<String, dynamic>.from(data);

      /// ===============================
      /// FIELD NORMALIZATION FIX
      /// ===============================

      // Convert severity_level → severity (DB column fix)
      if (safeData.containsKey("severity_level")) {
        safeData["severity"] = safeData["severity_level"];
        safeData.remove("severity_level");
      }

      // ensure severity exists correctly
      if (safeData.containsKey("severity")) {
        safeData["severity"] = safeData["severity"];
      }

      /// ===============================
      /// BOOLEAN FIX
      /// ===============================
      if (safeData.containsKey("is_reviewed")) {
        safeData["is_reviewed"] =
            safeData["is_reviewed"] == true;
      }

      /// ===============================
      /// ALWAYS UPDATE TIMESTAMP
      /// ===============================
      safeData["updated_at"] = DateTime.now().toIso8601String();

      /// ===============================
      /// SUPABASE UPDATE (CRITICAL FIX)
      /// ===============================
      final response = await supabaseService.client
          .from('detections')
          .update(safeData)
          .eq('id', detectionId)
          .select();

      print("📦 Supabase response: $response");

      /// ===============================
      /// REAL SUCCESS CHECK
      /// ===============================
      if (response.isEmpty) {
        print("❌ UPDATE FAILED: No row returned (RLS or wrong ID)");
        return false;
      }

      print("✅ UPDATE SUCCESSFUL");
      return true;
    } catch (e) {
      print("❌ Update expert review error: $e");
      return false;
    }
  }

  /// =====================================================
  /// ❌ DELETE DETECTION
  /// =====================================================
  Future<bool> deleteDetection(String id) async {
    try {
      await supabaseService.deleteDetection(id);
      return true;
    } catch (e) {
      print("❌ Delete error: $e");
      return false;
    }
  }

  /// =====================================================
  /// 🔄 REFRESH QUEUE
  /// =====================================================
  Future<List<DetectionResultModel>> refreshExpertQueue() async {
    return await pullExpertDetections();
  }
      // =====================================================
// 👤 SYNC USER PROFILE (ADD ONLY 🔥)
// =====================================================
Future<void> syncUserProfile() async {
  try {
    final user = HiveService.getCurrentUser();
    if (user == null) return;

    final success = await supabaseService.updateUserProfile(
      user.id,
      {
        "full_name": user.fullName,
        "phone": user.phone,
        "avatar_url": user.avatarUrl,
      },
    );

    if (success) {
      print("✅ Profile synced to server");
    } else {
      print("⚠️ Sync failed, will retry later");
    }
  } catch (e) {
    print("❌ Profile sync error: $e");
   }
}
}