import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { english, amharic, oromo }

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'app_language';
  AppLanguage _currentLanguage = AppLanguage.english;
  
  AppLanguage get currentLanguage => _currentLanguage;
  
  String get languageCode {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'en';
      case AppLanguage.amharic:
        return 'am';
      case AppLanguage.oromo:
        return 'om';
    }
  }
  
  bool get isAmharic => _currentLanguage == AppLanguage.amharic;
  bool get isOromo => _currentLanguage == AppLanguage.oromo;
  bool get isEnglish => _currentLanguage == AppLanguage.english;
  
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString(_languageKey);
    if (savedLang != null) {
      try {
        _currentLanguage = AppLanguage.values.firstWhere(
          (e) => e.toString() == savedLang,
        );
        notifyListeners();
      } catch (e) {
        _currentLanguage = AppLanguage.english;
      }
    }
  }
  
  Future<void> setLanguage(AppLanguage language) async {
    if (_currentLanguage == language) return;
    
    _currentLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language.toString());
    notifyListeners();
  }
  
  String translate(String english, String amharic, String oromo) {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return english;
      case AppLanguage.amharic:
        return amharic.isNotEmpty ? amharic : english;
      case AppLanguage.oromo:
        return oromo.isNotEmpty ? oromo : english;
    }
  }
  
  /// Cycle through languages (English → Amharic → Oromo → English)
  void cycleLanguage() {
    switch (_currentLanguage) {
      case AppLanguage.english:
        setLanguage(AppLanguage.amharic);
        break;
      case AppLanguage.amharic:
        setLanguage(AppLanguage.oromo);
        break;
      case AppLanguage.oromo:
        setLanguage(AppLanguage.english);
        break;
    }
  }
}