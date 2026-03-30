import 'package:flutter/material.dart';
import '../../core/services/sync_service.dart';
import '../../models/detection_result_model.dart';
import 'package:intl/intl.dart';

class ReviewDetectionScreen extends StatefulWidget {
  final DetectionResultModel detection;

  const ReviewDetectionScreen({super.key, required this.detection});

  @override
  State<ReviewDetectionScreen> createState() =>
      _ReviewDetectionScreenState();
}

class _ReviewDetectionScreenState
    extends State<ReviewDetectionScreen> {

  final SyncService _syncService = SyncService();

  late TextEditingController _noteController;
  String? _selectedSeverity;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _noteController =
        TextEditingController(text: widget.detection.expertNote);
    _selectedSeverity =
        widget.detection.severityLevel ?? "low";
  }

  Color _severityColor(String? s) {
    switch (s) {
      case "high":
        return Colors.red;
      case "medium":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  Future<void> _saveReview() async {
    if (_selectedSeverity == null) return;

    setState(() => _loading = true);

    final data = {
      "is_reviewed": true,
      "expert_note": _noteController.text.trim(),
      "severity": _selectedSeverity,
    };

    try {
      final success = await _syncService.updateExpertReview(
        widget.detection.id,
        data,
      );

      if (!success) throw Exception("Update failed");

      widget.detection.isReviewed = true;
      widget.detection.expertNote = _noteController.text.trim();
      widget.detection.severityLevel = _selectedSeverity;

      if (widget.detection.isInBox) {
        await widget.detection.save();
      }

      await _syncService.pullExpertUpdates();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Review saved")),
        );
        Navigator.pop(context, true);
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to update")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    final d = widget.detection;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Detection"),
        backgroundColor: Colors.green.shade700,
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  /// 📸 IMAGE CARD
                  if (d.imageUrl != null)
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          d.imageUrl!,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  /// 🌿 DISEASE INFO CARD
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                d.diseaseLabel ?? "Unknown",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Chip(
                                label: Text(
                                  _selectedSeverity!.toUpperCase(),
                                ),
                                backgroundColor:
                                    _severityColor(_selectedSeverity)
                                        .withOpacity(0.2),
                                labelStyle: TextStyle(
                                  color: _severityColor(
                                      _selectedSeverity),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          LinearProgressIndicator(
                            value: d.diseaseConfidence ?? 0,
                            minHeight: 8,
                          ),

                          const SizedBox(height: 5),

                          Text(
                            "Confidence: ${(d.diseaseConfidence ?? 0) * 100}%",
                          ),

                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('yyyy-MM-dd HH:mm')
                                    .format(d.createdAt),
                                style: const TextStyle(
                                    color: Colors.grey),
                              ),
                              Text(
                                d.isReviewed
                                    ? "Reviewed ✅"
                                    : "Pending ⏳",
                                style: TextStyle(
                                  color: d.isReviewed
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 📝 NOTE
                  TextField(
                    controller: _noteController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: "Expert Note",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(15),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ⚠ SEVERITY
                  DropdownButtonFormField<String>(
                    value: _selectedSeverity,
                    decoration: InputDecoration(
                      labelText: "Severity",
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(15),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: "low", child: Text("Low 🟢")),
                      DropdownMenuItem(
                          value: "medium",
                          child: Text("Medium 🟡")),
                      DropdownMenuItem(
                          value: "high", child: Text("High 🔴")),
                    ],
                    onChanged: (v) =>
                        setState(() => _selectedSeverity = v),
                  ),

                  const SizedBox(height: 25),

                  /// 💾 SAVE BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.green.shade700,
                        padding:
                            const EdgeInsets.symmetric(
                                vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "Save Review",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}