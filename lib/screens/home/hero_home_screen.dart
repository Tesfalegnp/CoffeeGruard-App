import 'package:flutter/material.dart';
import '../detection/capture_screen.dart';
import '../detection/history_screen.dart';

class HeroHomeScreen extends StatelessWidget {
  const HeroHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),

      appBar: AppBar(
        title: const Text("CoffeeGuard ☕🌿"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// 🌿 LOGO
            Image.asset(
              'assets/icons/app_icon.png',
              height: 100,
            ),

            const SizedBox(height: 10),

            /// 🏷 APP NAME
            const Text(
              "CoffeeGuard",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            /// 📖 DESCRIPTION
            const Text(
              "Detect coffee leaf diseases instantly using AI.\nWorks offline & syncs automatically.",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            /// 📸 ACTION BUTTONS
            _buildActionButton(
              context,
              icon: Icons.camera_alt,
              title: "Capture Image",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CaptureScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 15),

            _buildActionButton(
              context,
              icon: Icons.photo,
              title: "Upload from Gallery",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CaptureScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 15),

            _buildActionButton(
              context,
              icon: Icons.history,
              title: "View History",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HistoryScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            /// 💡 RECOMMENDATION / INFO SECTION
            _buildInfoCard(),

          ],
        ),
      ),
    );
  }

  /// 🔘 Reusable Button
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// 💡 Info Card
  Widget _buildInfoCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            Text(
              "🌱 Tips for Better Detection",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "- Capture clear leaf images\n"
              "- Avoid shadows\n"
              "- Focus on one leaf\n"
              "- Use natural light",
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }

  /// 📂 Drawer Menu
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [

          /// 🔰 HEADER
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.green),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.eco, size: 40, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  "CoffeeGuard",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),

          /// 📂 MENU ITEMS
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text("Capture"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CaptureScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("History"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HistoryScreen(),
                ),
              );
            },
          ),

          const Divider(),

          /// 🔐 FUTURE LOGIN (Expert/Admin)
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text("Expert / Admin Login"),
            onTap: () {
              // TODO: implement later
            },
          ),
        ],
      ),
    );
  }
}