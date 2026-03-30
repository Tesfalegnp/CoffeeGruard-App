import 'package:flutter/material.dart';
import '../../core/services/sync_service.dart';
import '../../models/detection_result_model.dart';
import 'review_detection_screen.dart';
import 'manage_recommendations_screen.dart'; // ✅ new

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
      final cloudData = await _syncService.pullExpertDetections();

      setState(() {
        _allDetections = cloudData;
        _loading = false;
      });
    } catch (e) {
      print("❌ Load error: $e");
      setState(() => _loading = false);
    }
  }

  int get total => _allDetections.length;
  int get healthy =>
      _allDetections.where((d) => d.diseaseLabel == "Healthy").length;
  int get diseased =>
      _allDetections.where((d) =>
          d.diseaseLabel != null &&
          d.diseaseLabel != "Healthy").length;
  int get highSeverity =>
      _allDetections.where((d) => d.severityLevel == "high").length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expert Dashboard"),
        backgroundColor: Colors.green.shade700,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDetections,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ======================= DASHBOARD BUTTONS =======================
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _actionButton(
                        title: "Review Detections",
                        icon: Icons.task_alt,
                        color: Colors.blue,
                        onTap: () {},
                      ),
                      _actionButton(
                        title: "Manage Recommendations",
                        icon: Icons.menu_book,
                        color: Colors.orange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const ManageRecommendationsScreen(),
                            ),
                          );
                        },
                      ),
                      _actionButton(
                        title: "Sync Data",
                        icon: Icons.sync,
                        color: Colors.green,
                        onTap: () async {
                          setState(() => _loading = true);
                          await _syncService.fullSync();
                          await _loadDetections();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("✅ Data synced successfully")),
                          );
                        },
                      ),
                      _actionButton(
                        title: "Analytics",
                        icon: Icons.bar_chart,
                        color: Colors.purple,
                        onTap: () {
                          // TODO: add future Analytics page
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// 📊 STATS GRID
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 1.4,
                    children: [
                      _card("Total", total, Colors.blue),
                      _card("Healthy", healthy, Colors.green),
                      _card("Diseased", diseased, Colors.orange),
                      _card("High Risk", highSeverity, Colors.red),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Recent Detections",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  ..._allDetections.map(_tile)
                ],
              ),
            ),
    );
  }

  Widget _actionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 90,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color.withOpacity(0.4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(2, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }

  Widget _card(String t, int v, Color c) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [c.withOpacity(0.7), c.withOpacity(0.3)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(t,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text("$v",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile(DetectionResultModel d) {
    Color severityColor;
    switch (d.severityLevel) {
      case "high":
        severityColor = Colors.red;
        break;
      case "medium":
        severityColor = Colors.orange;
        break;
      default:
        severityColor = Colors.green;
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: d.imageUrl != null
              ? Image.network(d.imageUrl!, width: 55, height: 55, fit: BoxFit.cover)
              : const Icon(Icons.image),
        ),
        title: Text(
          d.diseaseLabel ?? "Unknown",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    d.severityLevel ?? "low",
                    style: TextStyle(
                        color: severityColor, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  d.isReviewed ? "Reviewed" : "Pending",
                  style: TextStyle(
                      color: d.isReviewed ? Colors.green : Colors.orange),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReviewDetectionScreen(detection: d),
            ),
          ).then((result) async {
            if (result == true) {
              await _loadDetections();
            }
          });
        },
      ),
    );
  }
}