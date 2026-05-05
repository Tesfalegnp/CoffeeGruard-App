import 'package:flutter/material.dart';

import '../../../models/user_model.dart';
import '../../detection/history_screen.dart';
import '../../expert/expert_dashboard.dart';
import '../../admin/admin_dashboard.dart';
import '../../auth/login_screen.dart';
import '../../../core/services/hive_service.dart';
import '../../../providers/language_provider.dart';
import 'package:provider/provider.dart';

class RoleDrawer extends StatelessWidget {
  final UserModel? currentUser;

  const RoleDrawer({
    super.key,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final role = currentUser?.role;
    final langProvider = context.watch<LanguageProvider>();
    final isAmharic = langProvider.code == 'am';
    final isOromo = langProvider.code == 'om';
    
    // Localized text
    String historyText = "History";
    String expertDashboardText = "Expert Dashboard";
    String adminDashboardText = "Admin Dashboard";
    String loginText = "Login";
    String logoutText = "Logout";
    String coffeeGuardText = "CoffeeGuard";
    
    if (isAmharic) {
      historyText = "ታሪክ";
      expertDashboardText = "የባለሙያ ዳሽቦርድ";
      adminDashboardText = "የአስተዳዳሪ ዳሽቦርድ";
      loginText = "ግባ";
      logoutText = "ውጣ";
      coffeeGuardText = "ቡናጋርድ";
    } else if (isOromo) {
      historyText = "Seenaa";
      expertDashboardText = "Deezbaardii Ogeessaa";
      adminDashboardText = "Deezbaardii Admin";
      loginText = "Seenuu";
      logoutText = "Ba'uu";
      coffeeGuardText = "BunaGuard";
    }

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
                const Icon(Icons.eco, size: 40, color: Colors.white),
                const SizedBox(height: 10),
                Text(
                  coffeeGuardText,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                if (currentUser != null)
                  Text(
                    currentUser!.email ?? "",
                    style: const TextStyle(color: Colors.white70),
                  ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(historyText),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HistoryScreen(),
                      ),
                    );
                  },
                ),

                if (role == "expert")
                  ListTile(
                    leading: const Icon(Icons.dashboard),
                    title: Text(expertDashboardText),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ExpertDashboard(),
                        ),
                      );
                    },
                  ),

                if (role == "admin")
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings),
                    title: Text(adminDashboardText),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminDashboard(),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: currentUser == null
                ? ElevatedButton.icon(
                    icon: const Icon(Icons.login),
                    label: Text(loginText),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                  )
                : ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    icon: const Icon(Icons.logout),
                    label: Text(logoutText),
                    onPressed: () async {
                      await HiveService.clearUserSession();
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }
}