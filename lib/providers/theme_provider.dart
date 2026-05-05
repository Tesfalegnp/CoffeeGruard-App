import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {
  light,
  dark,
  system,
}

class ThemeProvider extends ChangeNotifier {
  static const String _key = "app_theme";

  AppThemeMode _themeMode = AppThemeMode.system;

  AppThemeMode get currentTheme => _themeMode;

  ThemeMode get themeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key) ?? "system";

    switch (saved) {
      case "light":
        _themeMode = AppThemeMode.light;
        break;
      case "dark":
        _themeMode = AppThemeMode.dark;
        break;
      default:
        _themeMode = AppThemeMode.system;
    }

    notifyListeners();
  }

  Future<void> setTheme(AppThemeMode mode) async {
    _themeMode = mode;

    final prefs = await SharedPreferences.getInstance();

    switch (mode) {
      case AppThemeMode.light:
        await prefs.setString(_key, "light");
        break;
      case AppThemeMode.dark:
        await prefs.setString(_key, "dark");
        break;
      default:
        await prefs.setString(_key, "system");
    }

    notifyListeners();
  }
}