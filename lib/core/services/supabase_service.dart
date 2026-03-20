import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final client = Supabase.instance.client;

  /// ===============================
  /// 📸 UPLOAD IMAGE (FIXED BUCKET)
  /// ===============================
  Future<String?> uploadImage(File file, String fileName) async {
    try {
      final path = "uploads/$fileName";

      print("📤 Uploading image to Supabase...");

      await client.storage
          .from('coffee-images') // ✅ YOUR REAL BUCKET NAME
          .upload(path, file);

      final url = client.storage
          .from('coffee-images')
          .getPublicUrl(path);

      print("✅ Upload success");

      return url;

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
      print("📡 Sending detection to Supabase...");

      await client.from('detections').insert(data);

      print("✅ Detection inserted");

      return true;

    } catch (e) {
      print("❌ Insert error: $e");
      return false;
    }
  }

  /// ===============================
  /// 💡 GET RECOMMENDATION (FIXED)
  /// ===============================
  Future<Map<String, dynamic>?> getRecommendationByDisease(String disease) async {
    try {
      print("🔎 Fetching recommendation for: $disease");

      final response = await client
          .from('recommendations')
          .select()
          .ilike('disease_label', disease) // ✅ FIXED COLUMN NAME
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        print("⚠️ No recommendation found for $disease");
      } else {
        print("✅ Recommendation fetched");
      }

      return response;

    } catch (e) {
      print("❌ Recommendation fetch error: $e");
      return null;
    }
  }

  /// ===============================
  /// 📥 GET ALL RECOMMENDATIONS
  /// (FOR OFFLINE SYNC - NEXT STEP)
  /// ===============================
  Future<List<Map<String, dynamic>>> getAllRecommendations() async {
    try {
      print("📥 Fetching all recommendations...");

      final response = await client
          .from('recommendations')
          .select()
          .order('updated_at', ascending: false);

      print("✅ Recommendations fetched: ${response.length}");

      return List<Map<String, dynamic>>.from(response);

    } catch (e) {
      print("❌ Fetch all recommendations error: $e");
      return [];
    }
  }
}