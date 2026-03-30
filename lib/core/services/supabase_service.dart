import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final client = Supabase.instance.client;

  /// ===============================
  /// 📸 UPLOAD IMAGE
  /// ===============================
  Future<String?> uploadImage(File file, String fileName) async {
    try {
      final path = "uploads/$fileName";

      await client.storage
          .from('coffee-images')
          .upload(path, file);

      return client.storage
          .from('coffee-images')
          .getPublicUrl(path);
    } catch (e) {
      print("❌ Upload error: $e");
      return null;
    }
  }

  /// ===============================
  /// ☁ INSERT DETECTION
  /// ===============================
  Future<bool> insertDetection(Map<String, dynamic> data) async {
    try {
      await client.from('detections').insert(data);
      return true;
    } catch (e) {
      print("❌ Insert error: $e");
      return false;
    }
  }

  /// ===============================
  /// 🧠 UPDATE DETECTION REVIEW (FIXED 🔥)
  /// ===============================
  Future<bool> updateDetectionReview(
      String detectionId, Map<String, dynamic> data) async {
    try {
      print("📡 Updating detection ID: $detectionId");
      print("📦 Data: $data");

      final response = await client
          .from('detections')
          .update(data)
          .eq('id', detectionId)
          .select(); // ✅ IMPORTANT: returns updated rows

      if (response == null || response.isEmpty) {
        print("❌ No rows updated → ID mismatch or not found");
        return false;
      }

      print("✅ DB Updated: $response");
      return true;
    } catch (e) {
      print("❌ Review update error: $e");
      return false;
    }
  }
 /// ===============================
  /// 📥 recommedation update
  /// ===============================
  Future<bool> updateRecommendation(String id, Map<String, dynamic> data) async {
    try {
      await client.from('recommendations').update(data).eq('id', id);
      return true;
    } catch (e) {
      print("❌ Recommendation update error: $e");
      return false;
    }
  }
  /// ===============================
  /// 📥 FETCH DETECTIONS (WITH REVIEW)
  /// ===============================
  Future<List<Map<String, dynamic>>> fetchDetections() async {
    try {
      final response = await client
          .from('detections')
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("❌ Fetch detections error: $e");
      return [];
    }
  }

  /// ===============================
  /// 💡 GET RECOMMENDATION BY DISEASE
  /// ===============================
  Future<Map<String, dynamic>?> getRecommendationByDisease(String disease) async {
    try {
      final response = await client
          .from('recommendations')
          .select()
          .ilike('disease_label', disease)
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();

      return response;
    } catch (e) {
      print("❌ Recommendation fetch error: $e");
      return null;
    }
  }

  /// ===============================
  /// 📥 GET ALL RECOMMENDATIONS
  /// ===============================
  Future<List<Map<String, dynamic>>> getAllRecommendations() async {
    try {
      final response = await client
          .from('recommendations')
          .select()
          .order('updated_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("❌ Fetch recommendations error: $e");
      return [];
    }
  }
}