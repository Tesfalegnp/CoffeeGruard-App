import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {

  final client = Supabase.instance.client;

  /// ✅ Upload Image
  Future<String?> uploadImage(File file, String fileName) async {

    try {

      final path = "uploads/$fileName";

      await client.storage
          .from('coffee-images') // ⚠️ MUST MATCH YOUR BUCKET
          .upload(path, file);

      final url = client.storage
          .from('coffee-images')
          .getPublicUrl(path);

      return url;

    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }

  /// ✅ Insert detection
  Future<bool> insertDetection(Map<String, dynamic> data) async {

    try {

      await client.from('detections').insert(data);

      return true;

    } catch (e) {

      print("Insert error: $e");
      return false;
    }
  }
}