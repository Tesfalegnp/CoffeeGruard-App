import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  english,
  amharic,
  oromo,
}

class LanguageProvider extends ChangeNotifier {
  static const String _key = "app_language";

  AppLanguage _currentLanguage = AppLanguage.english;

  AppLanguage get currentLanguage => _currentLanguage;

  /// 🌍 FIX: used by MaterialApp.locale
  Locale get locale {
    switch (_currentLanguage) {
      case AppLanguage.amharic:
        return const Locale('am', 'ET');
      case AppLanguage.oromo:
        return const Locale('om', 'ET');
      default:
        return const Locale('en', 'US');
    }
  }

  /// 🔑 used for Supabase + TTS + DB
  String get code {
    switch (_currentLanguage) {
      case AppLanguage.amharic:
        return "am";
      case AppLanguage.oromo:
        return "om";
      default:
        return "en";
    }
  }

  String get displayName {
    switch (_currentLanguage) {
      case AppLanguage.amharic:
        return "አማርኛ";
      case AppLanguage.oromo:
        return "Afaan Oromoo";
      default:
        return "English";
    }
  }

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key) ?? "en";

    _currentLanguage = _fromCode(saved);
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage language) async {
    _currentLanguage = language;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);

    notifyListeners(); // 🔥 CRITICAL FIX
  }

  AppLanguage _fromCode(String code) {
    switch (code) {
      case "am":
        return AppLanguage.amharic;
      case "om":
        return AppLanguage.oromo;
      default:
        return AppLanguage.english;
    }
  }
}