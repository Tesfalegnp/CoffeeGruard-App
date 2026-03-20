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
  }

  /// =========================
  /// 📸 IMAGE STORAGE FIX (VERY IMPORTANT)
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

  /// ✅ SAVE + AUTO SYNC
  static Future<void> saveDetection(DetectionResultModel detection) async {

    try {

      print("🔥 saveDetection CALLED");

      final box = getDetectionBox();

      await box.add(detection);

      print("✅ Saved locally");

      /// 🚀 AUTO SYNC (non-blocking)
      Future.microtask(() async {
        print("🚀 Starting sync...");
        await SyncService().syncDetections();
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
  /// RECOMMENDATION METHODS
  /// =========================

  static Box<RecommendationModel> getRecommendationBox() {
    return Hive.box<RecommendationModel>(recommendationBox);
  }

  /// 📥 Save all recommendations (overwrite old)
  static Future<void> saveRecommendations(
      List<RecommendationModel> list) async {

    try {

      final box = getRecommendationBox();

      await box.clear();

      for (var item in list) {
        await box.put(item.id, item);
      }

      print("✅ Recommendations saved locally");

    } catch (e) {
      print("❌ saveRecommendations error: $e");
    }
  }

  /// 📤 Get all recommendations
  static List<RecommendationModel> getAllRecommendations() {
    return getRecommendationBox().values.toList();
  }

  /// 🔍 Find recommendation by disease + severity
  static RecommendationModel? getRecommendation(
      String disease, String severity) {

    final box = getRecommendationBox();

    try {

      return box.values.firstWhere(
        (e) =>
            e.diseaseLabel.toLowerCase().trim() ==
                disease.toLowerCase().trim() &&
            e.severity.toLowerCase().trim() ==
                severity.toLowerCase().trim(),
      );

    } catch (e) {
      print("⚠️ No local recommendation found");
      return null;
    }
  }
}