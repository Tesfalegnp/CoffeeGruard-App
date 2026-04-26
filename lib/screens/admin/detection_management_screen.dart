import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';

class DetectionManagementScreen extends StatefulWidget {
  const DetectionManagementScreen({super.key});

  @override
  State<DetectionManagementScreen> createState() =>
      _DetectionManagementScreenState();
}

class _DetectionManagementScreenState
    extends State<DetectionManagementScreen> {

  String filter = "all";

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<AdminProvider>(context, listen: false)
            .loadDetections());
  }

  List<Map<String, dynamic>> _applyFilter(
      List<Map<String, dynamic>> list) {
    if (filter == "pending") {
      return list.where((d) =>
          d["is_reviewed"] == false ||
          d["is_reviewed"] == null).toList();
    }
    if (filter == "reviewed") {
      return list.where((d) => d["is_reviewed"] == true).toList();
    }
    if (filter == "rejected") {
      return list.where((d) =>
          d["is_reviewed"] == true &&
          (d["expert_note"] ?? "")
              .toString()
              .toLowerCase()
              .contains("reject")).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminProvider>(context);

    final data = _applyFilter(provider.detections);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detection Management"),
        backgroundColor: Colors.green,
      ),

      body: provider.detectionLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [

                // ===== FILTER =====
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: DropdownButton<String>(
                    value: filter,
                    items: const [
                      DropdownMenuItem(value: "all", child: Text("All")),
                      DropdownMenuItem(value: "pending", child: Text("Pending")),
                      DropdownMenuItem(value: "reviewed", child: Text("Reviewed")),
                      DropdownMenuItem(value: "rejected", child: Text("Rejected")),
                    ],
                    onChanged: (v) {
                      setState(() => filter = v!);
                    },
                  ),
                ),

                // ===== LIST =====
                Expanded(
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (_, i) {
                      final d = data[i];

                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          leading: d["image_url"] != null
                              ? Image.network(
                                  d["image_url"],
                                  width: 50,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.image),

                          title: Text(d["disease_label"] ?? "Unknown"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Confidence: ${d["disease_confidence"]}"),
                              Text("Status: ${d["is_reviewed"] == true ? "Reviewed" : "Pending"}"),
                            ],
                          ),

                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == "approve") {
                                await provider.updateDetection(d["id"], {
                                  "is_reviewed": true,
                                  "status": "approved",
                                  "admin_override": true,
                                });
                              } else if (value == "reject") {
                                await provider.updateDetection(d["id"], {
                                  "is_reviewed": true,
                                  "status": "rejected",
                                  "expert_note": "Rejected by admin",
                                  "admin_override": true,
                                });
                              } else if (value == "delete") {
                                await provider.deleteDetection(
                                    d["id"], d["image_url"]);
                              } else if (value == "edit") {
                                _showEditDialog(context, d);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: "approve", child: Text("Approve")),
                              PopupMenuItem(value: "reject", child: Text("Reject")),
                              PopupMenuItem(value: "edit", child: Text("Edit")),
                              PopupMenuItem(value: "delete", child: Text("Delete")),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  // ================= EDIT DIALOG =================
  void _showEditDialog(BuildContext context, Map<String, dynamic> d) {
    final noteController =
        TextEditingController(text: d["expert_note"] ?? "");

    String severity = d["severity"] ?? "low";

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Edit Detection"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              TextField(
                controller: noteController,
                decoration:
                    const InputDecoration(labelText: "Expert Note"),
              ),

              DropdownButton<String>(
                value: severity,
                items: const [
                  DropdownMenuItem(value: "low", child: Text("Low")),
                  DropdownMenuItem(value: "medium", child: Text("Medium")),
                  DropdownMenuItem(value: "high", child: Text("High")),
                ],
                onChanged: (v) {
                  severity = v!;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                await Provider.of<AdminProvider>(context, listen: false)
                    .updateDetection(d["id"], {
                  "expert_note": noteController.text,
                  "severity": severity,
                  "is_reviewed": true,
                  "admin_override": true,
                });

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}