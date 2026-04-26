import 'package:flutter/material.dart';

class AdminGuideScreen extends StatelessWidget {
  const AdminGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin System Guide"),
        backgroundColor: Colors.green,
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ================= HEADER =================
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green),
            ),
            child: const Text(
              "📘 Welcome Admin\n"
              "This guide helps you understand how to control and monitor the CoffeeGuard system effectively.",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 20),

          _sectionTitle("CORE MODULES"),

          const SizedBox(height: 10),

          _card(
            icon: Icons.people,
            title: "User Management",
            desc:
                "Manage farmers, experts, and admins.\n"
                "✔ Activate / deactivate users\n"
                "✔ Assign roles (farmer / expert / admin)\n"
                "✔ Monitor user activity",
          ),

          _card(
            icon: Icons.bar_chart,
            title: "Analytics Dashboard",
            desc:
                "Understand system performance.\n"
                "✔ Total detections\n"
                "✔ Disease trends\n"
                "✔ User growth statistics",
          ),

          _card(
            icon: Icons.memory,
            title: "Model Monitoring",
            desc:
                "Track AI model performance.\n"
                "✔ Accuracy tracking\n"
                "✔ Model evaluation\n"
                "✔ Detect weak predictions",
          ),

          _card(
            icon: Icons.dataset,
            title: "Detections Control",
            desc:
                "Full control over AI detections.\n"
                "✔ View all detection records\n"
                "✔ Edit or delete entries\n"
                "✔ Validate AI outputs",
          ),

          _card(
            icon: Icons.verified,
            title: "Review Audit",
            desc:
                "Monitor expert decisions.\n"
                "✔ Check expert reviews\n"
                "✔ Flag incorrect decisions\n"
                "✔ Ensure data quality",
          ),

          _card(
            icon: Icons.settings,
            title: "System Settings",
            desc:
                "Control system behavior.\n"
                "✔ Configure thresholds\n"
                "✔ Manage system rules\n"
                "✔ Optimize performance",
          ),

          const SizedBox(height: 20),

          // ================= FOOTER NOTE =================
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange),
            ),
            child: const Text(
              "💡 Tip: Always monitor Review Audit + Model Accuracy together to ensure system reliability.",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ================= SECTION TITLE =================
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.green,
      ),
    );
  }

  // ================= GUIDE CARD =================
  Widget _card({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Icon(icon, color: Colors.green, size: 28),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}