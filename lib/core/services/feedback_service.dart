import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class FeedbackService {
  final supabase = Supabase.instance.client;
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  static const String bucketName = 'feedback-screenshots';

  /// ==========================================================
  /// UPLOAD SCREENSHOTS TO SUPABASE STORAGE
  /// ==========================================================
  Future<List<String>> uploadScreenshots({
    required String userId,
    required List<File> files,
  }) async {
    try {
      List<String> urls = [];

      for (final file in files) {
        final ext = path.extension(file.path);

        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_$userId$ext';

        final filePath = 'users/$userId/$fileName';

        await supabase.storage.from(bucketName).upload(
              filePath,
              file,
              fileOptions: const FileOptions(
                upsert: true,
                cacheControl: '3600',
              ),
            );

        final publicUrl =
            supabase.storage.from(bucketName).getPublicUrl(filePath);

        urls.add(publicUrl);
      }

      return urls;
    } catch (e) {
      print("❌ Screenshot upload error: $e");
      return [];
    }
  }

  /// ==========================================================
  /// SEND FEEDBACK
  /// ==========================================================
  Future<bool> sendFeedback({
    required String userId,
    required String userEmail,
    required String feedbackType,
    required String targetRole,
    required String message,
    required int rating,
    List<String>? screenshotUrls,
    String? category,
    String? priority,
  }) async {
    try {
      final deviceData = await _getDeviceInfo();

      final packageInfo = await PackageInfo.fromPlatform();

      final appVersion =
          "${packageInfo.version}+${packageInfo.buildNumber}";

      final feedbackData = {
        'user_id': userId,
        'user_email': userEmail,
        'feedback_type': feedbackType,
        'target_role': targetRole,
        'message': message,
        'rating': rating,
        'status': 'pending',
        'priority': priority ?? _getPriorityFromRating(rating),
        'category': category ?? feedbackType,
        'app_version': appVersion,
        'device_info': deviceData,
        'screenshot_url': screenshotUrls ?? [],
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await supabase
          .from('feedbacks')
          .insert(feedbackData)
          .select();

      print("✅ Feedback submitted successfully: $response");

      return true;
    } catch (e) {
      print("❌ Feedback submission error: $e");
      return false;
    }
  }

  /// ==========================================================
  /// GET DEVICE INFO
  /// ==========================================================
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;

        return {
          'platform': 'android',
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'version': androidInfo.version.release,
          'sdk_int': androidInfo.version.sdkInt,
          'brand': androidInfo.brand,
          'device': androidInfo.device,
        };
      }

      if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;

        return {
          'platform': 'ios',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'system_version': iosInfo.systemVersion,
          'identifier_for_vendor': iosInfo.identifierForVendor,
        };
      }

      return {
        'platform': 'other',
        'info': 'Unknown platform',
      };
    } catch (e) {
      return {
        'platform': 'unknown',
        'error': e.toString(),
      };
    }
  }

  /// ==========================================================
  /// PRIORITY FROM RATING
  /// ==========================================================
  String _getPriorityFromRating(int rating) {
    if (rating <= 2) return 'high';
    if (rating == 3) return 'medium';
    return 'low';
  }

  /// ==========================================================
  /// GET USER FEEDBACKS
  /// ==========================================================
  Future<List<Map<String, dynamic>>> getUserFeedbacks(
      String userId) async {
    try {
      final response = await supabase
          .from('feedbacks')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("❌ Error fetching user feedbacks: $e");
      return [];
    }
  }

  /// ==========================================================
  /// GET ALL FEEDBACKS
  /// ==========================================================
  Future<List<Map<String, dynamic>>> getAllFeedbacks({
            String? status,
            String? priority,
            int? limit,
            int? offset,
          }) async {
            try {
              var query = supabase.from('feedbacks').select();

              if (status != null) {
                query = query.eq('status', status);
              }

              if (priority != null) {
                query = query.eq('priority', priority);
              }

              final data = await query
                  .order('created_at', ascending: false)
                  .range(
                    offset ?? 0,
                    (offset ?? 0) + (limit ?? 20) - 1,
                  );

              return List<Map<String, dynamic>>.from(data);
            } catch (e) {
              print("❌ Error fetching all feedbacks: $e");
              return [];
            }
          }

  /// ==========================================================
  /// UPDATE FEEDBACK STATUS
  /// ==========================================================
  Future<bool> updateFeedbackStatus({
    required String feedbackId,
    required String status,
    String? adminNote,
    String? resolvedBy,
  }) async {
    try {
      final data = {
        'status': status,
        'admin_note': adminNote,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (status == 'resolved') {
        data['resolved_at'] =
            DateTime.now().toIso8601String();

        data['resolved_by'] = resolvedBy;
      }

      await supabase
          .from('feedbacks')
          .update(data)
          .eq('id', feedbackId);

      return true;
    } catch (e) {
      print("❌ Update status error: $e");
      return false;
    }
  }

  /// ==========================================================
  /// DELETE FEEDBACK
  /// ==========================================================
  Future<bool> deleteFeedback(String feedbackId) async {
    try {
      await supabase
          .from('feedbacks')
          .delete()
          .eq('id', feedbackId);

      return true;
    } catch (e) {
      print("❌ Delete error: $e");
      return false;
    }
  }

  /// ==========================================================
  /// GET STATS
  /// ==========================================================
  Future<Map<String, dynamic>> getFeedbackStats() async {
    try {
      final response =
          await supabase.from('feedback_stats').select();

      if (response.isNotEmpty) {
        return Map<String, dynamic>.from(response[0]);
      }

      return {};
    } catch (e) {
      print("❌ Stats error: $e");
      return {};
    }
  }
  /// ==========================================================
/// GET FEEDBACKS FOR EXPERT VIEW (FILTERED + CLEAN DATA)
/// ==========================================================
Future<List<Map<String, dynamic>>> getExpertFeedbacks({
  String? status,
  int limit = 50,
}) async {
  try {
    var query = supabase
        .from('feedbacks')
        .select('''
          id,
          user_email,
          feedback_type,
          target_role,
          message,
          rating,
          status,
          priority,
          created_at
        ''')
        .eq('target_role', 'expert');

    if (status != null) {
      query = query.eq('status', status);
    }

    final response = await query
        .order('created_at', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    print("❌ Expert feedback fetch error: $e");
    return [];
  }
}
              /// ==========================================================
              /// ADMIN FEEDBACK VIEW (FULL CONTROL)
              /// ==========================================================
              Future<List<Map<String, dynamic>>> getAdminFeedbacks({
                String? status,
                String? priority,
                String? feedbackType,
                int limit = 50,
              }) async {
                try {
                  var query = supabase.from('feedbacks').select('''
                    id,
                    user_id,
                    user_email,
                    feedback_type,
                    target_role,
                    category,
                    priority,
                    message,
                    rating,
                    status,
                    admin_note,
                    resolved_by,
                    resolved_at,
                    created_at
                  ''');

                  if (status != null && status != "all") {
                    query = query.eq('status', status);
                  }

                  if (priority != null && priority != "all") {
                    query = query.eq('priority', priority);
                  }

                  if (feedbackType != null && feedbackType != "all") {
                    query = query.eq('feedback_type', feedbackType);
                  }

                  final response = await query
                      .order('created_at', ascending: false)
                      .limit(limit);

                  return List<Map<String, dynamic>>.from(response);
                } catch (e) {
                  print("❌ Admin feedback fetch error: $e");
                  return [];
                }
              }
}