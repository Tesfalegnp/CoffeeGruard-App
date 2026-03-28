import 'package:flutter/material.dart';
import '../../core/services/sync_service.dart';
import '../../models/detection_result_model.dart';
import '../expert/review_detection_screen.dart';

class ExpertDashboard extends StatefulWidget {
  const ExpertDashboard({super.key});

  @override
  State<ExpertDashboard> createState() => _ExpertDashboardState();
}

class _ExpertDashboardState extends State<ExpertDashboard> {
  final SyncService _syncService = SyncService();

  List<DetectionResultModel> _allDetections = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDetections();
  }

  Future<void> _loadDetections() async {
    setState(() => _loading = true);

    try {
      // Directly fetch from Supabase (cloud only)
      final cloudData = await _syncService.pullExpertDetections();

      setState(() {
        _allDetections = cloudData;
        _loading = false;
      });
    } catch (e) {
      print("❌ Failed to load cloud detections: $e");
      setState(() => _loading = false);
    }
  }

  // =========================
  // Stats Cards
  // =========================
  int get total => _allDetections.length;
  int get healthy =>
      _allDetections.where((d) => d.diseaseLabel == "Healthy").length;
  int get diseased =>
      _allDetections.where((d) =>
          d.diseaseLabel != null && d.diseaseLabel != "Healthy").length;
  int get highSeverity =>
      _allDetections.where((d) => d.severityLevel == "high").length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expert Dashboard"),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDetections,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCard("Total", total.toString(), Colors.blue),
                        _buildCard("Healthy", healthy.toString(), Colors.green),
                        _buildCard("Diseased", diseased.toString(), Colors.orange),
                        _buildCard("High Risk", highSeverity.toString(), Colors.red),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Recent Detections",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ..._allDetections
                        .reversed
                        .take(10)
                        .map((d) => _buildDetectionTile(d))
                        .toList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: color, fontSize: 16)),
              const SizedBox(height: 8),
              Text(value,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 22)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetectionTile(DetectionResultModel d) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: d.imageUrl != null
            ? Image.network(d.imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
            : const Icon(Icons.image, size: 50),
        title: Text(d.diseaseLabel ?? "Unknown"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (d.severityLevel != null) Text("Severity: ${d.severityLevel}"),
            if (d.isReviewed)
              const Text("Reviewed ✅")
            else
              const Text("Pending review ⏳"),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReviewDetectionScreen(detection: d),
            ),
          ).then((_) => _loadDetections()); // refresh after review
        },
      ),
    );
  }
}