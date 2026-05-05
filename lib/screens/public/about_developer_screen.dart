// ==========================================================
// FILE: lib/screens/public/about_developer_screen.dart
// ABOUT DEVELOPER (TEAM PAGE)
// 1 GIRL + 4 MEN (PLACEHOLDER PROFILES)
// CONTACT POPUP INCLUDED
// ==========================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';

class AboutDeveloperScreen extends StatelessWidget {
  const AboutDeveloperScreen({super.key});

  String tr(String en, String am, String om, String code) {
    if (code == "am") return am;
    if (code == "om") return om;
    return en;
  }

  void showContact(BuildContext context, Developer dev, String code) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 320,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dev.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              _infoRow("📞 Phone", dev.phone),
              _infoRow("📧 Email", dev.email),
              _infoRow("💬 Telegram", dev.telegram),
              _infoRow("🌐 Portfolio", dev.portfolio),
              _infoRow("🧠 Role", dev.role),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(tr("Close", "ዝጋ", "Cufi", code)),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$title: ",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final code = lang.code;

    final devs = [
      Developer(
        name: "Sara (UI/UX Designer)",
        role: "UI/UX Designer",
        phone: "+251 900 000 001",
        email: "sara@coffeeguard.app",
        telegram: "@sara_uiux",
        portfolio: "sara.design",
        image: "assets/dev1.png",
      ),
      Developer(
        name: "Abel (AI Engineer)",
        role: "AI Engineer",
        phone: "+251 900 000 002",
        email: "abel@coffeeguard.app",
        telegram: "@abel_ai",
        portfolio: "abel-ai.dev",
        image: "assets/dev2.png",
      ),
      Developer(
        name: "Daniel (Backend Dev)",
        role: "Backend Developer",
        phone: "+251 900 000 003",
        email: "daniel@coffeeguard.app",
        telegram: "@dan_backend",
        portfolio: "daniel.dev",
        image: "assets/dev3.png",
      ),
      Developer(
        name: "Yosef (Mobile Dev)",
        role: "Flutter Developer",
        phone: "+251 900 000 004",
        email: "yosef@coffeeguard.app",
        telegram: "@yosef_flutter",
        portfolio: "yosef.dev",
        image: "assets/dev4.png",
      ),
      Developer(
        name: "Mekdes (Research)",
        role: "Agriculture Research",
        phone: "+251 900 000 005",
        email: "mekdes@coffeeguard.app",
        telegram: "@mekdes_agri",
        portfolio: "mekdes.agri",
        image: "assets/dev5.png",
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: Text(
          tr("About Developers", "ስለ አበልጻጊዎች", "Waa'ee Developer", code),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Icon(Icons.groups, size: 70, color: Colors.green),
            const SizedBox(height: 10),

            Text(
              tr(
                "CoffeeGuard Development Team",
                "የCoffeeGuard ልማት ቡድን",
                "Garee Guddina CoffeeGuard",
                code,
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: devs.length,
                itemBuilder: (context, index) {
                  final dev = devs[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.shade100,
                        child: const Icon(Icons.person, color: Colors.green),
                      ),
                      title: Text(dev.name),
                      subtitle: Text(dev.role),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () =>
                            showContact(context, dev, code),
                        child: Text(
                          tr("Contact", "አግኙ", "Quunnamtii", code),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// MODEL (LOCAL)
// ==========================================================

class Developer {
  final String name;
  final String role;
  final String phone;
  final String email;
  final String telegram;
  final String portfolio;
  final String image;

  Developer({
    required this.name,
    required this.role,
    required this.phone,
    required this.email,
    required this.telegram,
    required this.portfolio,
    required this.image,
  });
}