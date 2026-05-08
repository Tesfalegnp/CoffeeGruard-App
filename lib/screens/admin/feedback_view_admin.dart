import 'package:flutter/material.dart';
import '../../core/services/feedback_service.dart';

class FeedbackViewAdmin extends StatefulWidget {
  const FeedbackViewAdmin({super.key});

  @override
  State<FeedbackViewAdmin> createState() => _FeedbackViewAdminState();
}

class _FeedbackViewAdminState extends State<FeedbackViewAdmin> {
  final FeedbackService service = FeedbackService();

  List<Map<String, dynamic>> feedbacks = [];
  bool loading = false;

  String statusFilter = "all";
  String priorityFilter = "all";
  String typeFilter = "all";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => loading = true);

    final data = await service.getAdminFeedbacks(
      status: statusFilter,
      priority: priorityFilter,
      feedbackType: typeFilter,
    );

    setState(() {
      feedbacks = data;
      loading = false;
    });
  }

  Future<void> updateStatus(String id, String status) async {
    await service.updateFeedbackStatus(
      feedbackId: id,
      status: status,
      resolvedBy: "admin",
    );

    loadData();
  }

  Future<void> addNote(String id, String note) async {
    await service.supabase
        .from('feedbacks')
        .update({'admin_note': note}).eq('id', id);

    loadData();
  }

  Color statusColor(String status) {
    switch (status) {
      case "resolved":
        return Colors.green;
      case "in_progress":
        return Colors.orange;
      case "pending":
      default:
        return Colors.red;
    }
  }

  Color priorityColor(String priority) {
    switch (priority) {
      case "high":
        return Colors.red;
      case "medium":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  void showNoteDialog(String id) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Admin Note"),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: "Write admin note...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              addNote(id, controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Feedback Panel"),
        actions: [
          // STATUS FILTER
          DropdownButton<String>(
            value: statusFilter,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: "all", child: Text("All")),
              DropdownMenuItem(value: "pending", child: Text("Pending")),
              DropdownMenuItem(value: "in_progress", child: Text("In Progress")),
              DropdownMenuItem(value: "resolved", child: Text("Resolved")),
            ],
            onChanged: (value) {
              setState(() => statusFilter = value!);
              loadData();
            },
          ),

          const SizedBox(width: 10),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : feedbacks.isEmpty
              ? const Center(child: Text("No feedback found"))
              : RefreshIndicator(
                  onRefresh: loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: feedbacks.length,
                    itemBuilder: (context, index) {
                      final item = feedbacks[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // HEADER
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['user_email'] ?? "Unknown",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      _badge(
                                        item['status'],
                                        statusColor(item['status']),
                                      ),
                                      const SizedBox(width: 6),
                                      _badge(
                                        item['priority'],
                                        priorityColor(item['priority']),
                                      ),
                                    ],
                                  )
                                ],
                              ),

                              const SizedBox(height: 8),

                              Text(
                                "Type: ${item['feedback_type']} | Rating: ${item['rating']}/5",
                                style: TextStyle(color: Colors.grey.shade600),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                item['message'] ?? "",
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),

                              if (item['admin_note'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "Admin Note: ${item['admin_note']}",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 12),

                              Wrap(
                                spacing: 8,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => updateStatus(
                                      item['id'],
                                      "in_progress",
                                    ),
                                    child: const Text("Progress"),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    onPressed: () => updateStatus(
                                      item['id'],
                                      "resolved",
                                    ),
                                    child: const Text("Resolve"),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    onPressed: () => updateStatus(
                                      item['id'],
                                      "pending",
                                    ),
                                    child: const Text("Reset"),
                                  ),
                                  OutlinedButton(
                                    onPressed: () =>
                                        showNoteDialog(item['id']),
                                    child: const Text("Note"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }
}