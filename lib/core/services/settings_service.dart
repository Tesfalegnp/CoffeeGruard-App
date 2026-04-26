import 'package:hive/hive.dart';
import '../../models/system_settings_model.dart';

class SettingsService {
  static const String boxName = "system_settings";

  Future<SystemSettingsModel> loadSettings() async {
    final box = await Hive.openBox(boxName);

    final data = box.get("settings");

    if (data == null) {
      final defaultSettings = SystemSettingsModel();
      await box.put("settings", defaultSettings.toMap());
      return defaultSettings;
    }

    return SystemSettingsModel.fromMap(Map.from(data));
  }

  Future<void> saveSettings(SystemSettingsModel settings) async {
    final box = await Hive.openBox(boxName);
    await box.put("settings", settings.toMap());
  }

  Future<void> resetSettings() async {
    final box = await Hive.openBox(boxName);
    await box.clear();
  }
}