import 'supabase_service.dart';

class AdminService {
  final SupabaseService _supabase = SupabaseService();

  // ===============================
  // 👥 USERS
  // ===============================
  Future<List<Map<String, dynamic>>> getUsers() async {
    return await _supabase.fetchUsers();
  }

  Future<bool> createUser(Map<String, dynamic> data) async {
    return await _supabase.createUser(data);
  }

  Future<bool> updateUser(String id, Map<String, dynamic> data) async {
    return await _supabase.updateUser(id, data);
  }

  Future<bool> deleteUser(String id) async {
    return await _supabase.deleteUser(id);
  }

  // ===============================
  // 🗂 DETECTIONS (ADMIN CONTROL)
  // ===============================

  /// 📥 GET ALL DETECTIONS (ADMIN VIEW)
  Future<List<Map<String, dynamic>>> getDetections() async {
    return await _supabase.fetchDetections();
  }

  /// 🔄 BACKWARD COMPATIBILITY (your old code)
  Future<List<Map<String, dynamic>>> getAllDetections() async {
    return await _supabase.fetchDetections();
  }

  // ===============================
  // ✏ UPDATE DETECTION (ADMIN OVERRIDE)
  // ===============================
  Future<bool> updateDetection(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await _supabase.updateDetectionReview(id, data);
  }

  // ===============================
  // ❌ DELETE DETECTION
  // ===============================
  Future<bool> deleteDetection(
    String id,
    String? imageUrl,
  ) async {
    try {
      // delete image first if exists
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await _supabase.deleteImageFromStorage(imageUrl);
      }

      return await _supabase.deleteDetection(id);
    } catch (e) {
      print("❌ Admin delete detection error: $e");
      return false;
    }
  }

  // ===============================
  // 📊 ANALYTICS SUPPORT HOOKS
  // ===============================

  /// used by AdminProvider analytics
  Future<List<Map<String, dynamic>>> getDetectionsForAnalytics() async {
    return await _supabase.fetchDetections();
  }

  Future<List<Map<String, dynamic>>> getUsersForAnalytics() async {
    return await _supabase.fetchUsers();
  }
}