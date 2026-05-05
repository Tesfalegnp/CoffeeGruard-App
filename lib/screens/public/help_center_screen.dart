// ==========================================================
// FILE: lib/screens/public/help_center_screen.dart
// HELP CENTER / SUPPORT / FAQ
// ==========================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  String tr(String en, String am, String om, String code) {
    if (code == "am") return am;
    if (code == "om") return om;
    return en;
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final code = lang.code;

    final faqs = [
      {
        "q": tr(
          "How to scan coffee leaf?",
          "የቡና ቅጠል እንዴት እንደሚቃኝ?",
          "Akkaataa baala bunaa itti sakatta'an?",
          code,
        ),
        "a": tr(
          "Open camera, take a clear leaf photo and wait for AI result.",
          "ካሜራ ይክፈቱ ፎቶ ያንሱ እና ውጤት ይጠብቁ።",
          "Kaameraa bani, suuraa baala kaasi, bu'aa eegi.",
          code,
        ),
      },
      {
        "q": tr(
          "Why detection fails?",
          "ለምን ምርመራ አይሳካም?",
          "Maaliif qorannoon hin milkaa'u?",
          code,
        ),
        "a": tr(
          "Bad light or blurry image can cause failure.",
          "ደካማ ብርሃን ወይም ግልጽ ያልሆነ ፎቶ ችግኝ ያመጣል።",
          "Ifa gadhee ykn suuraa ifa hin qabne rakkoo fida.",
          code,
        ),
      },
      {
        "q": tr(
          "How to improve accuracy?",
          "ትክክለኛነት እንዴት ይሻላል?",
          "Akkaataa sirrii taasisuu?",
          code,
        ),
        "a": tr(
          "Use natural light and clean leaf background.",
          "ተፈጥሮ ብርሃን ይጠቀሙ።",
          "Ifa uumamaa fayyadami.",
          code,
        ),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: Text(
          tr("Help Center", "የእርዳታ ማዕከል", "Gargaarsa", code),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.support_agent,
                size: 80, color: Colors.green),

            const SizedBox(height: 10),

            Text(
              tr(
                "We are here to help farmers",
                "ለአርሶ አደሮች እንረዳለን",
                "Farmers ni gargaarra",
                code,
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // ================= FAQ =================
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                tr("FAQ", "ተደጋጋሚ ጥያቄ", "Gaaffiiwwan", code),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            ...faqs.map((faq) {
              return ExpansionTile(
                title: Text(faq["q"]!),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(faq["a"]!),
                  ),
                ],
              );
            }),

            const SizedBox(height: 20),

            // ================= CONTACT =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.phone, color: Colors.green),
                  const SizedBox(height: 10),

                  Text(
                    tr(
                      "Emergency Support",
                      "የአስቸኳይ እርዳታ",
                      "Gargaarsa ariifachiisaa",
                      code,
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "+251 900 000 000",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= GUIDE =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.menu_book, color: Colors.blue),
                  const SizedBox(height: 10),

                  Text(
                    tr(
                      "How to use app",
                      "እንዴት እንደሚጠቀሙ",
                      "Akkaataa itti fayyadaman",
                      code,
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    tr(
                      "1. Open camera\n2. Capture leaf\n3. Get AI result\n4. Follow advice",
                      "1. ካሜራ ክፈት\n2. ፎቶ አንሳ\n3. ውጤት ተቀበል\n4. ምክር ተከተል",
                      "1. Kaameraa bani\n2. Suuraa kaasi\n3. Bu'aa argadhu\n4. Gorsa hordofi",
                      code,
                    ),
                    style: const TextStyle(height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}