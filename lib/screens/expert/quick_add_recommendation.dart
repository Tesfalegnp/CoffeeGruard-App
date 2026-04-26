import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';

class QuickAddRecommendation extends StatefulWidget {
  const QuickAddRecommendation({super.key});

  @override
  State<QuickAddRecommendation> createState() => _QuickAddRecommendationState();
}

class _QuickAddRecommendationState extends State<QuickAddRecommendation> {
  final SupabaseService _service = SupabaseService();

  final TextEditingController title = TextEditingController();
  final TextEditingController content = TextEditingController();

  String priority = "medium";
  bool loading = false;

  Future<void> save() async {
    setState(() => loading = true);

    final data = {
      "title": title.text,
      "content": content.text,
      "priority": priority,
      "created_at": DateTime.now().toIso8601String(),
    };

    final res = await _service.updateRecommendation("NEW", data);

    setState(() => loading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saved recommendation")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quick Add Recommendation")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: "Title"),
            ),

            TextField(
              controller: content,
              maxLines: 4,
              decoration: const InputDecoration(labelText: "Content"),
            ),

            DropdownButton<String>(
              value: priority,
              items: const [
                DropdownMenuItem(value: "low", child: Text("Low")),
                DropdownMenuItem(value: "medium", child: Text("Medium")),
                DropdownMenuItem(value: "high", child: Text("High")),
              ],
              onChanged: (v) => setState(() => priority = v!),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : save,
              child: Text(loading ? "Saving..." : "Save"),
            ),
          ],
        ),
      ),
    );
  }
}