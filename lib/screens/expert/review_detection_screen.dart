import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/services/sync_service.dart';
import '../../models/detection_result_model.dart';

class ReviewDetectionScreen extends StatefulWidget {
  final DetectionResultModel detection;

  const ReviewDetectionScreen({
    super.key,
    required this.detection,
  });

  @override
  State<ReviewDetectionScreen> createState() =>
      _ReviewDetectionScreenState();
}

class _ReviewDetectionScreenState extends State<ReviewDetectionScreen> {
  final SyncService _syncService = SyncService();

  late TextEditingController _noteController;
  String _selectedSeverity = "low";
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    _noteController = TextEditingController(
      text: widget.detection.expertNote ?? "",
    );

    _selectedSeverity =
        widget.detection.severityLevel ?? "low";
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Color _confidenceColor(double c) {
    if (c >= 0.85) return Colors.green;
    if (c >= 0.6) return Colors.orange;
    return Colors.red;
  }

  /// ===============================
  /// 🚀 SUBMIT REVIEW (FIXED)
  /// ===============================
  Future<void> _submitReview({required bool approved}) async {
    setState(() => _loading = true);

    try {
      /// 🔥 IMPORTANT FIX: use severity_level (DB COLUMN)
      final Map<String, dynamic> payload = {
        "is_reviewed": true,
        "expert_note": _noteController.text.trim(),
        "severity_level": _selectedSeverity,
        "status": approved ? "approved" : "rejected",
        "updated_at": DateTime.now().toIso8601String(),
      };

      print("📡 Sending review update payload:");
      print(payload);

      final success = await _syncService.updateExpertReview(
        widget.detection.id,
        payload,
      );

      if (!success) {
        throw Exception("Update failed from Supabase layer");
      }

      if (mounted) {
        Navigator.pop(context, true); // refresh queue
      }
    } catch (e) {
      print("❌ Review update error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Failed to update review"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.detection;
    final confidence = d.diseaseConfidence ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Expert Review"),
        backgroundColor: Colors.green,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// ================= IMAGE =================
                  if (d.imageUrl != null && d.imageUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        d.imageUrl!,
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image, size: 80),
                      ),
                    ),

                  const SizedBox(height: 20),

                  /// ================= DISEASE =================
                  Text(
                    d.diseaseLabel ?? "Unknown",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// ================= CONFIDENCE =================
                  LinearProgressIndicator(
                    value: confidence,
                    color: _confidenceColor(confidence),
                    backgroundColor: Colors.grey.shade300,
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Confidence: ${(confidence * 100).toStringAsFixed(2)}%",
                  ),

                  const SizedBox(height: 10),

                  /// ================= DATE =================
                  Text(
                    DateFormat('yyyy-MM-dd HH:mm')
                        .format(d.createdAt),
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 20),

                  /// ================= NOTE =================
                  TextField(
                    controller: _noteController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: "Expert Note",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ================= SEVERITY =================
                  DropdownButtonFormField<String>(
                    value: _selectedSeverity,
                    decoration: const InputDecoration(
                      labelText: "Severity Level",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: "low",
                        child: Text("Low 🟢"),
                      ),
                      DropdownMenuItem(
                        value: "medium",
                        child: Text("Medium 🟡"),
                      ),
                      DropdownMenuItem(
                        value: "high",
                        child: Text("High 🔴"),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _selectedSeverity = v);
                      }
                    },
                  ),

                  const SizedBox(height: 30),

                  /// ================= ACTION BUTTONS =================
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.close),
                          label: const Text("Reject"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () =>
                              _submitReview(approved: false),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check),
                          label: const Text("Approve"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () =>
                              _submitReview(approved: true),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}