import 'package:flutter/material.dart';
import '../../core/services/feedback_service.dart';

class FeedbackViewScreen extends StatefulWidget {
  const FeedbackViewScreen({super.key});

  @override
  State<FeedbackViewScreen> createState() => _FeedbackViewScreenState();
}

class _FeedbackViewScreenState extends State<FeedbackViewScreen> {
  final FeedbackService service = FeedbackService();

  List<Map<String, dynamic>> feedbacks = [];
  bool loading = false;
  String selectedStatus = "all";

  @override
  void initState() {
    super.initState();
    loadFeedbacks();
  }

  Future<void> loadFeedbacks() async {
    setState(() => loading = true);

    final data = await service.getExpertFeedbacks(
      status: selectedStatus == "all" ? null : selectedStatus,
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
      resolvedBy: "expert",
    );

    loadFeedbacks();
  }

  Color statusColor(String status) {
    switch (status) {
      case "resolved":
        return Colors.green;
      case "in_progress":
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expert Feedback Review"),
        actions: [
          DropdownButton<String>(
            value: selectedStatus,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: "all", child: Text("All")),
              DropdownMenuItem(value: "pending", child: Text("Pending")),
              DropdownMenuItem(value: "in_progress", child: Text("In Progress")),
              DropdownMenuItem(value: "resolved", child: Text("Resolved")),
            ],
            onChanged: (value) {
              setState(() => selectedStatus = value!);
              loadFeedbacks();
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : feedbacks.isEmpty
              ? const Center(child: Text("No feedback found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: feedbacks.length,
                  itemBuilder: (context, index) {
                    final item = feedbacks[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['user_email'] ?? "Unknown",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor(item['status']),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    item['status'] ?? "pending",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            Text(
                              "Type: ${item['feedback_type']} | Rating: ${item['rating']}/5",
                              style: TextStyle(color: Colors.grey.shade700),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              item['message'] ?? "",
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 12),

                            // Actions
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () => updateStatus(
                                    item['id'],
                                    "in_progress",
                                  ),
                                  child: const Text("In Progress"),
                                ),
                                const SizedBox(width: 8),
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
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}