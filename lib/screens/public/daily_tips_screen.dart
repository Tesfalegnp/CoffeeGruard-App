// ==========================================================
// FILE: lib/screens/public/daily_tips_screen.dart
// CREATE THIS NEW FILE
// ==========================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';

class DailyTipsScreen extends StatefulWidget {
  const DailyTipsScreen({super.key});

  @override
  State<DailyTipsScreen> createState() => _DailyTipsScreenState();
}

class _DailyTipsScreenState extends State<DailyTipsScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  Timer? _timer;

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) {
        if (!mounted) return;

        currentIndex++;

        if (currentIndex >= 6) {
          currentIndex = 0;
        }

        _pageController.animateToPage(
          currentIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );

        setState(() {});
      },
    );
  }

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

  List<Map<String, dynamic>> getTips(String code) {
    return [
      {
        "icon": Icons.wb_sunny,
        "title": tr(
          "Use Morning Sunlight",
          "የጠዋት ፀሐይ ይጠቀሙ",
          "Ifa ganamaa fayyadami",
          code,
        ),
        "body": tr(
          "Take leaf photos in morning natural light for better detection accuracy.",
          "ለትክክለኛ ምርመራ ቅጠልን በጠዋት ብርሃን ይፎቱ።",
          "Sirrii ta'uuf suuraa baala ganama ifatti kaasi.",
          code,
        ),
      },
      {
        "icon": Icons.water_drop,
        "title": tr(
          "Water Correctly",
          "በትክክል ያጠጡ",
          "Sirnaan bishaan kenni",
          code,
        ),
        "body": tr(
          "Do not overwater coffee plants. Wet soil may cause fungal disease.",
          "በጣም አትጠጡ፤ እርጥብ አፈር በሽታ ያመጣል።",
          "Bishaan baay'ee hin kennin. Lafti jiidhaan dhibee fida.",
          code,
        ),
      },
      {
        "icon": Icons.spa,
        "title": tr(
          "Remove Infected Leaves",
          "የታመሙ ቅጠሎችን አስወግዱ",
          "Baala dhukkubsate balleessi",
          code,
        ),
        "body": tr(
          "Quickly remove diseased leaves to stop spreading.",
          "በሽተኛ ቅጠል በፍጥነት ያስወግዱ።",
          "Baala dhibee qabu saffisaan balleessi.",
          code,
        ),
      },
      {
        "icon": Icons.bug_report,
        "title": tr(
          "Check for Insects",
          "ተባዮችን ይመልከቱ",
          "Ilbiisota ilaali",
          code,
        ),
        "body": tr(
          "Inspect under leaves weekly for insects and eggs.",
          "በየሳምንቱ ከቅጠሉ በታች ይመልከቱ።",
          "Torban torbaniin jala baalaa ilaali.",
          code,
        ),
      },
      {
        "icon": Icons.grass,
        "title": tr(
          "Clean Around Plants",
          "ዙሪያውን ንጹህ ያድርጉ",
          "Naannoo biqiltuu qulqulleessi",
          code,
        ),
        "body": tr(
          "Remove weeds and waste near coffee plants.",
          "አረምና ቆሻሻ ያስወግዱ።",
          "Aramaa fi xurii naannoo irraa kaasii.",
          code,
        ),
      },
      {
        "icon": Icons.phone_android,
        "title": tr(
          "Use CoffeeGuard Weekly",
          "CoffeeGuard በየሳምንቱ ይጠቀሙ",
          "CoffeeGuard torban torbaniin fayyadami",
          code,
        ),
        "body": tr(
          "Scan leaves every week for early disease detection.",
          "በየሳምንቱ ቅጠል ይመርምሩ።",
          "Torban torbaniin baala sakatta'i.",
          code,
        ),
      },
    ];
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final code = lang.code;

    final tips = getTips(code);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
        title: Text(
          tr(
            "Daily Tips",
            "የዕለት ምክሮች",
            "Gorsa Guyyaa",
            code,
          ),
        ),
      ),

      body: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade700,
                  Colors.green.shade500,
                ],
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.lightbulb,
                  color: Colors.white,
                  size: 55,
                ),
                const SizedBox(height: 10),
                Text(
                  tr(
                    "Expert Coffee Farming Advice",
                    "የባለሙያ የቡና ምክር",
                    "Gorsa Ogeessa Bunaa",
                    code,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: tips.length,
              itemBuilder: (context, index) {
                final tip = tips[index];

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: AnimatedContainer(
                    duration:
                        const Duration(milliseconds: 500),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(.08),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 42,
                            backgroundColor:
                                Colors.green.shade100,
                            child: Icon(
                              tip["icon"],
                              color: Colors.green,
                              size: 40,
                            ),
                          ),

                          const SizedBox(height: 24),

                          Text(
                            tip["title"],
                            textAlign:
                                TextAlign.center,
                            style:
                                const TextStyle(
                              fontSize: 22,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 16),

                          Text(
                            tip["body"],
                            textAlign:
                                TextAlign.center,
                            style:
                                TextStyle(
                              fontSize: 16,
                              color: Colors
                                  .grey.shade700,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // INDICATOR
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: List.generate(
              tips.length,
              (index) => Container(
                margin:
                    const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 14,
                ),
                width:
                    currentIndex == index ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: currentIndex == index
                      ? Colors.green
                      : Colors.grey.shade400,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}