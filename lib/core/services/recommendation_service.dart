import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/recommendation_model.dart';
import 'hive_service.dart';

class RecommendationService {
  final supabase = Supabase.instance.client;

  Future<void> syncRecommendations() async {
    try {
      final response = await supabase
          .from('recommendations')
          .select();

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
          updatedAt: e['updated_at'] != null
              ? DateTime.parse(e['updated_at'])
              : null,
        );
      }).toList();

      await HiveService.saveRecommendations(list);

      debugPrint("Synced ${list.length} recommendations");
    } catch (e) {
      debugPrint("Sync Error: $e");
    }
  }
}