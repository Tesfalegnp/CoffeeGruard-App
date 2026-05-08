// ============================================================
// FILE: lib/screens/home/widgets/role_drawer.dart
// FULL FIXED + SAFE FOOTER + AUTO HIVE UI REFRESH
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../models/user_model.dart';
import '../../../providers/language_provider.dart';
import '../../../core/services/hive_service.dart';

import '../../detection/history_screen.dart';
import '../../expert/expert_dashboard.dart';
import '../../admin/admin_dashboard.dart';
import '../../auth/login_screen.dart';

import '../../public/daily_tips_screen.dart';
import '../../public/feedback_screen.dart';
import '../../public/about_developer_screen.dart';
import '../../public/help_center_screen.dart';
import '../../profile/user_profile_screen.dart';

class RoleDrawer extends StatelessWidget {
  const RoleDrawer({super.key});

  String tr(String en, String am, String om, String code) {
    if (code == "am") return am;
    if (code == "om") return om;
    return en;
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final code = lang.code;

    final box = HiveService.getSessionBox();

    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, _, __) {
        final UserModel? currentUser =
            box.get(HiveService.sessionKey);

        final role = currentUser?.role;

        return SafeArea(
          child: Drawer(
            child: Column(
              children: [
                // ================= HEADER =================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
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

                // ================= MENU =================
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _tile(
                        context,
                        icon: Icons.history,
                        title: tr("History", "ታሪክ", "Seenaa", code),
                        page: const HistoryScreen(),
                      ),
                      _tile(
                        context,
                        icon: Icons.lightbulb,
                        title: tr("Daily Tips", "የዕለት ምክሮች", "Gorsa Guyyaa", code),
                        page: const DailyTipsScreen(),
                      ),
                      _tile(
                        context,
                        icon: Icons.support_agent,
                        title: tr("Help Center", "የእርዳታ ማዕከል", "Gargaarsa", code),
                        page: const HelpCenterScreen(),
                      ),
                      _tile(
                        context,
                        icon: Icons.feedback,
                        title: tr("Feedback", "አስተያየት", "Yaada", code),
                        page: const FeedbackScreen(),
                      ),
                      _tile(
                        context,
                        icon: Icons.person,
                        title: tr("About Developer", "ስለ አበልጻጊው", "Waa'ee Developer", code),
                        page: const AboutDeveloperScreen(),
                      ),

                      const Divider(),
                      if (currentUser != null)
                        _tile(
                          context,
                          icon: Icons.person_outline,
                          title: tr("Profile", "መገለጫ", "Profaayilii", code),
                          page: const UserProfileScreen(),
                        ),
                      if (role == "expert")
                        _tile(
                          context,
                          icon: Icons.dashboard,
                          title: tr("Expert Dashboard", "የባለሙያ ዳሽቦርድ", "Dashboordii Ogeessaa", code),
                          page: const ExpertDashboard(),
                        ),

                      if (role == "admin")
                        _tile(
                          context,
                          icon: Icons.admin_panel_settings,
                          title: tr("Admin Dashboard", "የአስተዳዳሪ ዳሽቦርድ", "Dashboordii Admin", code),
                          page: const AdminDashboard(),
                        ),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),

                // ================= FOOTER BUTTON =================
                SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: currentUser == null
                          ? ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.login),
                              label: Text(
                                tr("Login", "ግባ", "Seeni", code),
                              ),
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
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.logout),
                              label: Text(
                                tr("Logout", "ውጣ", "Ba'i", code),
                              ),
                              onPressed: () async {
                                await HiveService.clearUserSession();

                                if (!context.mounted) return;

                                Navigator.pop(context);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Logged out successfully"),
                                    backgroundColor: Colors.green,
                                  ),
                                );

                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              },
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget page,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
    );
  }
}