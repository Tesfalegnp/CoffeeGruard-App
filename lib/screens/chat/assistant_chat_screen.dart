import 'package:flutter/material.dart';
import '../../core/services/gemini_service.dart';

class AssistantChatScreen extends StatefulWidget {
  const AssistantChatScreen({super.key});

  @override
  State<AssistantChatScreen> createState() =>
      _AssistantChatScreenState();
}

class _AssistantChatScreenState
    extends State<AssistantChatScreen> {
  final TextEditingController controller =
      TextEditingController();

  final GeminiService gemini =
      GeminiService();

  String reply = "";
  bool loading = false;

  Future<void> send() async {
    if (controller.text.trim().isEmpty) return;

    setState(() => loading = true);

    final result =
        await gemini.ask(controller.text);

    setState(() {
      reply = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("CoffeeGuard AI")),
      body: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration:
                  const InputDecoration(
                hintText:
                    "Ask about coffee disease...",
              ),
            ),
            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: send,
              child: const Text("Ask"),
            ),

            const SizedBox(height: 20),

            if (loading)
              const CircularProgressIndicator(),

            if (!loading)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(reply),
                ),
              ),
          ],
        ),
      ),
    );
  }
}