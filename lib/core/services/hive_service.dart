import 'package:hive_flutter/hive_flutter.dart';

import '../../models/detection_result_model.dart';
import '../../models/user_model.dart';
import 'sync_service.dart';

class HiveService {

  static const String detectionBox = "detections";
  static const String userBox = "users";

  static Future<void> init() async {

    await Hive.initFlutter();

    /// Register Adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(DetectionResultModelAdapter());
    }

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserModelAdapter());
    }

    /// Open Boxes
    await Hive.openBox<DetectionResultModel>(detectionBox);
    await Hive.openBox<UserModel>(userBox);
  }

  static Box<DetectionResultModel> getDetectionBox() {
    return Hive.box<DetectionResultModel>(detectionBox);
  }

  /// ✅ SAVE + AUTO SYNC
  static Future<void> saveDetection(DetectionResultModel detection) async {

    print("🔥 saveDetection CALLED");

    final box = getDetectionBox();

    await box.add(detection);

    print("✅ Saved locally");

    /// 🚀 AUTO SYNC
    print("🚀 Starting sync...");
    await SyncService().syncDetections();
  }

  static List<DetectionResultModel> getAllDetections() {
    return getDetectionBox().values.toList();
  }

  static List<DetectionResultModel> getUnsyncedDetections() {
    return getDetectionBox().values
        .where((d) => d.isSynced != true)
        .toList();
  }
}