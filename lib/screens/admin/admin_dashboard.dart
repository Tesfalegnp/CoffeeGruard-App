import 'package:flutter/material.dart';
import '../../core/services/hive_service.dart';

import '../home/hero_home_screen.dart';
import '../detection/history_screen.dart';
import '../expert/expert_dashboard.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _actionButton("Manage Users", Icons.people, Colors.blue),
                _actionButton("Reports", Icons.report, Colors.orange),
                _actionButton("Recommendations", Icons.menu_book, Colors.green),
                _actionButton("Settings", Icons.settings, Colors.red),
              ],
            ),
            const SizedBox(height: 30),
            const Text("Welcome Admin!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  /// ================= DRAWER =================
  Widget _buildDrawer(BuildContext context) {
    final user = HiveService.getCurrentUser();

    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.green.shade700,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.admin_panel_settings,
                    color: Colors.white, size: 40),
                const SizedBox(height: 10),
                const Text("Admin Panel",
                    style: TextStyle(color: Colors.white, fontSize: 18)),
                Text(user?.email ?? "",
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text("Farmer Home"),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HeroHomeScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.dashboard),
                  title: const Text("Expert Dashboard"),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ExpertDashboard()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text("History"),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const HistoryScreen()));
                  },
                ),
              ],
            ),
          ),

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
                  MaterialPageRoute(
                      builder: (_) => const HeroHomeScreen()),
                  (_) => false,
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _actionButton(String t, IconData i, Color c) {
    return Container(
      width: 150,
      height: 90,
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Text(t, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}