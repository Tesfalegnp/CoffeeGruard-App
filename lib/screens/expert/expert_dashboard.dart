import 'package:flutter/material.dart';

import '../../core/services/sync_service.dart';
import '../../models/detection_result_model.dart';

import 'expert_queue_screen.dart';
import 'manage_recommendations_screen.dart';
import 'analytics_screen.dart';
import 'model_performance_screen.dart';
import 'image_gallery_screen.dart';
import 'expert_settings_screen.dart';
import 'expert_guide_screen.dart';
import 'expert_profile_screen.dart';
import '../auth/login_screen.dart';

class ExpertDashboard extends StatefulWidget {
  const ExpertDashboard({super.key});

  @override
  State<ExpertDashboard> createState() => _ExpertDashboardState();
}

class _ExpertDashboardState extends State<ExpertDashboard>
    with SingleTickerProviderStateMixin {

  final SyncService _syncService = SyncService();

  List<DetectionResultModel> _allDetections = [];
  bool _loading = true;

  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _loadDetections();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadDetections() async {
    setState(() => _loading = true);

    try {
      final data = await _syncService.refreshExpertQueue();

      setState(() {
        _allDetections = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  List<DetectionResultModel> get pending =>
      _allDetections.where((d) => d.isReviewed != true).toList();

  List<DetectionResultModel> get reviewed =>
      _allDetections.where((d) => d.isReviewed == true).toList();

  List<DetectionResultModel> get rejected =>
      _allDetections.where((d) =>
          d.isReviewed == true &&
          (d.expertNote?.toLowerCase().contains("reject") ?? false))
          .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(
        title: const Text("Expert Control Center"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ExpertGuideScreen(),
                ),
              );
            },
          )
        ],
      ),

      body: FadeTransition(
        opacity: _fade,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadDetections,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [

                    // ================= HEADER =================
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green),
                      ),
                      child: const Text(
                        "💡 Expert System Active: Review AI detections, validate diseases, and improve model accuracy.",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ================= ACTION GRID =================
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                          _btn("Profile", Icons.person, Colors.indigo, () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ExpertProfileScreen(),
                                ),
                              );
                            }),
                        _btn("Queue", Icons.task, Colors.blue, () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const ExpertQueueScreen()))
                              .then((_) => _loadDetections());
                        }),

                        _btn("Analytics", Icons.bar_chart, Colors.purple, () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const AnalyticsScreen()));
                        }),

                        _btn("Model", Icons.memory, Colors.red, () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const ModelPerformanceScreen()));
                        }),

                        _btn("Gallery", Icons.photo, Colors.teal, () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const ImageGalleryScreen()));
                        }),

                        _btn("Recommendations", Icons.recommend, Colors.orange, () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const ManageRecommendationsScreen()));
                        }),

                        _btn("Sync", Icons.sync, Colors.green, () async {
                          await _syncService.fullSync();
                          await _loadDetections();
                        }),

                        _btn("Settings", Icons.settings, Colors.grey, () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const ExpertSettingsScreen()));
                        }),

                        _btn("Guide", Icons.menu_book, Colors.green, () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const ExpertGuideScreen()));
                        }),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "📊 Expert Overview",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(child: _card("Total", _allDetections.length, Colors.blue)),
                        Expanded(child: _card("Reviewed", reviewed.length, Colors.green)),
                        Expanded(child: _card("Pending", pending.length, Colors.orange)),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(child: _card("Rejected", rejected.length, Colors.red)),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // ================= BUTTON =================
  Widget _btn(String t, IconData i, Color c, VoidCallback tap) {
    return GestureDetector(
      onTap: tap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 150,
        height: 92,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [c.withOpacity(0.85), c.withOpacity(0.45)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: c.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(i, color: Colors.white, size: 26),
            const SizedBox(height: 6),
            Text(
              t,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }

  // ================= CARD =================
  Widget _card(String t, int v, Color c) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [c.withOpacity(0.15), Colors.white],
          ),
        ),
        child: Column(
          children: [
            Text(t, style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 5),
            Text(
              "$v",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= DRAWER (UPDATED ONLY) =================
  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.green,
            child: const Text(
              "Expert Control Center",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),

          const SizedBox(height: 10),

          _sectionTitle("WORK AREA"),

          ListTile(
            leading: const Icon(Icons.dashboard, color: Colors.green),
            title: const Text("Dashboard"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.indigo),
            title: const Text("Profile"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ExpertProfileScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.task, color: Colors.blue),
            title: const Text("Queue"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ExpertQueueScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.recommend, color: Colors.orange),
            title: const Text("Recommendations"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManageRecommendationsScreen(),
                ),
              );
            },
          ),

          _sectionTitle("INSIGHTS"),

          ListTile(
            leading: const Icon(Icons.bar_chart, color: Colors.purple),
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

          ListTile(
            leading: const Icon(Icons.memory, color: Colors.red),
            title: const Text("Model Performance"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ModelPerformanceScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.photo, color: Colors.teal),
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

          _sectionTitle("SYSTEM"),

          ListTile(
            leading: const Icon(Icons.sync, color: Colors.green),
            title: const Text("Sync"),
            onTap: () async {
              await _syncService.fullSync();
              await _loadDetections();
            },
          ),

          ListTile(
            leading: const Icon(Icons.settings, color: Colors.grey),
            title: const Text("Settings"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ExpertSettingsScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.menu_book, color: Colors.green),
            title: const Text("Guide"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ExpertGuideScreen(),
                ),
              );
            },
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 45),
              ),
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        t,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}