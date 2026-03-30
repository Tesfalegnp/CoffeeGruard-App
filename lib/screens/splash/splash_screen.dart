import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../home/hero_home_screen.dart'; // ✅ Correct import

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3)); // splash duration
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HeroHomeScreen()), // ✅ Remove const
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset(
          'assets/animations/coffee_splash.json',
          width: 250,
          height: 250,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}