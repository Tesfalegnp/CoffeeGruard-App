import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'core/services/hive_service.dart';
import 'core/services/recommendation_service.dart';
import 'core/services/language_service.dart'; // Add this
import 'providers/admin_provider.dart';
import 'screens/home/hero_home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive and other services before running app
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
        ChangeNotifierProvider(create: (_) => LanguageService()), // Add Language Service
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "CoffeeGuard",
        theme: ThemeData(
          primarySwatch: Colors.green,
          fontFamily: 'Poppins',
          useMaterial3: true,
        ),
        home: const StartupScreen(),
      ),
    );
  }
}

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _loadingMessage = "Preparing smart detection...";
  int _loadingStep = 0;
  
  final List<String> _loadingMessages = [
    "Initializing AI model...",
    "Loading disease database...",
    "Setting up language support...",
    "Ready to protect coffee!",
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    
    _simulateLoadingSteps();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }
  
  void _simulateLoadingSteps() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _loadingMessage = _loadingMessages[0]);
    });
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) setState(() => _loadingMessage = _loadingMessages[1]);
    });
    Future.delayed(const Duration(milliseconds: 4500), () {
      if (mounted) setState(() => _loadingMessage = _loadingMessages[2]);
    });
    Future.delayed(const Duration(milliseconds: 5500), () {
      if (mounted) setState(() => _loadingMessage = _loadingMessages[3]);
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize Language Service
      final languageService = Provider.of<LanguageService>(context, listen: false);
      await languageService.init();
      
      // Any additional initialization
      await Future.delayed(const Duration(milliseconds: 500));
      
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
    return Scaffold(
      body: Stack(
        children: [
          /// BACKGROUND GRADIENT
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

          /// FLOATING LEAVES
          floatingLeaf(80, 30, 40, 0.1),
          floatingLeaf(160, 280, 55, 0.3),
          floatingLeaf(500, 40, 50, 0.5),
          floatingLeaf(620, 290, 38, 0.7),
          floatingLeaf(350, 170, 65, 0.9),

          /// CENTER CONTENT
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// GLOW CIRCLE WITH PULSE ANIMATION
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 1.0, end: 1.1),
                  duration: const Duration(seconds: 2),
                  builder: (context, double scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.12),
                              blurRadius: 25,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.eco,
                          color: Colors.white,
                          size: 70,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 28),

                const Text(
                  "CoffeeGuard",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Protecting every coffee leaf",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 35),

                /// ANIMATED PROGRESS BAR
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

                /// DYNAMIC LOADING MESSAGE
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    _loadingMessage,
                    key: ValueKey(_loadingMessage),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                /// LANGUAGE INDICATOR (subtle)
                Consumer<LanguageService>(
                  builder: (context, lang, child) {
                    String languageText = "";
                    if (lang.isEnglish) languageText = "🌐 English";
                    else if (lang.isAmharic) languageText = "🇪🇹 አማርኛ";
                    else languageText = "🇪🇹 Oromoo";
                    
                    return AnimatedOpacity(
                      opacity: 0.5,
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        languageText,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}