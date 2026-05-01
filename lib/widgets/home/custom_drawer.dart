import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/services/language_service.dart';
import '../../core/services/hive_service.dart';
import '../../models/user_model.dart';
import '../../screens/detection/history_screen.dart';
import '../../screens/expert/expert_dashboard.dart';
import '../../screens/admin/admin_dashboard.dart';
import '../../screens/auth/login_screen.dart';

class CustomDrawer extends StatelessWidget {
  final bool isDarkMode;
  final UserModel? currentUser;
  final VoidCallback onLanguageToggle;
  final VoidCallback onThemeToggle;
  final VoidCallback onUserUpdate;
  
  const CustomDrawer({
    super.key,
    required this.isDarkMode,
    this.currentUser,
    required this.onLanguageToggle,
    required this.onThemeToggle,
    required this.onUserUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageService>(context);
    final role = currentUser?.role;
    
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [Colors.grey.shade900, Colors.grey.shade800]
                : [Colors.green.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildDrawerHeader(context, lang),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  children: [
                    _buildDrawerItem(
                      icon: Icons.history,
                      title: lang.translate("History", "ታሪክ", "Seenaa"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HistoryScreen()),
                        );
                      },
                      isDarkMode: isDarkMode,
                    ),
                    _buildDrawerItem(
                      icon: Icons.settings,
                      title: lang.translate("Settings", "ቅንብሮች", "Qindoomina"),
                      onTap: () => _showSettingsDialog(context, lang),
                      isDarkMode: isDarkMode,
                    ),
                    _buildDrawerItem(
                      icon: Icons.language,
                      title: lang.translate("Language", "ቋንቋ", "Afaan"),
                      trailing: Switch(
                        value: lang.isAmharic,
                        onChanged: (val) => onLanguageToggle(),
                        activeColor: Colors.green,
                      ),
                      isDarkMode: isDarkMode,
                    ),
                    _buildDrawerItem(
                      icon: isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      title: lang.translate("Dark Mode", "ጨለማ ሁነታ", "Haala Dukkan"),
                      trailing: Switch(
                        value: isDarkMode,
                        onChanged: (val) => onThemeToggle(),
                        activeColor: Colors.green,
                      ),
                      isDarkMode: isDarkMode,
                    ),
                    if (role == "expert")
                      _buildDrawerItem(
                        icon: Icons.dashboard_customize,
                        title: lang.translate("Expert Dashboard", "የባለሙያ ዳሽቦርድ", "Daashboordii Ogeessa"),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ExpertDashboard()),
                          );
                        },
                        isDarkMode: isDarkMode,
                      ),
                    if (role == "admin")
                      _buildDrawerItem(
                        icon: Icons.admin_panel_settings,
                        title: lang.translate("Admin Dashboard", "አስተዳዳሪ ዳሽቦርድ", "Daashboordii Admii"),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AdminDashboard()),
                          );
                        },
                        isDarkMode: isDarkMode,
                      ),
                    const Divider(height: 2, thickness: 1),
                    _buildDrawerItem(
                      icon: Icons.info_outline,
                      title: lang.translate("About", "ስለ እኛ", "Waa'ee"),
                      onTap: () => _showAboutDialog(context, lang),
                      isDarkMode: isDarkMode,
                    ),
                    _buildDrawerItem(
                      icon: Icons.help_outline,
                      title: lang.translate("Help", "እገዛ", "Gargaarsa"),
                      onTap: () => _showHelpDialog(context, lang),
                      isDarkMode: isDarkMode,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: currentUser == null
                    ? ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.login),
                        label: Text(lang.translate("Login", "ግባ", "Seeni")),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                          onUserUpdate();
                        },
                      )
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.logout),
                        label: Text(lang.translate("Logout", "ውጣ", "Ba'i")),
                        onPressed: () async {
                          await HiveService.clearUserSession();
                          onUserUpdate();
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDrawerHeader(BuildContext context, LanguageService lang) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode 
              ? [Colors.green.shade900, Colors.green.shade700]
              : [Colors.green.shade700, Colors.green.shade500],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.eco, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 15),
          Text(
            "CoffeeGuard AI",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          if (currentUser != null)
            Text(
              currentUser!.email ?? "",
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
        ],
      ),
    );
  }
  
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
    required bool isDarkMode,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDarkMode ? Colors.green.shade400 : Colors.green.shade700),
      title: Text(title, style: GoogleFonts.poppins(color: isDarkMode ? Colors.white70 : Colors.grey.shade800)),
      trailing: trailing,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      hoverColor: isDarkMode ? Colors.green.shade900 : Colors.green.shade50,
    );
  }
  
  void _showSettingsDialog(BuildContext context, LanguageService lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.translate("Settings", "ቅንብሮች", "Qindoomina"), style: GoogleFonts.poppins()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text(lang.translate("Amharic Language", "አማርኛ ቋንቋ", "Afaan Amaaraa"), style: GoogleFonts.poppins()),
              value: lang.isAmharic,
              onChanged: (val) {
                onLanguageToggle();
                Navigator.pop(context);
              },
              activeColor: Colors.green,
            ),
            SwitchListTile(
              title: Text(lang.translate("Dark Mode", "ጨለማ ሁነታ", "Haala Dukkan"), style: GoogleFonts.poppins()),
              value: isDarkMode,
              onChanged: (val) {
                onThemeToggle();
                Navigator.pop(context);
              },
              activeColor: Colors.green,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang.translate("Close", "ዝጋ", "Cufi"), style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }
  
  void _showAboutDialog(BuildContext context, LanguageService lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.translate("About CoffeeGuard", "ስለ CoffeeGuard", "Waa'ee CoffeeGuard"), style: GoogleFonts.poppins()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.eco, size: 60, color: Colors.green),
            const SizedBox(height: 10),
            Text(
              lang.translate(
                "CoffeeGuard is an advanced mobile application that uses AI to detect coffee leaf diseases.",
                "CoffeeGuard የቡና በሽታዎችን ለመለየት AI የሚጠቀም በጣም ዘመናዊ መተግበሪያ ነው።",
                "CoffeeGuard appilkeeshinii kubbaa baalaa dhukkuba hubachuuf AI fayyadamtu kan taate isa onaanadha.",
              ),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 10),
            Text(
              lang.translate("Version 2.0.0", "ስሪት 2.0.0", "Veershini 2.0.0"),
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang.translate("Close", "ዝጋ", "Cufi"), style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }
  
  void _showHelpDialog(BuildContext context, LanguageService lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.translate("Help", "እገዛ", "Gargaarsa"), style: GoogleFonts.poppins()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lang.translate(
                "1. Take a photo of a coffee leaf in good lighting\n2. Ensure the photo is clear and focused on one leaf\n3. The app will analyze the disease\n4. Follow the recommendations provided",
                "1. ጥሩ ብርሃን ባለበት የቡና ቅጠል ፎቶ ይንሱ\n2. ፎቶው ግልጽ እና አንድ ቅጠል ላይ ያተኮረ ይሁን\n3. መተግበሪያው በሽታውን ይተነትናል\n4. ምክሮችን ይከተሉ",
                "1. Ifa gaariin jala baala kubbaa fudhadhu\n2. Ifa baala tokko iratti ifa fi ifa ta'uu isaa mirkaneessi\n3. Appilkeeshiniin dhukkuba xiinxala\n4. Gorsa kenname hordofaa",
              ),
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang.translate("Close", "ዝጋ", "Cufi"), style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }
}