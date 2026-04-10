import 'package:flutter/material.dart';

import '../../models/detection_result_model.dart';
import '../../core/services/sync_service.dart';
import 'review_detection_screen.dart';

class ExpertQueueScreen extends StatefulWidget {
  const ExpertQueueScreen({super.key});

  @override
  State<ExpertQueueScreen> createState() => _ExpertQueueScreenState();
}

class _ExpertQueueScreenState extends State<ExpertQueueScreen> {
  final SyncService _syncService = SyncService();

  List<DetectionResultModel> pending = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadPending();
  }

  /// ===============================
  /// 🔥 LOAD PENDING DETECTIONS
  /// ===============================
  Future<void> loadPending() async {
    setState(() => loading = true);

    try {
      final data = await _syncService.pullExpertDetections();

      setState(() {
        pending = data.where((d) {
          return d.isReviewed == false || d.isReviewed == null;
        }).toList();

        loading = false;
      });

      print("🔥 Pending loaded: ${pending.length}");
    } catch (e) {
      print("❌ Queue load error: $e");

      setState(() {
        pending = [];
        loading = false;
      });
    }
  }

  /// ===============================
  /// 🧠 OPEN REVIEW SCREEN
  /// ===============================
  Future<void> openReview(DetectionResultModel d) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewDetectionScreen(detection: d),
      ),
    );

    if (result == true) {
      await loadPending();
    }
  }

  /// ===============================
  /// 🔄 REFRESH QUEUE
  /// ===============================
  Future<void> refresh() async {
    await loadPending();
  }

  /// ===============================
  /// 📊 SAFE CONFIDENCE FORMATTER
  /// ===============================
  String _formatConfidence(dynamic value) {
    try {
      if (value == null) return "0.00";

      final doubleVal = double.tryParse(value.toString()) ?? 0.0;

      return (doubleVal * 100).toStringAsFixed(2);
    } catch (e) {
      return "0.00";
    }
  }

  /// ===============================
  /// 🖼 IMAGE WIDGET
  /// ===============================
  Widget _buildImage(String? url) {
    if (url == null || url.isEmpty) {
      return const Icon(Icons.image, size: 50);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.broken_image, size: 50),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expert Review Queue"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            onPressed: refresh,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())

          : pending.isEmpty
              ? const Center(
                  child: Text(
                    "🎉 No pending reviews",
                    style: TextStyle(fontSize: 16),
                  ),
                )

              : RefreshIndicator(
                  onRefresh: refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: pending.length,
                    itemBuilder: (_, i) {
                      final d = pending[i];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: _buildImage(d.imageUrl),

                          title: Text(
                            d.diseaseLabel ?? "Unknown",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),

                              Text(
                                "Confidence: ${_formatConfidence(d.diseaseConfidence)}%",
                              ),

                              const SizedBox(height: 2),

                              Text(
                                "Status: Pending Review",
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),

                          trailing: const Icon(Icons.arrow_forward_ios),

                          onTap: () => openReview(d),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}