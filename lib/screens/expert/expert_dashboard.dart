import 'package:flutter/material.dart';
import '../../core/services/sync_service.dart';
import '../../models/detection_result_model.dart';

import 'review_detection_screen.dart';
import 'manage_recommendations_screen.dart';
import 'analytics_screen.dart';
import 'model_performance_screen.dart';
import 'image_gallery_screen.dart';

import '../auth/login_screen.dart';

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
      final data = await _syncService.pullExpertDetections();
      setState(() {
        _allDetections = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  int get total => _allDetections.length;
  int get reviewed => _allDetections.where((d) => d.isReviewed).length;
  int get pending => _allDetections.where((d) => !d.isReviewed).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
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

                  /// 🔘 ACTION BUTTONS
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _btn("Review", Icons.task, Colors.blue, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReviewDetectionScreen(
                              detection: _allDetections.isNotEmpty
                                  ? _allDetections.first
                                  : throw Exception("No detection available"),
                            ),
                          ),
                        );
                      }),

                      _btn("Recommendations", Icons.menu_book, Colors.orange,
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const ManageRecommendationsScreen(),
                          ),
                        );
                      }),

                      _btn("Analytics", Icons.bar_chart, Colors.purple, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AnalyticsScreen(),
                          ),
                        );
                      }),

                      _btn("Model Check", Icons.memory, Colors.red, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const ModelPerformanceScreen(),
                          ),
                        );
                      }),

                      _btn("Gallery", Icons.photo, Colors.teal, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ImageGalleryScreen(),
                          ),
                        );
                      }),

                      _btn("Sync", Icons.sync, Colors.green, () async {
                        await _syncService.fullSync();
                        await _loadDetections();
                      }),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// 📊 KPI
                  Row(
                    children: [
                      Expanded(child: _card("Total", total, Colors.blue)),
                      Expanded(child: _card("Reviewed", reviewed, Colors.green)),
                      Expanded(child: _card("Pending", pending, Colors.orange)),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _btn(String t, IconData i, Color c, VoidCallback tap) {
    return GestureDetector(
      onTap: tap,
      child: Container(
        width: 150,
        height: 90,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [c.withOpacity(0.7), c.withOpacity(0.4)],
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(i, color: Colors.white),
            const SizedBox(height: 5),
            Text(t,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }

  Widget _card(String t, int v, Color c) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text(t),
            Text("$v",
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  /// 🔐 SAFE DRAWER (NO ADMIN ACCESS)
  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.green,
            child: const Text(
              "Expert Panel",
              style: TextStyle(color: Colors.white),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text("Dashboard"),
            onTap: () => Navigator.pop(context),
          ),

          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text("Image Gallery"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ImageGalleryScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text("Analytics"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AnalyticsScreen(),
                ),
              );
            },
          ),

          const Spacer(),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}