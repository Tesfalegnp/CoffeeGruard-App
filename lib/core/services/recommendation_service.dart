import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/recommendation_model.dart';
import 'hive_service.dart';

class RecommendationService {
  final supabase = Supabase.instance.client;

  /// ==============================
  /// 🔄 SYNC ALL RECOMMENDATIONS (Pull from cloud to local)
  /// ==============================
  Future<void> syncRecommendations() async {
    try {
      debugPrint("🔄 Syncing recommendations from cloud...");
      
      final response = await supabase.from('recommendations').select();

      final data = response as List;

      final list = data.map((e) {
        return RecommendationModel(
          id: e['id'],
          diseaseLabel: e['disease_label'],
          severity: e['severity'],
          title: e['title'],
          content: e['content'],
          titleAm: e['title_am'],
          contentAm: e['content_am'],
          titleOm: e['title_om'],
          contentOm: e['content_om'],
          priority: e['priority'] ?? 'medium',
          category: e['category'],
          updatedAt: e['updated_at'] != null
              ? DateTime.parse(e['updated_at'])
              : null,
        );
      }).toList();

      await HiveService.saveRecommendations(list);

      debugPrint("✅ Synced ${list.length} recommendations from cloud to local");
    } catch (e) {
      debugPrint("❌ Sync Error: $e");
    }
  }

  /// ==========================================
  /// 🌍 GET RECOMMENDATION (Check LOCAL first, then cloud)
  /// ==========================================
  Future<String> getRecommendation({
    required String diseaseLabel,
    required String languageCode, // en | am | om
  }) async {
    try {
      debugPrint("🔍 Looking for recommendation: $diseaseLabel in $languageCode");
      
      // ==============================
      // 1️⃣ FIRST: Check LOCAL HIVE cache
      // ==============================
      final localRecommendation = await _getLocalRecommendation(diseaseLabel);
      
      if (localRecommendation != null) {
        debugPrint("✅ Found local recommendation for: $diseaseLabel");
        return _getTextByLanguage(localRecommendation, languageCode);
      }
      
      // ==============================
      // 2️⃣ SECOND: Try cloud if not in local
      // ==============================
      debugPrint("⚠️ No local recommendation, fetching from cloud...");
      
      final response = await supabase
          .from('recommendations')
          .select()
          .eq('disease_label', diseaseLabel)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        // Save to local for future use
        final newRec = RecommendationModel(
          id: response['id'],
          diseaseLabel: response['disease_label'],
          severity: response['severity'],
          title: response['title'],
          content: response['content'],
          titleAm: response['title_am'],
          contentAm: response['content_am'],
          titleOm: response['title_om'],
          contentOm: response['content_om'],
          priority: response['priority'] ?? 'medium',
          category: response['category'],
          updatedAt: response['updated_at'] != null
              ? DateTime.parse(response['updated_at'])
              : null,
        );
        
        await HiveService.saveSingleRecommendation(newRec);
        
        return _getTextByLanguage(newRec, languageCode);
      }

      // ==============================
      // 3️⃣ THIRD: Fallback with fuzzy matching
      // ==============================
      debugPrint("⚠️ No exact match, trying fuzzy match...");
      final fuzzyMatch = await _fuzzyMatchRecommendation(diseaseLabel);
      
      if (fuzzyMatch != null) {
        return _getTextByLanguage(fuzzyMatch, languageCode);
      }

      // ==============================
      // 4️⃣ LAST: Default fallback
      // ==============================
      return _fallback(languageCode);
      
    } catch (e) {
      debugPrint("❌ Fetch Error: $e");
      
      // Try local one more time on error
      final localRec = await _getLocalRecommendation(diseaseLabel);
      if (localRec != null) {
        return _getTextByLanguage(localRec, languageCode);
      }
      
      return _fallback(languageCode);
    }
  }

  /// ==============================
  /// 📦 Get from LOCAL HIVE
  /// ==============================
  Future<RecommendationModel?> _getLocalRecommendation(String diseaseLabel) async {
    try {
      final allRecs = HiveService.getAllRecommendations();
      
      if (allRecs.isEmpty) {
        debugPrint("📦 Local recommendation box is empty");
        return null;
      }
      
      final normalizedDisease = diseaseLabel.toLowerCase().trim();
      
      // Exact match
      for (var rec in allRecs) {
        if (rec.diseaseLabel.toLowerCase().trim() == normalizedDisease) {
          return rec;
        }
      }
      
      // Contains match
      for (var rec in allRecs) {
        final recLabel = rec.diseaseLabel.toLowerCase().trim();
        if (normalizedDisease.contains(recLabel) || recLabel.contains(normalizedDisease)) {
          debugPrint("🔍 Fuzzy match: $diseaseLabel -> ${rec.diseaseLabel}");
          return rec;
        }
      }
      
      return null;
    } catch (e) {
      debugPrint("❌ Local get error: $e");
      return null;
    }
  }
  
  /// ==============================
  /// 🔍 Fuzzy match from cloud
  /// ==============================
  Future<RecommendationModel?> _fuzzyMatchRecommendation(String diseaseLabel) async {
    try {
      final allRecs = await supabase.from('recommendations').select();
      
      if (allRecs == null || allRecs.isEmpty) return null;
      
      final normalizedInput = diseaseLabel.toLowerCase().trim();
      
      for (var rec in allRecs) {
        final recLabel = rec['disease_label'].toLowerCase().trim();
        if (normalizedInput.contains(recLabel) || recLabel.contains(normalizedInput)) {
          return RecommendationModel(
            id: rec['id'],
            diseaseLabel: rec['disease_label'],
            severity: rec['severity'],
            title: rec['title'],
            content: rec['content'],
            titleAm: rec['title_am'],
            contentAm: rec['content_am'],
            titleOm: rec['title_om'],
            contentOm: rec['content_om'],
            priority: rec['priority'] ?? 'medium',
            category: rec['category'],
            updatedAt: rec['updated_at'] != null
                ? DateTime.parse(rec['updated_at'])
                : null,
          );
        }
      }
      
      return null;
    } catch (e) {
      debugPrint("❌ Fuzzy match error: $e");
      return null;
    }
  }

  /// ==============================
  /// 🌍 Get text by language
  /// ==============================
  String _getTextByLanguage(RecommendationModel rec, String languageCode) {
    switch (languageCode) {
      case "am":
        return rec.contentAm ?? rec.content ?? _fallback(languageCode);
      case "om":
        return rec.contentOm ?? rec.content ?? _fallback(languageCode);
      default:
        return rec.content ?? _fallback(languageCode);
    }
  }

  /// ==============================
  /// 🔁 FALLBACK TEXT
  /// ==============================
  String _fallback(String lang) {
    switch (lang) {
      case "am":
        return "ምክር አልተገኘም። እባክዎ ይህን ቅጠል ለባለሙያ ያሳዩ።";
      case "om":
        return "Gorsi hin argamne. Maaloo baala kana hayyuuf agarsiisaa.";
      default:
        return "Recommendation not found. Please consult an expert for this coffee leaf condition.";
    }
  }
  
  /// ==============================
  /// 📝 Add/Update recommendation (for experts)
  /// ==============================
  Future<bool> saveRecommendation(RecommendationModel recommendation) async {
    try {
      final exists = await _checkIfExists(recommendation.diseaseLabel, recommendation.severity);
      
      if (exists) {
        // Update existing
        await supabase.from('recommendations').update({
          'title': recommendation.title,
          'content': recommendation.content,
          'title_am': recommendation.titleAm,
          'content_am': recommendation.contentAm,
          'title_om': recommendation.titleOm,
          'content_om': recommendation.contentOm,
          'priority': recommendation.priority,
          'category': recommendation.category,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('disease_label', recommendation.diseaseLabel)
          .eq('severity', recommendation.severity);
      } else {
        // Insert new
        await supabase.from('recommendations').insert({
          'disease_label': recommendation.diseaseLabel,
          'severity': recommendation.severity,
          'title': recommendation.title,
          'content': recommendation.content,
          'title_am': recommendation.titleAm,
          'content_am': recommendation.contentAm,
          'title_om': recommendation.titleOm,
          'content_om': recommendation.contentOm,
          'priority': recommendation.priority,
          'category': recommendation.category,
        });
      }
      
      // Resync local cache
      await syncRecommendations();
      
      return true;
    } catch (e) {
      debugPrint("❌ Save recommendation error: $e");
      return false;
    }
  }
  
  /// ==============================
  /// 🔍 Check if recommendation exists
  /// ==============================
  Future<bool> _checkIfExists(String diseaseLabel, String severity) async {
    try {
      final response = await supabase
          .from('recommendations')
          .select()
          .eq('disease_label', diseaseLabel)
          .eq('severity', severity)
          .maybeSingle();
          
      return response != null;
    } catch (e) {
      return false;
    }
  }
}