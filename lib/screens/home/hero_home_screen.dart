import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../widgets/image_picker_widget.dart';
import '../../widgets/home/home_header.dart';
import '../../widgets/home/processing_widget.dart';
import '../../widgets/home/result_card.dart';
import '../../widgets/home/custom_drawer.dart';
import '../../core/services/detection_service.dart';
import '../../core/services/sync_service.dart';
import '../../core/services/hive_service.dart';
import '../../core/services/language_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/text_animator.dart';
import '../../models/user_model.dart';
import '../../models/recommendation_model.dart';

class HeroHomeScreen extends StatefulWidget {
  const HeroHomeScreen({super.key});

  @override
  State<HeroHomeScreen> createState() => _HeroHomeScreenState();
}

class _HeroHomeScreenState extends State<HeroHomeScreen> with SingleTickerProviderStateMixin {
  final DetectionService detectionService = DetectionService();
  final SyncService syncService = SyncService();
  final FlutterTts tts = FlutterTts();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final TextAnimator _textAnimator = TextAnimator();

  bool isProcessing = false;
  bool isSpeaking = false;
  bool isDarkMode = false;
  RecommendationModel? currentRecommendationModel;
  File? selectedImage;
  String? disease;
  double? confidence;
  String? recommendation;
  bool isCoffeeLeaf = true;
  UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    detectionService.init();
    _initTTS();
    _loadPreferences();
    currentUser = HiveService.getCurrentUser();
    
    // Initialize language service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LanguageService>(context, listen: false).init();
    });
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(_pulseController);
  }

  Future<void> _initTTS() async {
    await tts.setSpeechRate(0.5);
    await tts.setPitch(1.0);
    final lang = Provider.of<LanguageService>(context, listen: false);
    await tts.setLanguage(lang.languageCode == 'am' ? "am-ET" : 
                          lang.languageCode == 'om' ? "om-ET" : "en-US");
    tts.setCompletionHandler(() {
      setState(() => isSpeaking = false);
    });
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', isDarkMode);
  }

  Future<void> _speak(String text) async {
    if (text.isEmpty) return;
    await tts.stop();
    setState(() => isSpeaking = true);
    final lang = Provider.of<LanguageService>(context, listen: false);
    await tts.setLanguage(lang.languageCode == 'am' ? "am-ET" : 
                          lang.languageCode == 'om' ? "om-ET" : "en-US");
    await tts.speak(text);
  }

  Future<void> _stopSpeak() async {
    await tts.stop();
    setState(() => isSpeaking = false);
  }

  Future<void> handleImage(File image) async {
    await _stopSpeak();

    setState(() {
      selectedImage = image;
      isProcessing = true;
      disease = null;
      confidence = null;
      recommendation = null;
      isCoffeeLeaf = true;
    });

    final result = await detectionService.runDetection(image);

    if (result["success"] == false) {
      final lang = Provider.of<LanguageService>(context, listen: false);
      setState(() {
        isProcessing = false;
        disease = lang.translate(
          "Sorry, This is Not a Coffee Leaf",
          "ይቅርታ, ይህ የቡና ቅጠል አይደለም",
          "Dhiifama, Kun Baala Kubbaa Mitii",
        );
        recommendation = result["message"];
      });
      _animateRecommendation(recommendation ?? "");
      _scrollToResult();
      return;
    }

    final detectedDisease = result["disease"];
    final detectedConfidence = double.parse(result["confidence"].toString()) / 100;

    if (detectedDisease.toLowerCase().contains("not") ||
        detectedDisease.toLowerCase().contains("unknown")) {
      final lang = Provider.of<LanguageService>(context, listen: false);
      setState(() {
        isCoffeeLeaf = false;
        disease = lang.translate(
          "Sorry, This is Not a Coffee Leaf",
          "ይቅርታ, ይህ የቡና ቅጠል አይደለም",
          "Dhiifama, Kun Baala Kubbaa Mitii",
        );
        confidence = detectedConfidence;
        recommendation = lang.translate(
          "Please capture a clear coffee leaf. Use natural light, focus on one leaf, and avoid blur.",
          "እባክዎ ግልጽ የቡና ቅጠል ያንሱ። ተፈጥሯዊ ብርሃን ይጠቀሙ፣ በአንድ ቅጠል ላይ ያተኩሩ እና ድብዘዛ ያስወግዱ።",
          "Mee baala kubbaa ifa ta'e fudhadhu. Ifa uumamaa fayyadami, baala tokko iratti xiyyeeffadhu, fi tasgabbii dhorki.",
        );
        isProcessing = false;
      });
      _animateRecommendation(recommendation!);
      _scrollToResult();
      return;
    }

    final recModel = result["recommendationModel"];
    String detectedRecommendation;
    if (recModel != null) {
      final lang = Provider.of<LanguageService>(context, listen: false);
      if (lang.isAmharic) {
        detectedRecommendation = recModel.contentAm ?? recModel.content;
      } else if (lang.isOromo) {
        detectedRecommendation = recModel.contentOm ?? recModel.content;
      } else {
        detectedRecommendation = recModel.content;
      }
    } else {
      detectedRecommendation = _smartRecommendation(detectedDisease);
    }

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      syncService.syncDetections();
    }

    setState(() {
      disease = detectedDisease;
      confidence = detectedConfidence;
      currentRecommendationModel = recModel;
      recommendation = detectedRecommendation;
      isProcessing = false;
    });

    _animateRecommendation(detectedRecommendation);
    _scrollToResult();
  }

  void _animateRecommendation(String text) {
    _textAnimator.animateText(
      fullText: text,
      onUpdate: () => setState(() {}),
    );
  }

  void _scrollToResult() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  String _smartRecommendation(String disease) {
    final lang = Provider.of<LanguageService>(context, listen: false);
    
    if (disease.toLowerCase().contains("healthy")) {
      return lang.translate(
        "Healthy plant. Keep monitoring and maintain proper watering.",
        "ጤናማ ተክል። ክትትል ያድርጉ እና ትክክለኛ ውሃ ይጠብቁ።",
        "Biqilgaa fayyaa qabu. Ilaalcha irraa eegii fi bishaan bu'aa eegi.",
      );
    }
    if (disease.toLowerCase().contains("rust")) {
      return lang.translate(
        "Coffee Rust disease detected. Remove infected leaves, apply copper-based fungicide, and monitor daily.",
        "የቡና ዝገት በሽታ ተገኝቷል። የበሽታውን ቅጠሎች ያስወግዱ፣ መዳብ ላይ የተመሰረተ ፀረ-ፈንገስ ይጠቀሙ እና በየቀኑ ይቆጣጠሩ።",
        "Dhukkubaan Kubbaa Dhullaa'e. Baalota dhukkubsatan balleessi, farra-fungusii kan koppira irratti hundoofte fayyadami, fi guyyatti ilaali.",
      );
    }
    return lang.translate(
      "Disease detected. Remove infected leaves, apply appropriate fungicide, and monitor daily.",
      "በሽታ ተገኝቷል። የበሽታውን ቅጠሎች ያስወግዱ፣ ተገቢውን ፀረ-ፈንገስ ይጠቀሙ እና በየቀኑ ይቆጣጠሩ።",
      "Dhukkubni argame. Baalota dhukkubsatan balleessi, farra-fungusii madaalawaa fayyadami, fi guyyatti ilaali.",
    );
  }

  void _reset() async {
    await _stopSpeak();
    setState(() {
      selectedImage = null;
      disease = null;
      confidence = null;
      recommendation = null;
      isProcessing = false;
      currentRecommendationModel = null;
    });
  }

  void _toggleLanguage() async {
    final lang = Provider.of<LanguageService>(context, listen: false);
    
    // Cycle through languages
    if (lang.isEnglish) {
      await lang.setLanguage(AppLanguage.amharic);
    } else if (lang.isAmharic) {
      await lang.setLanguage(AppLanguage.oromo);
    } else {
      await lang.setLanguage(AppLanguage.english);
    }
    
    // Update displayed text based on new language
    if (currentRecommendationModel != null) {
      String newRecommendation;
      if (lang.isAmharic) {
        newRecommendation = currentRecommendationModel!.contentAm ?? currentRecommendationModel!.content;
      } else if (lang.isOromo) {
        newRecommendation = currentRecommendationModel!.contentOm ?? currentRecommendationModel!.content;
      } else {
        newRecommendation = currentRecommendationModel!.content;
      }
      setState(() {
        recommendation = newRecommendation;
      });
      _animateRecommendation(newRecommendation);
    } else if (disease != null && !isCoffeeLeaf) {
      final newRecommendation = _smartRecommendation(disease!);
      setState(() {
        recommendation = newRecommendation;
      });
      _animateRecommendation(newRecommendation);
    } else if (disease != null && recommendation != null) {
      final newRecommendation = _smartRecommendation(disease!);
      setState(() {
        recommendation = newRecommendation;
      });
      _animateRecommendation(newRecommendation);
    }
    
    await _initTTS();
  }

  void _toggleTheme() async {
    setState(() {
      isDarkMode = !isDarkMode;
    });
    await _savePreferences();
  }

  void _updateUser() {
    setState(() {
      currentUser = HiveService.getCurrentUser();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pulseController.dispose();
    _textAnimator.dispose();
    tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageService()),
      ],
      child: Consumer<LanguageService>(
        builder: (context, lang, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(isDarkMode),
            home: Scaffold(
              drawer: CustomDrawer(
                isDarkMode: isDarkMode,
                currentUser: currentUser,
                onLanguageToggle: _toggleLanguage,
                onThemeToggle: _toggleTheme,
                onUserUpdate: _updateUser,
              ),
              appBar: _buildAppBar(lang),
              body: _buildBody(lang),
              floatingActionButton: _buildFloatingButton(lang),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(LanguageService lang) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: Icon(Icons.eco, color: Colors.yellow.shade700, size: 28),
          ),
          const SizedBox(width: 10),
          Text("CoffeeGuard AI", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        ],
      ),
      actions: [
        IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              key: ValueKey(isDarkMode),
            ),
          ),
          onPressed: _toggleTheme,
          tooltip: lang.translate("Light Mode", "ብርሃን ሁነታ", "Haala Ifaa"),
        ),
      ],
    );
  }

  Widget _buildBody(LanguageService lang) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          HomeHeader(isDarkMode: isDarkMode),
          const SizedBox(height: 20),
          if (selectedImage == null) _buildImagePickerContainer(lang),
          if (isProcessing && selectedImage != null) ProcessingWidget(selectedImage: selectedImage!),
          if (!isProcessing && disease != null) _buildResultCard(lang),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildImagePickerContainer(LanguageService lang) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode 
                ? [Colors.grey.shade800, Colors.grey.shade700]
                : [Colors.green.shade50, Colors.lime.shade50],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isDarkMode ? Colors.green.shade400 : Colors.green.shade200,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            ImagePickerWidget(
              onImageSelected: handleImage,
            ),
            if (selectedImage == null)
              Positioned.fill(
                child: Center(
                  child: ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.green.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(LanguageService lang) {
    return ResultCard(
      selectedImage: selectedImage,
      disease: disease!,
      confidence: confidence,
      recommendation: recommendation ?? "",
      currentRecommendationModel: currentRecommendationModel,
      isCoffeeLeaf: isCoffeeLeaf,
      onReset: _reset,
      onLanguageToggle: _toggleLanguage,
      tts: tts,
      isSpeaking: isSpeaking,
      onSpeak: () => _speak(recommendation ?? ""),
      onStopSpeak: _stopSpeak,
      textAnimator: _textAnimator,
      displayedText: _textAnimator.displayedText,
    );
  }

  Widget _buildFloatingButton(LanguageService lang) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: FloatingActionButton.extended(
        onPressed: _reset,
        icon: const Icon(Icons.photo_camera),
        label: Text(lang.translate("New Scan", "አዲስ ፎቶ", "Fudhanna Haaraa")),
        backgroundColor: Colors.green.shade600,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}