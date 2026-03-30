import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';

class ManageRecommendationsScreen extends StatefulWidget {
  const ManageRecommendationsScreen({super.key});

  @override
  State<ManageRecommendationsScreen> createState() =>
      _ManageRecommendationsScreenState();
}

class _ManageRecommendationsScreenState
    extends State<ManageRecommendationsScreen> {
  final SupabaseService _supabaseService = SupabaseService();

  List<Map<String, dynamic>> _recommendations = [];
  List<bool> _expandedFlags = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() => _loading = true);
    final data = await _supabaseService.getAllRecommendations();
    setState(() {
      _recommendations = data;
      _expandedFlags = List.filled(data.length, false);
      _loading = false;
    });
  }

  Future<void> _saveRecommendation(int index) async {
    final rec = _recommendations[index];
    final updated = {
      "title": rec["title"],
      "content": rec["content"],
      "title_am": rec["title_am"],       // Amharic title
      "content_am": rec["content_am"],   // Amharic content
      "priority": rec["priority"],
      "updated_at": DateTime.now().toIso8601String(),
    };
    final success =
        await _supabaseService.updateRecommendation(rec["id"], updated);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Recommendation updated")),
      );
      _loadRecommendations();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Update failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Recommendations"),
        backgroundColor: Colors.green.shade700,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _recommendations.length,
              itemBuilder: (context, index) {
                final rec = _recommendations[index];
                final isExpanded = _expandedFlags[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 3,
                  child: Column(
                    children: [
                      // Header
                      ListTile(
                        title: Text(
                          rec["title"] ?? "No title",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(
                          "Priority: ${rec["priority"] ?? "medium"}",
                          style: TextStyle(
                            color: _priorityColor(rec["priority"]),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                          ),
                          onPressed: () {
                            setState(() {
                              _expandedFlags[index] = !isExpanded;
                            });
                          },
                        ),
                      ),

                      // Expanded content
                      if (isExpanded)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // English Content
                              const Text("Content (EN):",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              TextField(
                                maxLines: null,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                                controller: TextEditingController(
                                    text: rec["content"] ?? ""),
                                onChanged: (v) => rec["content"] = v,
                              ),
                              const SizedBox(height: 8),

                              // Amharic Content
                              const Text("Content (AM):",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              TextField(
                                maxLines: null,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                                controller: TextEditingController(
                                    text: rec["content_am"] ?? ""),
                                onChanged: (v) => rec["content_am"] = v,
                              ),
                              const SizedBox(height: 8),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  DropdownButton<String>(
                                    value: rec["priority"] ?? "medium",
                                    items: const [
                                      DropdownMenuItem(
                                          value: "low", child: Text("Low")),
                                      DropdownMenuItem(
                                          value: "medium",
                                          child: Text("Medium")),
                                      DropdownMenuItem(
                                          value: "high", child: Text("High")),
                                      DropdownMenuItem(
                                          value: "critical",
                                          child: Text("Critical")),
                                    ],
                                    onChanged: (v) {
                                      setState(() {
                                        rec["priority"] = v;
                                      });
                                    },
                                  ),
                                  ElevatedButton(
                                    onPressed: () => _saveRecommendation(index),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.green.shade700),
                                    child: const Text("Save"),
                                  )
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Color _priorityColor(String? priority) {
    switch (priority) {
      case "low":
        return Colors.green;
      case "medium":
        return Colors.orange;
      case "high":
        return Colors.red;
      case "critical":
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}