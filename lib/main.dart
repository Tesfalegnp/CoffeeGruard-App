import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'config/supabase_config.dart';
import 'core/services/hive_service.dart';
import 'core/services/recommendation_service.dart';
import 'core/theme/app_theme.dart';

import 'providers/admin_provider.dart';
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';

import 'screens/home/hero_home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");

    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );

    await HiveService.init();
    await RecommendationService().syncRecommendations();
  } catch (e) {
    debugPrint("Initialization Error: $e");
  }

  runApp(const CoffeeGuardApp());
}

class CoffeeGuardApp extends StatelessWidget {
  const CoffeeGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminProvider()),

        /// 🌍 LANGUAGE PROVIDER
        ChangeNotifierProvider(
          create: (_) => LanguageProvider()..loadLanguage(),
        ),

        /// 🎨 THEME PROVIDER
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..loadTheme(),
        ),
      ],
      child: const AppRoot(),
    );
  }
}

/// =======================================
/// 🔥 FIX: LANGUAGE NOW REACTS GLOBALLY
/// =======================================
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final languageProvider = context.watch<LanguageProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "CoffeeGuard",

      /// 🌍 FIX LANGUAGE - Use locale but with fallback for unsupported languages
      locale: languageProvider.locale,
      
      /// 🔥 CRITICAL FIX: Set fallback locale for languages without Material support
      localeResolutionCallback: (locale, supportedLocales) {
        // If the locale is Oromo (om), fallback to English for Material components
        if (locale?.languageCode == 'om') {
          return const Locale('en', 'US');
        }
        return locale;
      },

      supportedLocales: const [
        Locale('en', 'US'),
        Locale('am', 'ET'),
        Locale('om', 'ET'),
      ],

      /// 🔥 CRITICAL FIX - Added all localization delegates
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      /// 🎨 THEME SUPPORT
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,

      home: const StartupScreen(),
    );
  }
}

/// ==============================
/// 🚀 STARTUP SCREEN
/// ==============================
class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  String _loadingMessage = "Preparing smart detection...";

  final Map<String, List<String>> _loadingMessages = {
    'en': [
      "Initializing AI model...",
      "Loading disease database...",
      "Setting up language support...",
      "Ready to protect coffee!"
    ],
    'am': [
      "ኤአይ ሞዴል በማስጀመር ላይ...",
      "የበሽታ ውሂብ ጎታ በመጫን ላይ...",
      "የቋንቋ ድጋፍ በማዘጋጀት ላይ...",
      "ቡናን ለመጠበቅ ዝግጁ!"
    ],
    'om': [
      "Moodelii AI kan eegaluu...",
      "Gurmuu dhukkuba qaamaa kan fe'uu...",
      "Deeggarsa afaanii kan qopheessuu...",
      "Buna eeguuf qophaa'aa!"
    ],
  };

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _simulateLoadingSteps();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  void _simulateLoadingSteps() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _updateLoadingMessage(0);
    });

    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) _updateLoadingMessage(1);
    });

    Future.delayed(const Duration(milliseconds: 4500), () {
      if (mounted) _updateLoadingMessage(2);
    });

    Future.delayed(const Duration(milliseconds: 5500), () {
      if (mounted) _updateLoadingMessage(3);
    });
  }

  void _updateLoadingMessage(int index) {
    final lang = context.read<LanguageProvider>().code;
    final messages = _loadingMessages[lang] ?? _loadingMessages['en']!;
    setState(() => _loadingMessage = messages[index]);
  }

  Future<void> _initializeApp() async {
    try {
      await Future.delayed(const Duration(seconds: 6));
    } catch (e) {
      debugPrint("Startup Error: $e");
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HeroHomeScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget floatingLeaf(double top, double left, double size, double delay) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final value = (_controller.value + delay) % 1;

        return Positioned(
          top: top + math.sin(value * 2 * math.pi) * 20,
          left: left + math.cos(value * 2 * math.pi) * 15,
          child: Opacity(
            opacity: 0.18,
            child: Icon(
              Icons.eco,
              size: size,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();
    final isAmharic = langProvider.code == 'am';
    final isOromo = langProvider.code == 'om';

    String titleText = "CoffeeGuard";
    String subtitleText = "Protecting every coffee leaf";

    if (isAmharic) {
      titleText = "ቡናጋርድ";
      subtitleText = "እያንዳንዱን የቡና ቅጠል መጠበቅ";
    } else if (isOromo) {
      titleText = "BunaGuard";
      subtitleText = "Buna tokkoo tokkoo eeguu";
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1B5E20),
                  Color(0xFF2E7D32),
                  Color(0xFF43A047),
                ],
              ),
            ),
          ),

          floatingLeaf(80, 30, 40, 0.1),
          floatingLeaf(160, 280, 55, 0.3),
          floatingLeaf(500, 40, 50, 0.5),
          floatingLeaf(620, 290, 38, 0.7),
          floatingLeaf(350, 170, 65, 0.9),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.eco, color: Colors.white, size: 70),
                const SizedBox(height: 28),
                Text(
                  titleText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitleText,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 35),
                SizedBox(
                  width: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    _loadingMessage,
                    key: ValueKey(_loadingMessage),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
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