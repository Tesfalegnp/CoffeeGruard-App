import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'core/services/hive_service.dart';
import 'core/services/recommendation_service.dart';

// Providers
import 'providers/admin_provider.dart';

// Screens
import 'screens/home/hero_home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ===============================
  // 🌱 LOAD ENV
  // ===============================
  await dotenv.load(fileName: ".env");

  // ===============================
  // ☁ INIT SUPABASE
  // ===============================
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  // ===============================
  // 💾 INIT HIVE
  // ===============================
  await HiveService.init();

  // ===============================
  // 🔄 SYNC RECOMMENDATIONS
  // ===============================
  try {
    await RecommendationService().syncRecommendations();
    debugPrint("✅ Recommendations synced successfully");
  } catch (e) {
    debugPrint("⚠️ Recommendation sync failed: $e");
  }

  // ===============================
  // 🚀 RUN APP WITH PROVIDERS
  // ===============================
  runApp(const CoffeeGuardApp());
}

class CoffeeGuardApp extends StatelessWidget {
  const CoffeeGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [

        // ===============================
        // 👨‍💼 ADMIN PROVIDER
        // ===============================
        ChangeNotifierProvider(
          create: (_) => AdminProvider(),
        ),

        // 👉 (NEXT STEPS)
        // You will add more providers here:
        // DetectionProvider()
        // AuthProvider()
        // SyncProvider()

      ],
      child: MaterialApp(
        title: 'CoffeeGuard',
        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          primarySwatch: Colors.green,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
          ),
        ),

        // ===============================
        // 🏠 START SCREEN
        // ===============================
        home: const HeroHomeScreen(),
      ),
    );
  }
}