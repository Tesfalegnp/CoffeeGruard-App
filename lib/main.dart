import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'core/services/hive_service.dart';
import 'core/services/recommendation_service.dart';
import 'screens/home/hero_home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load ENV variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  // Initialize Hive (offline storage)
  await HiveService.init();

  // 🔄 Sync recommendations from Supabase → Hive
  try {
    await RecommendationService().syncRecommendations();
    debugPrint("✅ Recommendations synced successfully");
  } catch (e) {
    debugPrint("⚠️ Recommendation sync failed: $e");
  }

  runApp(const CoffeeGuardApp());
}

class CoffeeGuardApp extends StatelessWidget {
  const CoffeeGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoffeeGuard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const HeroHomeScreen(),
    );
  }
}