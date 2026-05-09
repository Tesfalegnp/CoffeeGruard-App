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
import '../public/daily_tips_screen.dart';

import '../chat/assistant_chat_screen.dart';
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
  final RecommendationService recommendationService =
      RecommendationService();
  final SyncService syncService = SyncService();
  final FlutterTts tts = FlutterTts();

  final ScrollController _scrollController = ScrollController();

  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _fadeController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _fadeAnimation;

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

  // =====================================================
  // INIT
  // =====================================================
  @override
  void initState() {
    super.initState();

    currentUser = HiveService.getCurrentUser();

    detectionService.init();

    _initTTS();
    _preloadRecommendations();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _pulseAnimation =
        Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _floatAnimation =
        Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOut,
      ),
    );

    _fadeAnimation =
        CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
  }

  Future<void> _preloadRecommendations() async {
    await recommendationService.syncRecommendations();
  }

  Future<void> _initTTS() async {
    await tts.setSpeechRate(0.45);
    await tts.setPitch(1.0);
  }

  // =====================================================
  // LANGUAGE TEXTS
  // =====================================================

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

  // =====================================================
  // SPEAK
  // =====================================================

  Future<void> _speak(String text) async {
    final code =
        Provider.of<LanguageProvider>(
          context,
          listen: false,
        ).code;

    if (code == "am") {
      await tts.setLanguage("am-ET");
    } else {
      await tts.setLanguage("en-US");
    }

    setState(() => isSpeaking = true);

    await tts.speak(text);
  }

  Future<void> _stopSpeak() async {
    await tts.stop();

    if (mounted) {
      setState(() => isSpeaking = false);
    }
  }

  // =====================================================
  // HANDLE IMAGE
  // =====================================================

  Future<void> handleImage(File image) async {
    final code =
        Provider.of<LanguageProvider>(
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

    final result =
        await detectionService.runDetection(image);

    if (result["success"] == false) {
      setState(() {
        isProcessing = false;
        disease = tr(
          "Detection Failed",
          "ምርመራ አልተሳካም",
          "Qorannoon hin milkoofne",
          code,
        );

        recommendation = result["message"];
      });

      _typeText(recommendation);
      return;
    }

    final detectedDisease = result["disease"];
    final detectedConfidence =
        result["diseaseConfidence"];

    if (detectedDisease
            .toLowerCase()
            .contains("not") ||
        detectedDisease
            .toLowerCase()
            .contains("unknown")) {
      setState(() {
        isCoffeeLeaf = false;
        confidence = detectedConfidence;

        disease = tr(
          "Not Coffee Leaf",
          "የቡና ቅጠል አይደለም",
          "Baala buna miti",
          code,
        );

        recommendation = tr(
          "Please select clear coffee leaf image.",
          "እባክዎ ግልጽ የቡና ቅጠል ፎቶ ይምረጡ።",
          "Maaloo suuraa baala bunaa qulqulluu filadhu.",
          code,
        );

        isProcessing = false;
      });

      _typeText(recommendation);
      return;
    }

    final rec =
        await recommendationService.getRecommendation(
      diseaseLabel: detectedDisease,
      languageCode: code,
    );

    final net =
        await Connectivity().checkConnectivity();

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

  // =====================================================
  // TYPE WRITER
  // =====================================================

  void _typeText(String text) {
    displayedText = "";

    int i = 0;

    _typingTimer = Timer.periodic(
      const Duration(milliseconds: 18),
      (timer) {
        if (i < text.length) {
          setState(() {
            displayedText += text[i];
          });

          i++;
        } else {
          timer.cancel();
        }
      },
    );
  }

  // =====================================================
  // RESET
  // =====================================================

  Future<void> _reset() async {
    _typingTimer?.cancel();
    await _stopSpeak();

    setState(() {
      selectedImage = null;
      isProcessing = false;
      disease = "";
      confidence = 0;
      recommendation = "";
      displayedText = "";
    });
  }

void _openHelperPanel() {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Close",
    barrierColor: Colors.black54,
    transitionDuration:
        const Duration(milliseconds: 350),

    pageBuilder: (_, __, ___) {
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.transparent,

          child: Container(
            width:
                MediaQuery.of(context)
                        .size
                        .width *
                    0.82,

            height:
                MediaQuery.of(context)
                    .size
                    .height,

            decoration: BoxDecoration(
              color: Theme.of(context)
                  .scaffoldBackgroundColor,

              borderRadius:
                  const BorderRadius.only(
                topLeft:
                    Radius.circular(26),
                bottomLeft:
                    Radius.circular(26),
              ),
            ),

            child:
                const AssistantChatScreen(),
          ),
        ),
      );
    },

    transitionBuilder:
        (_, animation, __, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    },
  );
}


  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  void dispose() {
    _typingTimer?.cancel();

    _scrollController.dispose();

    _pulseController.dispose();
    _floatController.dispose();
    _fadeController.dispose();

    tts.stop();

    super.dispose();
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final lang =
        context.watch<LanguageProvider>();

    final theme =
        context.watch<ThemeProvider>();

    final code = lang.code;

    final isDark =
        theme.currentTheme ==
            AppThemeMode.dark;

    final bg =
        isDark
            ? const Color(0xff101513)
            : Colors.grey.shade100;

    final card =
        isDark
            ? const Color(0xff1b221f)
            : Colors.white;

    final txt =
        isDark
            ? Colors.white
            : Colors.black87;

    return Scaffold(
      backgroundColor: bg,

      drawer: const RoleDrawer(),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor:
            Colors.green.shade700,

        title: Column(
          children: [
            Text(
              tr(
                "CoffeeGuard",
                "ቡናጋርድ",
                "BunaGuard",
                code,
              ),
              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            Text(
              tr(
                "Protect coffee plants",
                "የቡና ተክል ጥበቃ",
                "Buna eegi",
                code,
              ),
              style:
                  const TextStyle(
                fontSize: 11,
              ),
            ),
          ],
        ),

        actions: const [
          ThemeSelector(),
          LanguageSelector(),
        ],
      ),

      body: FadeTransition(
        opacity: _fadeAnimation,

        child: SingleChildScrollView(
          controller:
              _scrollController,

          child: Column(
            children: [
              // =================================================
              // HERO HEADER
              // =================================================
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(
                  20,
                ),

                decoration:
                    BoxDecoration(
                  gradient:
                      LinearGradient(
                    colors: [
                      Colors
                          .green
                          .shade800,
                      Colors
                          .green
                          .shade600,
                      Colors
                          .green
                          .shade400,
                    ],
                  ),

                  borderRadius:
                      const BorderRadius
                          .vertical(
                    bottom:
                        Radius.circular(
                            30),
                  ),
                ),

                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation:
                          _floatAnimation,
                      builder:
                          (_, child) {
                        return Transform
                            .translate(
                          offset:
                              Offset(
                            0,
                            _floatAnimation
                                .value,
                          ),
                          child:
                              child,
                        );
                      },

                      child:
                          ScaleTransition(
                        scale:
                            _pulseAnimation,
                        child:
                            const Icon(
                          Icons.eco,
                          color:
                              Colors
                                  .white,
                          size: 60,
                        ),
                      ),
                    ),

                    const SizedBox(
                        height: 16),

                    Text(
                      tr(
                        "Take Photo • Detect • Get Advice",
                        "ፎቶ ያንሱ • ይለዩ • ምክር ያግኙ",
                        "Suuraa kaasi • Adda baasi • Gorsa argadhu",
                        code,
                      ),
                      textAlign:
                          TextAlign
                              .center,
                      style:
                          const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                        height: 18),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceEvenly,
                      children: [
                        _MiniCard(
                          title: "AI",
                          sub: tr(
                            "Smart",
                            "ብልህ",
                            "Smart",
                            code,
                          ),
                        ),
                        _MiniCard(
                          title: "24/7",
                          sub: tr(
                            "Ready",
                            "ዝግጁ",
                            "Qophaa'e",
                            code,
                          ),
                        ),
                        _MiniCard(
                          title: "Fast",
                          sub: tr(
                            "Result",
                            "ውጤት",
                            "Bu'aa",
                            code,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(
                  height: 16),

              // =================================================
              // FEATURES
              // =================================================
              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _FeatureBox(
                        icon: Icons.camera_alt,
                        title: tr(
                          "Scan",
                          "ስካን",
                          "Scan",
                          code,
                        ),
                        subtitle: tr(
                          "Take Image",
                          "ፎቶ አንሳ",
                          "Suuraa kaasi",
                          code,
                        ),
                        color:
                            Colors.green,
                        card: card,
                      ),
                    ),
                    const SizedBox(
                        width: 10),
                    Expanded(
                      child: _FeatureBox(
                        icon: Icons.analytics,
                        title: tr(
                          "Detect",
                          "ለይ",
                          "Beeki",
                          code,
                        ),
                        subtitle: tr(
                          "AI Analyze",
                          "AI ይመርምር",
                          "AI qorata",
                          code,
                        ),
                        color:
                            Colors.orange,
                        card: card,
                      ),
                    ),
                    const SizedBox(
                        width: 10),
                    Expanded(
                      child: _FeatureBox(
                        icon: Icons.healing,
                        title: tr(
                          "Treat",
                          "ሕክምና",
                          "Yaala",
                          code,
                        ),
                        subtitle: tr(
                          "Get Help",
                          "እርዳታ",
                          "Gargaarsa",
                          code,
                        ),
                        color:
                            Colors.blue,
                        card: card,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                  height: 20),

              // =================================================
              // PICK IMAGE
              // =================================================
              if (selectedImage == null)
                Padding(
                  padding:
                      const EdgeInsets.all(
                          16),
                  child:
                      ImagePickerWidget(
                    onImageSelected:
                        handleImage,
                  ),
                ),

              // =================================================
              // LOADING
              // =================================================
              if (isProcessing)
                Padding(
                  padding:
                      const EdgeInsets.all(
                          16),
                  child: Container(
                    padding:
                        const EdgeInsets
                            .all(18),
                    decoration:
                        BoxDecoration(
                      color: card,
                      borderRadius:
                          BorderRadius.circular(
                              18),
                    ),
                    child: Column(
                      children: [
                        if (selectedImage !=
                            null)
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(
                                    14),
                            child:
                                Image.file(
                              selectedImage!,
                              height:
                                  180,
                              width: double
                                  .infinity,
                              fit: BoxFit
                                  .cover,
                            ),
                          ),

                        const SizedBox(
                            height: 18),

                        Shimmer.fromColors(
                          baseColor: Colors
                              .grey
                              .shade400,
                          highlightColor:
                              Colors.white,
                          child: Text(
                            tr(
                              "Analyzing coffee leaf...",
                              "የቡና ቅጠል በመመርመር ላይ...",
                              "Baala buna qorachaa jira...",
                              code,
                            ),
                            style:
                                const TextStyle(
                              fontSize:
                                  18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(
                            height: 18),

                        const CircularProgressIndicator(),
                      ],
                    ),
                  ),
                ),

              // =================================================
              // RESULT
              // =================================================
              if (!isProcessing &&
                  disease.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.all(
                          16),
                  child: ResultCard(
                    disease: disease,
                    confidence:
                        confidence,
                    recommendation:
                        recommendation,
                    displayedText:
                        displayedText,
                    isCoffeeLeaf:
                        isCoffeeLeaf,
                    isSpeaking:
                        isSpeaking,
                    onSpeakToggle:
                        () {
                      isSpeaking
                          ? _stopSpeak()
                          : _speak(
                              recommendation);
                    },
                    onReset: _reset,
                  ),
                ),

              // =================================================
              // EMPTY STATE
              // =================================================
              if (!isProcessing &&
                  disease.isEmpty &&
                  selectedImage ==
                      null)
                Padding(
                  padding:
                      const EdgeInsets.all(
                          20),
                  child: Container(
                    width:
                        double.infinity,
                    padding:
                        const EdgeInsets
                            .all(20),
                    decoration:
                        BoxDecoration(
                      color: card,
                      borderRadius:
                          BorderRadius.circular(
                              18),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons
                              .camera_alt_outlined,
                          size: 72,
                          color: Colors
                              .green
                              .shade400,
                        ),
                        const SizedBox(
                            height: 12),
                        Text(
                          tr(
                            "Start by taking coffee leaf photo",
                            "የቡና ቅጠል ፎቶ በማንሳት ይጀምሩ",
                            "Suuraa baala buna irraa jalqabi",
                            code,
                          ),
                          textAlign:
                              TextAlign
                                  .center,
                          style:
                              TextStyle(
                            color: txt,
                            fontWeight:
                                FontWeight.bold,
                            fontSize:
                                16,
                          ),
                        ),
                        const SizedBox(
                            height: 8),
                        Text(
                          tr(
                            "Tip: Use natural light.",
                            "ምክር፡ የተፈጥሮ ብርሃን ይጠቀሙ።",
                            "Gorsa: Ifa uumamaa fayyadami.",
                            code,
                          ),
                          style:
                              TextStyle(
                            color: txt
                                .withOpacity(
                                    .7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(
                  height: 30),
            ],
          ),
        ),
      ),

     floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // HELPER BUTTON
          TweenAnimationBuilder(
            tween: Tween(begin: 0.9, end: 1.05),
            duration:
                const Duration(seconds: 1),
            curve: Curves.easeInOut,
            builder:
                (_, value, child) =>
                    Transform.scale(
              scale: value as double,
              child: child,
            ),

            child: FloatingActionButton(
              heroTag: "helper",
              backgroundColor:
                  Colors.orange.shade700,

              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
              ),

              onPressed: _openHelperPanel,
            ),
          ),

          const SizedBox(height: 12),

          // NEWS BUTTON
          FloatingActionButton.extended(
            heroTag: "news",
            backgroundColor:
                Colors.green.shade700,

            icon: const Icon(Icons.history),

            label: Text(
              tr(
                "News",
                "ማስታወቂያ",
                "beeksisa",
                code,
              ),
            ),

            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const DailyTipsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// =====================================================
// MINI CARD
// =====================================================

class _MiniCard extends StatelessWidget {
  final String title;
  final String sub;

  const _MiniCard({
    required this.title,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style:
              const TextStyle(
            color: Colors.white,
            fontWeight:
                FontWeight.bold,
            fontSize: 17,
          ),
        ),
        Text(
          sub,
          style:
              const TextStyle(
            color:
                Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// =====================================================
// FEATURE BOX
// =====================================================

class _FeatureBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color card;

  const _FeatureBox({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.card,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(
              14),
      decoration:
          BoxDecoration(
        color: card,
        borderRadius:
            BorderRadius.circular(
                16),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(
              height: 10),
          Text(
            title,
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(
              height: 4),
          Text(
            subtitle,
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              fontSize: 11,
              color: Colors
                  .grey
                  .shade600,
            ),
          ),
        ],
      ),
    );
  }
}