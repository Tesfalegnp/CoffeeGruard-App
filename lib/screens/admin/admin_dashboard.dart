import 'package:flutter/material.dart';
import '../../core/services/hive_service.dart';

// Admin Screens
import 'user_management_screen.dart';
import 'system_analytics_screen.dart';
import 'model_monitoring_screen.dart';
import 'detection_management_screen.dart';
import 'system_settings_screen.dart';
import 'review_audit_screen.dart';
import 'admin_guide_screen.dart';
import 'admin_profile_screen.dart'; //
import 'feedback_view_admin.dart';

// Navigation targets
import '../auth/login_screen.dart';
import '../home/hero_home_screen.dart';
import '../expert/expert_dashboard.dart';
import '../detection/history_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {

  int totalUsers = 120;
  int totalDetections = 540;
  int pendingReviews = 34;
  int accuracy = 87;

  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(
        title: const Text("Admin Control Center"),
        backgroundColor: Colors.green,
        actions: [
          // ✅ ADDED PROFILE ICON
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              _nav(const AdminProfileScreen());
            },
          ),

          IconButton(
            icon: const Icon(Icons.menu_book),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminGuideScreen(),
                ),
              );
            },
          )
        ],
      ),

      body: FadeTransition(
        opacity: _fade,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green),
              ),
              child: const Text(
                "💡 Admin System Active: Monitor AI, experts, and system health regularly for best performance.",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),

            const SizedBox(height: 15),

            // ================= ACTION GRID =================
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [

                _btn("Users", Icons.people, Colors.blue, () {
                  _nav(const UserManagementScreen());
                }),

                _btn("Analytics", Icons.bar_chart, Colors.purple, () {
                  _nav(const SystemAnalyticsScreen());
                }),

                _btn("Model", Icons.memory, Colors.red, () {
                  _nav(const ModelMonitoringScreen());
                }),

                _btn("Detections", Icons.dataset, Colors.orange, () {
                  _nav(const DetectionManagementScreen());
                }),

                _btn("Settings", Icons.settings, Colors.grey, () {
                  _nav(const SystemSettingsScreen());
                }),

                _btn("Audit", Icons.verified, Colors.teal, () {
                  _nav(const ReviewAuditScreen());
                }),
                _btn("Feedback", Icons.feedback, Colors.green, () {
                  _nav(const FeedbackViewAdmin());
                }),
                _btn("Guide", Icons.menu_book, Colors.green, () {
                  _nav(const AdminGuideScreen());
                }),

                _btn("Farmer Home", Icons.home, Colors.brown, () {
                  _nav(const HeroHomeScreen());
                }),

                _btn("Expert Panel", Icons.dashboard, Colors.deepPurple, () {
                  _nav(const ExpertDashboard());
                }),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              "📊 System Overview",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(child: _card("Users", totalUsers, Colors.blue)),
                Expanded(child: _card("Detections", totalDetections, Colors.green)),
                Expanded(child: _card("Pending", pendingReviews, Colors.orange)),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(child: _card("Accuracy %", accuracy, Colors.purple)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= NAV =================
  void _nav(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
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

  // ================= DRAWER =================
  Widget _buildDrawer() {
    final user = HiveService.getCurrentUser();

    return Drawer(
      child: Column(
        children: [

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.green,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.admin_panel_settings,
                    color: Colors.white, size: 40),
                const SizedBox(height: 10),
                const Text("Admin Control Center",
                    style: TextStyle(color: Colors.white)),
                Text(user?.email ?? "",
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),

          const SizedBox(height: 10),

          _sectionTitle("MANAGEMENT"),
          _tile(Icons.people, "Users", () => _nav(const UserManagementScreen())),
          _tile(Icons.dataset, "Detections", () => _nav(const DetectionManagementScreen())),
          _tile(Icons.verified, "Review Audit", () => _nav(const ReviewAuditScreen())),

          _sectionTitle("INSIGHTS"),
          _tile(Icons.bar_chart, "Analytics", () => _nav(const SystemAnalyticsScreen())),
          _tile(Icons.memory, "Model Monitoring", () => _nav(const ModelMonitoringScreen())),

          _sectionTitle("SYSTEM"),
          _tile(Icons.settings, "Settings", () => _nav(const SystemSettingsScreen())),
          _tile(Icons.menu_book, "Admin Guide", () => _nav(const AdminGuideScreen())),

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
              onPressed: () async {
                await HiveService.clearUserSession();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _tile(IconData i, String t, VoidCallback tap) {
    return ListTile(
      leading: Icon(i, color: Colors.green),
      title: Text(t),
      onTap: tap,
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