import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shimmer/shimmer.dart';

import '../../widgets/image_picker_widget.dart';
import '../../core/services/detection_service.dart';
import '../../core/services/recommendation_service.dart';
import '../../core/services/sync_service.dart';
import '../../core/services/hive_service.dart';
import '../../models/user_model.dart';
import '../../providers/language_provider.dart';
import '../../providers/theme_provider.dart';
import '../detection/history_screen.dart';
import 'widgets/result_card.dart';
import 'widgets/role_drawer.dart';
import 'widgets/language_selector.dart';
import 'widgets/theme_selector.dart';

class HeroHomeScreen extends StatefulWidget {
  const HeroHomeScreen({super.key});

  @override
  State<HeroHomeScreen> createState() => _HeroHomeScreenState();
}

class _HeroHomeScreenState extends State<HeroHomeScreen>
    with TickerProviderStateMixin {
  final DetectionService detectionService = DetectionService();
  final RecommendationService recommendationService = RecommendationService();
  final SyncService syncService = SyncService();
  final FlutterTts tts = FlutterTts();

  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  final ScrollController _scrollController = ScrollController();

  File? selectedImage;

  bool isProcessing = false;
  bool isSpeaking = false;
  bool isCoffeeLeaf = true;

  String disease = "";
  double confidence = 0.0;
  String recommendation = "";
  String displayedText = "";

  Timer? _typingTimer;

  UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    
    detectionService.init();
    currentUser = HiveService.getCurrentUser();
    _initTTS();
    
    _slideController.forward();
    
    // Pre-load recommendations on startup
    _preloadRecommendations();
  }
  
  Future<void> _preloadRecommendations() async {
    await recommendationService.syncRecommendations();
  }

  /// =========================
  /// 🔊 TEXT TO SPEECH SETUP
  /// =========================
  void _initTTS() async {
    await tts.setSpeechRate(0.5);
    await tts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    if (!mounted) return;

    final lang = Provider.of<LanguageProvider>(
      context,
      listen: false,
    ).code;

    switch (lang) {
      case "am":
        await tts.setLanguage("am-ET");
        break;
      case "om":
        await tts.setLanguage("en-US");
        break;
      default:
        await tts.setLanguage("en-US");
    }

    setState(() => isSpeaking = true);
    await tts.speak(text);
  }

  Future<void> _stopSpeak() async {
    await tts.stop();
    setState(() => isSpeaking = false);
  }

  /// =========================
  /// 📸 IMAGE PROCESSING
  /// =========================
  Future<void> handleImage(File image) async {
    final lang = Provider.of<LanguageProvider>(
      context,
      listen: false,
    ).code;

    _typingTimer?.cancel();
    await _stopSpeak();

    setState(() {
      selectedImage = image;
      isProcessing = true;
      disease = "";
      recommendation = "";
      displayedText = "";
      isCoffeeLeaf = true;
    });

    final result = await detectionService.runDetection(image);

    if (result["success"] == false) {
      setState(() {
        isProcessing = false;
        disease = "Detection Failed";
        recommendation = result["message"];
      });

      _typeText(recommendation);
      return;
    }

    final detectedDisease = result["disease"];
    final detectedConfidence = result["diseaseConfidence"];

    /// ❌ Not coffee leaf
    if (detectedDisease.toLowerCase().contains("not") ||
        detectedDisease.toLowerCase().contains("unknown")) {
      setState(() {
        isCoffeeLeaf = false;
        disease = "Not a Coffee Leaf";
        confidence = detectedConfidence;
        recommendation = lang == 'am' 
            ? "እባክዎ በተፈጥሮ ብርሃን ስር ግልጽ የሆነ የቡና ቅጠል ይቅረጹ"
            : lang == 'om'
            ? "Maaloo suuraa baala bunaa ifa uumamaa keessatti ifa ta'e fudhadhu"
            : "Please capture a clear coffee leaf under natural light";
        isProcessing = false;
      });

      _typeText(recommendation);
      return;
    }

    /// 🌍 GET RECOMMENDATION (USES LOCAL CACHE FIRST)
    final rec = await recommendationService.getRecommendation(
      diseaseLabel: detectedDisease,
      languageCode: lang,
    );

    /// 🌐 SYNC IF ONLINE
    final net = await Connectivity().checkConnectivity();
    if (net != ConnectivityResult.none) {
      syncService.syncDetections();
    }

    setState(() {
      disease = detectedDisease;
      confidence = detectedConfidence;
      recommendation = rec;
      isProcessing = false;
    });

    _typeText(rec);
  }

  /// =========================
  /// ⌨ TYPEWRITER EFFECT
  /// =========================
  void _typeText(String text) {
    displayedText = "";
    int i = 0;

    _typingTimer = Timer.periodic(
      const Duration(milliseconds: 20),
      (timer) {
        if (i < text.length) {
          setState(() => displayedText += text[i]);
          i++;
        } else {
          timer.cancel();
        }
      },
    );
  }

  /// =========================
  /// 🔄 RESET
  /// =========================
  void _reset() async {
    _typingTimer?.cancel();
    await _stopSpeak();

    setState(() {
      selectedImage = null;
      disease = "";
      confidence = 0.0;
      recommendation = "";
      displayedText = "";
      isProcessing = false;
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _pulseController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    tts.stop();
    super.dispose();
  }

  /// =========================
  /// 🏠 UI with Attractive Design
  /// =========================
  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.currentTheme == AppThemeMode.dark;
    
    String titleText = "CoffeeGuard";
    String subtitleText = "Protect your coffee plants";
    
    if (langProvider.code == 'am') {
      titleText = "ቡናጋርድ";
      subtitleText = "የቡና ተክሎችዎን ይጠብቁ";
    } else if (langProvider.code == 'om') {
      titleText = "BunaGuard";
      subtitleText = "Buna keessan eegaa";
    }

    return Scaffold(
      drawer: RoleDrawer(currentUser: currentUser),
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              titleText,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              subtitleText,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
        actions: const [
          ThemeSelector(),
          LanguageSelector(),
        ],
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              /// Hero Animated Header
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.green.shade700,
                      Colors.green.shade400,
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: const Icon(
                          Icons.eco,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        langProvider.code == 'am'
                            ? "የቡና በሽታ መለያ"
                            : langProvider.code == 'om'
                            ? "Addabbii Dhukkuba Buna"
                            : "Coffee Disease Detector",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        langProvider.code == 'am'
                            ? "ቅጠል ይቅረጹ እና ይለዩ"
                            : langProvider.code == 'om'
                            ? "Suuraa fudhadhu fi adda baasi"
                            : "Capture & Identify",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// IMAGE PICKER SECTION
              if (selectedImage == null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    child: ImagePickerWidget(
                      onImageSelected: handleImage,
                    ),
                  ),
                ),

              /// PROCESSING SECTION
              if (isProcessing && selectedImage != null)
                Column(
                  children: [
                    Hero(
                      tag: 'selected_image',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          selectedImage!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Text(
                        langProvider.code == 'am'
                            ? "የቡና ቅጠልዎን በመተንተን ላይ..."
                            : langProvider.code == 'om'
                            ? "Baala bunaa keessan xiinxalaa jira..."
                            : "Analyzing your coffee leaf...",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        langProvider.code == 'am'
                            ? "እባክዎ ይጠብቁ..."
                            : langProvider.code == 'om'
                            ? "Maaloo eeggadhu..."
                            : "Please wait...",
                        style: TextStyle(color: Colors.green.shade800),
                      ),
                    ),
                  ],
                ),

              /// RESULT CARD
              if (!isProcessing && disease.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ResultCard(
                    disease: disease,
                    confidence: confidence,
                    recommendation: recommendation,
                    displayedText: displayedText,
                    isCoffeeLeaf: isCoffeeLeaf,
                    isSpeaking: isSpeaking,
                    onSpeakToggle: () {
                      isSpeaking ? _stopSpeak() : _speak(recommendation);
                    },
                    onReset: _reset,
                  ),
                ),

              /// EMPTY STATE
              if (!isProcessing && disease.isEmpty && selectedImage == null)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.photo_camera,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        langProvider.code == 'am'
                            ? "ለመጀመር የቡና ቅጠል ፎቶ ይቅረጹ"
                            : langProvider.code == 'om'
                            ? "Suuraa baala bunaa fudhadhu"
                            : "Tap the camera to start",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}