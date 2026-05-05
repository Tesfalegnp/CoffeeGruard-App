import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/language_provider.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  void _openSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Consumer<LanguageProvider>(
          builder: (context, lang, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Select Language",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text("English"),
                  subtitle: const Text("Default language"),
                  trailing: lang.currentLanguage == AppLanguage.english
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    context.read<LanguageProvider>().setLanguage(AppLanguage.english);
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text("አማርኛ"),
                  subtitle: const Text("Amharic"),
                  trailing: lang.currentLanguage == AppLanguage.amharic
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    context.read<LanguageProvider>().setLanguage(AppLanguage.amharic);
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text("Afaan Oromoo"),
                  subtitle: const Text("Oromo"),
                  trailing: lang.currentLanguage == AppLanguage.oromo
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    context.read<LanguageProvider>().setLanguage(AppLanguage.oromo);
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
    final lang = context.watch<LanguageProvider>();
    String flag = "🇬🇧";
    
    if (lang.currentLanguage == AppLanguage.amharic) {
      flag = "🇪🇹";
    } else if (lang.currentLanguage == AppLanguage.oromo) {
      flag = "🇪🇹";
    }

    return IconButton(
      icon: Text(flag, style: const TextStyle(fontSize: 20)),
      tooltip: lang.displayName,
      onPressed: () => _openSelector(context),
    );
  }
}