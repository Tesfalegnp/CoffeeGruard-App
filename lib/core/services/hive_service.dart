import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/detection_result_model.dart';
import '../../models/user_model.dart';
import '../../models/recommendation_model.dart';
import 'sync_service.dart';

class HiveService {
  static const String detectionBox = "detections";
  static const String userBox = "users";
  static const String recommendationBox = "recommendations";

  /// 🔐 NEW SESSION BOX
  static const String sessionBox = "session";
  static const String sessionKey = "current_user";

  /// =========================
  /// INIT
  /// =========================
  static Future<void> init() async {
    await Hive.initFlutter();

    /// ✅ Register Adapters (SAFE)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(DetectionResultModelAdapter());
    }

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserModelAdapter());
    }

    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(RecommendationModelAdapter());
    }

    /// ✅ Open Boxes
    await Hive.openBox<DetectionResultModel>(detectionBox);
    await Hive.openBox<UserModel>(userBox);
    await Hive.openBox<RecommendationModel>(recommendationBox);

    /// ✅ OPEN SESSION BOX (NEW 🔥)
    await Hive.openBox(sessionBox);
  }

  /// =========================
  /// 📸 IMAGE STORAGE
  /// =========================
  static Future<String> saveImageToLocal(File image) async {
    final dir = await getApplicationDocumentsDirectory();

    final newPath =
        "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

    final newImage = await image.copy(newPath);

    print("📁 Image saved to: $newPath");

    return newImage.path;
  }

  /// =========================
  /// DETECTION METHODS
  /// =========================

  static Box<DetectionResultModel> getDetectionBox() {
    return Hive.box<DetectionResultModel>(detectionBox);
  }

  /// ✅ SAVE + AUTO FULL SYNC (UNCHANGED)
  static Future<void> saveDetection(DetectionResultModel detection) async {
    try {
      print("🔥 saveDetection CALLED");

      final box = getDetectionBox();
      await box.add(detection);

      print("✅ Saved locally");

      /// 🚀 AUTO FULL SYNC
      Future.microtask(() async {
        print("🚀 Starting FULL sync...");
        await SyncService().fullSync();
      });
    } catch (e) {
      print("❌ saveDetection error: $e");
    }
  }

  static List<DetectionResultModel> getAllDetections() {
    return getDetectionBox().values.toList();
  }

  static List<DetectionResultModel> getUnsyncedDetections() {
    return getDetectionBox().values
        .where((d) => d.isSynced != true)
        .toList();
  }

  /// =========================
  /// 💡 RECOMMENDATION METHODS
  /// =========================

  static Box<RecommendationModel> getRecommendationBox() {
    return Hive.box<RecommendationModel>(recommendationBox);
  }

  /// 📥 Save all recommendations
  static Future<void> saveRecommendations(
      List<RecommendationModel> list) async {
    try {
      final box = getRecommendationBox();

      await box.clear();

      for (var item in list) {
        await box.put(item.id, item);
      }

      print("✅ Recommendations saved locally: ${list.length}");
    } catch (e) {
      print("❌ saveRecommendations error: $e");
    }
  }

  /// 📤 Get all recommendations
  static List<RecommendationModel> getAllRecommendations() {
    return getRecommendationBox().values.toList();
  }

  /// 🔍 SMART MATCH
  static RecommendationModel? getRecommendation(
      String disease, String severity) {
    final box = getRecommendationBox();

    try {
      final normalizedDisease =
          disease.toLowerCase().replaceAll(" ", "").trim();

      final normalizedSeverity = severity.toLowerCase().trim();

      /// 1️⃣ EXACT match
      try {
        return box.values.firstWhere(
          (e) =>
              e.diseaseLabel.toLowerCase().replaceAll(" ", "") ==
                  normalizedDisease &&
              e.severity.toLowerCase() == normalizedSeverity,
        );
      } catch (_) {}

      /// 2️⃣ CONTAINS match
      try {
        return box.values.firstWhere(
          (e) =>
              normalizedDisease.contains(
                  e.diseaseLabel.toLowerCase().replaceAll(" ", "")) ||
              e.diseaseLabel
                  .toLowerCase()
                  .replaceAll(" ", "")
                  .contains(normalizedDisease),
        );
      } catch (_) {}

      /// 3️⃣ FALLBACK
      try {
        return box.values.firstWhere(
          (e) =>
              normalizedDisease.contains(
                  e.diseaseLabel.toLowerCase().replaceAll(" ", "")),
        );
      } catch (_) {}

      print("⚠️ No local recommendation found");
      return null;
    } catch (e) {
      print("❌ getRecommendation error: $e");
      return null;
    }
  }

  /// =========================
  /// 🔐 SESSION METHODS (NEW 🔥)
  /// =========================

  /// 💾 Save logged-in user
  static Future<void> saveUserSession(UserModel user) async {
    try {
      final box = Hive.box(sessionBox);
      await box.put(sessionKey, user);
      print("✅ User session saved");
    } catch (e) {
      print("❌ saveUserSession error: $e");
    }
  }

  /// 📥 Get current user
  static UserModel? getCurrentUser() {
    try {
      final box = Hive.box(sessionBox);
      return box.get(sessionKey);
    } catch (e) {
      print("❌ getCurrentUser error: $e");
      return null;
    }
  }

  /// 🚪 Logout (clear session)
  static Future<void> clearUserSession() async {
    try {
      final box = Hive.box(sessionBox);
      await box.delete(sessionKey);
      print("✅ User logged out");
    } catch (e) {
      print("❌ clearUserSession error: $e");
    }
  }
}