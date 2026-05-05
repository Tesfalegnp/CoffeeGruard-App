import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackService {
  final SupabaseClient _client = Supabase.instance.client;

  /// ==============================
  /// SEND FEEDBACK TO SUPABASE
  /// ==============================
  Future<bool> sendFeedback({
    required String userId,
    required String userEmail,
    required String feedbackType,
    required String targetRole,
    required String message,
    int rating = 0,
  }) async {
    try {
      await _client.from('feedbacks').insert({
        'user_id': userId,
        'user_email': userEmail,
        'feedback_type': feedbackType,
        'target_role': targetRole,
        'message': message,
        'rating': rating,
      });

      return true;
    } catch (e) {
      print("Feedback error: $e");
      return false;
    }
  }

  /// ==============================
  /// GET FEEDBACKS (ADMIN / EXPERT)
  /// ==============================
  Future<List<Map<String, dynamic>>> getFeedbacks({
    String? type,
    String? role,
  }) async {
    try {
      var query = _client.from('feedbacks').select();

      if (type != null) {
        query = query.eq('feedback_type', type);
      }

      if (role != null) {
        query = query.eq('target_role', role);
      }

      final data = await query.order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print("Fetch feedback error: $e");
      return [];
    }
  }
}