// ============================================================
// FILE: lib/screens/home/widgets/role_drawer.dart
// FULL UPGRADED DRAWER WITH NEW PUBLIC FEATURES
// Replace your old role_drawer.dart with this code
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/user_model.dart';
import '../../../providers/language_provider.dart';
import '../../../core/services/hive_service.dart';

import '../../detection/history_screen.dart';
import '../../expert/expert_dashboard.dart';
import '../../admin/admin_dashboard.dart';
import '../../auth/login_screen.dart';

// NEW PUBLIC SCREENS
import '../../public/daily_tips_screen.dart';
import '../../public/feedback_screen.dart';
import '../../public/about_developer_screen.dart';
import '../../public/help_center_screen.dart';

class RoleDrawer extends StatelessWidget {
  final UserModel? currentUser;

  const RoleDrawer({
    super.key,
    required this.currentUser,
  });

  String tr(
    String en,
    String am,
    String om,
    String code,
  ) {
    if (code == "am") return am;
    if (code == "om") return om;
    return en;
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final code = lang.code;
    final role = currentUser?.role;

    return Drawer(
      child: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade800,
                  Colors.green.shade600,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.eco,
                  color: Colors.white,
                  size: 42,
                ),
                const SizedBox(height: 10),
                Text(
                  tr(
                    "CoffeeGuard",
                    "ቡናጋርድ",
                    "BunaGuard",
                    code,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  currentUser?.email ?? "",
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // ====================================
                // HISTORY
                // ====================================
                _tile(
                  context,
                  icon: Icons.history,
                  title: tr(
                    "History",
                    "ታሪክ",
                    "Seenaa",
                    code,
                  ),
                  page: const HistoryScreen(),
                ),

                // ====================================
                // DAILY TIPS
                // ====================================
                _tile(
                  context,
                  icon: Icons.lightbulb,
                  title: tr(
                    "Daily Tips",
                    "የዕለት ምክሮች",
                    "Gorsa Guyyaa",
                    code,
                  ),
                  page: const DailyTipsScreen(),
                ),

                // ====================================
                // HELP CENTER
                // ====================================
                _tile(
                  context,
                  icon: Icons.support_agent,
                  title: tr(
                    "Help Center",
                    "የእርዳታ ማዕከል",
                    "Gargaarsa",
                    code,
                  ),
                  page: const HelpCenterScreen(),
                ),

                // ====================================
                // FEEDBACK
                // ====================================
                _tile(
                  context,
                  icon: Icons.feedback,
                  title: tr(
                    "Feedback",
                    "አስተያየት",
                    "Yaada",
                    code,
                  ),
                  page: const FeedbackScreen(),
                ),

                // ====================================
                // ABOUT DEV
                // ====================================
                _tile(
                  context,
                  icon: Icons.person,
                  title: tr(
                    "About Developer",
                    "ስለ አበልጻጊው",
                    "Waa'ee Developer",
                    code,
                  ),
                  page: const AboutDeveloperScreen(),
                ),

                const Divider(),

                // ====================================
                // EXPERT
                // ====================================
                if (role == "expert")
                  _tile(
                    context,
                    icon: Icons.dashboard,
                    title: tr(
                      "Expert Dashboard",
                      "የባለሙያ ዳሽቦርድ",
                      "Dashboordii Ogeessaa",
                      code,
                    ),
                    page: const ExpertDashboard(),
                  ),

                // ====================================
                // ADMIN
                // ====================================
                if (role == "admin")
                  _tile(
                    context,
                    icon: Icons.admin_panel_settings,
                    title: tr(
                      "Admin Dashboard",
                      "የአስተዳዳሪ ዳሽቦርድ",
                      "Dashboordii Admin",
                      code,
                    ),
                    page: const AdminDashboard(),
                  ),
              ],
            ),
          ),

          // LOGIN / LOGOUT
          Padding(
            padding: const EdgeInsets.all(14),
            child: currentUser == null
                ? ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize:
                          const Size(double.infinity, 48),
                      backgroundColor:
                          Colors.green.shade700,
                    ),
                    icon: const Icon(Icons.login),
                    label: Text(
                      tr(
                        "Login",
                        "ግባ",
                        "Seeni",
                        code,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const LoginScreen(),
                        ),
                      );
                    },
                  )
                : ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize:
                          const Size(double.infinity, 48),
                      backgroundColor: Colors.red,
                    ),
                    icon: const Icon(Icons.logout),
                    label: Text(
                      tr(
                        "Logout",
                        "ውጣ",
                        "Ba'i",
                        code,
                      ),
                    ),
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

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget page,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.green.shade700,
      ),
      title: Text(title),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => page,
          ),
        );
      },
    );
  }
}