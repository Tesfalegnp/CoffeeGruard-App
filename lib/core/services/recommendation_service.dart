import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/recommendation_model.dart';
import 'hive_service.dart';

class RecommendationService {

  final supabase = Supabase.instance.client;

  /// 🔄 Download from Supabase → save locally
  Future<void> syncRecommendations() async {

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
        priority: e['priority'] ?? 'medium',
        updatedAt: e['updated_at'] != null
            ? DateTime.parse(e['updated_at'])
            : null,
      );

    }).toList();

    await HiveService.saveRecommendations(list);
  }
}