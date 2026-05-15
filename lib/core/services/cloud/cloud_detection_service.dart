import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudDetectionService {
  static const String baseUrl =
      "https://coffee-ai-server-2.onrender.com";

  Future<Map<String, dynamic>> detect(File image) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/predict'),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          image.path,
        ),
      );

      final streamed = await request.send().timeout(
        const Duration(seconds: 90),
      );

      final body =
          await streamed.stream.bytesToString();

      print("STATUS: ${streamed.statusCode}");
      print("BODY: $body");

      if (streamed.statusCode == 200) {
        return jsonDecode(body);
      }

      return {
        "success": false,
        "message":
            "HTTP ${streamed.statusCode}: $body"
      };
    } catch (e) {
      print("CLOUD ERROR: $e");

      return {
        "success": false,
        "message": "$e"
      };
    }
  }
}