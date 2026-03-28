import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';
import '../../models/detection_result_model.dart';
import 'package:intl/intl.dart';

class ReviewDetectionScreen extends StatefulWidget {
  final DetectionResultModel detection;

  const ReviewDetectionScreen({super.key, required this.detection});

  @override
  State<ReviewDetectionScreen> createState() => _ReviewDetectionScreenState();
}

class _ReviewDetectionScreenState extends State<ReviewDetectionScreen> {
  final SupabaseService _supabase = SupabaseService();

  late TextEditingController _noteController;
  String? _selectedSeverity;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.detection.expertNote);
    _selectedSeverity = widget.detection.severityLevel ?? "low";
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveReview() async {
    if (_selectedSeverity == null || _selectedSeverity!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select severity level")));
      return;
    }

    setState(() => _loading = true);

    final data = {
      "is_reviewed": true,
      "expert_note": _noteController.text.trim(),
      "severity": _selectedSeverity,
    };

    try {
      final success = await _supabase.updateDetectionReview(widget.detection.id, data);

      if (success) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("✅ Review saved to cloud")));
        Navigator.pop(context, true); // return true to refresh dashboard
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("❌ Failed to save review")));
      }
    } catch (e) {
      print("Error saving review: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("❌ Error updating cloud")));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.detection;

    return Scaffold(
      appBar: AppBar(title: const Text("Review Detection")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =========================
                  // Image
                  // =========================
                  if (d.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        d.imageUrl!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100),
                      ),
                    ),
                  const SizedBox(height: 12),

                  // =========================
                  // Disease + Confidence
                  // =========================
                  Text("Disease: ${d.diseaseLabel ?? 'Unknown'}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("Confidence: ${d.diseaseConfidence?.toStringAsFixed(2) ?? '-'}"),
                  const SizedBox(height: 8),

                  // =========================
                  // Recommendation
                  // =========================
                  if (d.recommendation != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("AI Recommendation:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(d.recommendation!),
                        const SizedBox(height: 8),
                      ],
                    ),

                  // =========================
                  // Metadata (location, timestamp)
                  // =========================
                  const Text("Metadata:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                      "Captured at: ${DateFormat('yyyy-MM-dd HH:mm').format(d.createdAt)}"),
                  Text(
                      "Location: ${d.latitude != null && d.longitude != null ? '${d.latitude}, ${d.longitude}' : 'Not available'}"),
                  const SizedBox(height: 16),

                  // =========================
                  // Expert Note
                  // =========================
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Expert Note / Advice",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // =========================
                  // Severity Dropdown
                  // =========================
                  DropdownButtonFormField<String>(
                    value: _selectedSeverity,
                    decoration: const InputDecoration(
                      labelText: "Severity Level",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: "low", child: Text("Low 🟢")),
                      DropdownMenuItem(value: "medium", child: Text("Medium 🟡")),
                      DropdownMenuItem(value: "high", child: Text("High 🔴")),
                    ],
                    onChanged: (val) => setState(() => _selectedSeverity = val),
                  ),
                  const SizedBox(height: 20),

                  // =========================
                  // Save Button
                  // =========================
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveReview,
                      child: const Text("Save Review to Cloud"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}