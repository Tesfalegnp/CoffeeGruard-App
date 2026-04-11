import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_provider.dart';

class ReviewAuditScreen extends StatefulWidget {
  const ReviewAuditScreen({super.key});

  @override
  State<ReviewAuditScreen> createState() => _ReviewAuditScreenState();
}

class _ReviewAuditScreenState extends State<ReviewAuditScreen> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<AdminProvider>(context, listen: false)
          .loadDetections();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminProvider>(context);

    // ================= FILTER REVIEWED ONLY =================
    final reviewed = provider.detections.where((d) {
      return d["is_reviewed"] == true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Audit"),
        backgroundColor: Colors.green,
      ),

      body: provider.detectionLoading
          ? const Center(child: CircularProgressIndicator())
          : reviewed.isEmpty
              ? const Center(
                  child: Text("No reviewed detections found"),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: reviewed.length,
                  itemBuilder: (_, i) {
                    final d = reviewed[i];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Text(
                            (d["disease_label"] ?? "?")
                                .toString()[0]
                                .toUpperCase(),
                          ),
                        ),

                        title: Text(d["disease_label"] ?? "Unknown"),

                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text("Severity: ${d["severity"] ?? "N/A"}"),
                            Text("Expert Note: ${d["expert_note"] ?? "No note"}"),
                            Text("Confidence: ${d["disease_confidence"] ?? 0}"),
                          ],
                        ),

                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {

                            // ================= ADMIN OVERRIDE =================
                            if (value == "approve") {
                              await provider.updateDetection(d["id"], {
                                "status": "approved",
                                "admin_override": true,
                              });

                              await provider.loadDetections();
                            }

                            if (value == "reject") {
                              await provider.updateDetection(d["id"], {
                                "status": "rejected",
                                "admin_override": true,
                              });

                              await provider.loadDetections();
                            }

                            if (value == "flag") {
                              await provider.updateDetection(d["id"], {
                                "admin_flag": true,
                                "status": "flagged",
                              });

                              await provider.loadDetections();
                            }

                            if (value == "delete") {
                              await provider.deleteDetection(
                                d["id"],
                                d["image_url"],
                              );
                            }
                          },

                          itemBuilder: (_) => const [

                            PopupMenuItem(
                              value: "approve",
                              child: Text("Force Approve"),
                            ),

                            PopupMenuItem(
                              value: "reject",
                              child: Text("Force Reject"),
                            ),

                            PopupMenuItem(
                              value: "flag",
                              child: Text("Flag as Bad Review"),
                            ),

                            PopupMenuDivider(),

                            PopupMenuItem(
                              value: "delete",
                              child: Text("Delete"),
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