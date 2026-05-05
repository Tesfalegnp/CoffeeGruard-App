import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  void _openSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Consumer<ThemeProvider>(
          builder: (context, theme, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Select Theme",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.light_mode),
                  title: const Text("Light"),
                  trailing: theme.currentTheme == AppThemeMode.light
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    context.read<ThemeProvider>().setTheme(AppThemeMode.light);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text("Dark"),
                  trailing: theme.currentTheme == AppThemeMode.dark
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    context.read<ThemeProvider>().setTheme(AppThemeMode.dark);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings_suggest),
                  title: const Text("System Default"),
                  trailing: theme.currentTheme == AppThemeMode.system
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    context.read<ThemeProvider>().setTheme(AppThemeMode.system);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.brightness_6),
      tooltip: "Theme",
      onPressed: () => _openSelector(context),
    );
  }
}