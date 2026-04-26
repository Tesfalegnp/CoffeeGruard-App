import 'supabase_service.dart';

class ModelMonitorService {
  final SupabaseService _supabase = SupabaseService();

  // ===============================
  // 📥 FETCH EVALUATION DATA
  // ===============================
  Future<List<Map<String, dynamic>>> getEvaluations() async {
    return await _supabase.fetchModelEvaluationData();
  }

  // ===============================
  // 🎯 CALCULATE ACCURACY
  // ===============================
  double calculateAccuracy(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 0;

    int correct = 0;

    for (var d in data) {
      final ai = d["disease_label"];
      final expert = d["severity"]; // expert proxy field

      if (ai != null && expert != null) {
        if (ai.toString().toLowerCase().trim() ==
            expert.toString().toLowerCase().trim()) {
          correct++;
        }
      }
    }

    return (correct / data.length) * 100;
  }

  // ===============================
  // ❌ ERROR RATE
  // ===============================
  double calculateErrorRate(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 0;
    return 100 - calculateAccuracy(data);
  }

  // ===============================
  // 🔥 MOST COMMON MISTAKES
  // ===============================
  Map<String, int> getMisclassified(List<Map<String, dynamic>> data) {
    Map<String, int> errors = {};

    for (var d in data) {
      final ai = d["disease_label"];
      final expert = d["severity"];

      if (ai != null && expert != null) {
        final aiStr = ai.toString().toLowerCase().trim();
        final expertStr = expert.toString().toLowerCase().trim();

        if (aiStr != expertStr) {
          final key = "$ai → $expert";
          errors[key] = (errors[key] ?? 0) + 1;
        }
      }
    }

    return errors;
  }
}