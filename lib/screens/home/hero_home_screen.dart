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
        title: const Text("CoffeeGuard"),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
      ),

      body: Column(
        children: [

          /// 🌿 HEADER (MODERN)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade700,
                  Colors.green.shade400
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [

                Image.asset(
                  'assets/icons/app_icon.png',
                  height: 80,
                ),

                const SizedBox(height: 10),

                const Text(
                  "CoffeeGuard",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  "AI-powered coffee disease detection",
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          /// 🚀 MAIN BUTTON (SMART)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () => _showImageSource(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                "Scan Coffee Leaf",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// 💡 TIP CARD
          Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    Text(
                      "💡 Tips",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "• Use clear images\n"
                      "• Avoid shadows\n"
                      "• Focus on one leaf\n"
                      "• Use natural light",
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  /// 📸 SMART PICKER (BOTTOM SHEET)
  void _showImageSource(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const Text(
                "Select Image Source",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CaptureScreen(),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CaptureScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// 📂 DRAWER
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [

          DrawerHeader(
            decoration: BoxDecoration(color: Colors.green.shade700),
            child: const Column(
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

          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () => Navigator.pop(context),
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

          ListTile(
            leading: const Icon(Icons.login),
            title: const Text("Expert / Admin"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}