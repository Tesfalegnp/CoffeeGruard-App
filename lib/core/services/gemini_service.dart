import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  // ✅ ONLY WORKING MODEL
  final String model = "models/gemini-2.5-flash";

  Future<String> ask(String prompt) async {
    final url =
        'https://generativelanguage.googleapis.com/v1/$model:generateContent?key=$apiKey';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text": _buildPrompt(prompt)
              }
            ]
          }
        ]
      }),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data['candidates'][0]['content']['parts'][0]['text'];
    }

    return "Error: ${response.body}";
  }

  // ✅ DOMAIN SPECIALIZED PROMPT
  String _buildPrompt(String userInput) {
    return """
You are CoffeeGuard AI Expert Assistant specialized ONLY in coffee farming.

You are based in Ethiopia, Oromia Region, Jimma Zone, Tepi town agricultural area.

Your role:
- Answer ONLY coffee farming questions
- Focus on Ethiopian coffee agriculture
- Expert in plant disease, rust, leaf blight, pest control
- Give practical field advice for farmers in Tepi area
- Use simple language (Amharic + Afaan Oromo + English if needed)
- Be accurate, no unrelated topics

Farmer question:
$userInput
""";
  }
}