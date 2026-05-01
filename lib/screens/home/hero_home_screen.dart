import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/image_picker_widget.dart';
import '../../core/services/detection_service.dart';
import '../../core/services/sync_service.dart';
import '../../core/services/hive_service.dart';
import '../../models/user_model.dart';
import '../detection/history_screen.dart';
import '../expert/expert_dashboard.dart';
import '../admin/admin_dashboard.dart';
import '../auth/login_screen.dart';
import '../../models/recommendation_model.dart';

// ===============================
// 📱 MAIN HOME SCREEN
// ===============================
class HeroHomeScreen extends StatefulWidget {
  const HeroHomeScreen({super.key});

  @override
  State<HeroHomeScreen> createState() => _HeroHomeScreenState();
}

class _HeroHomeScreenState extends State<HeroHomeScreen> {
  final DetectionService detectionService = DetectionService();
  final SyncService syncService = SyncService();
  final FlutterTts tts = FlutterTts();
  final ScrollController _scrollController = ScrollController();

  bool isProcessing = false;
  bool isSpeaking = false;
  bool isAmharic = false;
  bool isDarkMode = false;
  RecommendationModel? currentRecommendationModel;
  File? selectedImage;
  String? disease;
  double? confidence;
  String? recommendation;
  String displayedText = "";
  Timer? _typingTimer;
  bool isCoffeeLeaf = true;
  UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    detectionService.init();
    _initTTS();
    _loadPreferences();
    currentUser = HiveService.getCurrentUser();
  }

  void _initTTS() async {
    await tts.setSpeechRate(0.5);
    await tts.setPitch(1.0);
    await tts.setLanguage("en-US");
    tts.setCompletionHandler(() {
      setState(() => isSpeaking = false);
    });
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('darkMode') ?? false;
      isAmharic = prefs.getBool('isAmharic') ?? false;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', isDarkMode);
    await prefs.setBool('isAmharic', isAmharic);
  }

  Future<void> _speak(String text) async {
    if (text.isEmpty) return;
    await tts.stop();
    setState(() => isSpeaking = true);
    await tts.setLanguage(isAmharic ? "am-ET" : "en-US");
    await tts.speak(text);
  }

  Future<void> _stopSpeak() async {
    await tts.stop();
    setState(() => isSpeaking = false);
  }

  Future<void> handleImage(File image) async {
    _typingTimer?.cancel();
    await _stopSpeak();

    setState(() {
      selectedImage = image;
      isProcessing = true;
      disease = null;
      confidence = null;
      recommendation = null;
      displayedText = "";
      isCoffeeLeaf = true;
    });

    final result = await detectionService.runDetection(image);

    if (result["success"] == false) {
      setState(() {
        isProcessing = false;
        disease = "Sorry, This is Not a Coffee Leaf";
        recommendation = result["message"];
      });
      _startTyping(recommendation ?? "");
      _scrollToResult();
      return;
    }

    final detectedDisease = result["disease"];
    final detectedConfidence = result["diseaseConfidence"];

    if (detectedDisease.toLowerCase().contains("not") ||
        detectedDisease.toLowerCase().contains("unknown")) {
      setState(() {
        isCoffeeLeaf = false;
        disease = "Sorry this is Not a Coffee Leaf";
        confidence = detectedConfidence;
        recommendation = isAmharic
            ? "እባክዎ ግልጽ የቡና ቅጠል ያንሱ። ተፈጥሯዊ ብርሃን ይጠቀሙ፣ በአንድ ቅጠል ላይ ያተኩሩ እና ድብዘዛ ያስወግዱ።"
            : "Please capture a clear coffee leaf. Use natural light, focus on one leaf, and avoid blur.";
        isProcessing = false;
      });
      _startTyping(recommendation!);
      _scrollToResult();
      return;
    }

    final recModel = result["recommendationModel"];
    String detectedRecommendation;
    if (recModel != null) {
      detectedRecommendation = isAmharic
          ? (recModel.contentAm ?? recModel.content)
          : recModel.content;
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

    _startTyping(detectedRecommendation);
    _scrollToResult();
  }

  void _startTyping(String text) {
    displayedText = "";
    int index = 0;
    _typingTimer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (index < text.length) {
        setState(() {
          displayedText += text[index];
        });
        index++;
      } else {
        timer.cancel();
      }
    });
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
    if (disease.toLowerCase().contains("healthy")) {
      return isAmharic
          ? "ጤናማ ተክል። ክትትል ያድርጉ እና ትክክለኛ ውሃ ይጠብቁ።"
          : "Healthy plant. Keep monitoring and maintain proper watering.";
    }
    return isAmharic
        ? "በሽታ ተገኝቷል። የበሽታውን ቅጠሎች ያስወግዱ፣ ፀረ-ፈንገስ ይጠቀሙ እና በየቀኑ ይቆጣጠሩ።"
        : "Disease detected. Remove infected leaves, apply fungicide, and monitor daily.";
  }

  void _reset() async {
    _typingTimer?.cancel();
    await _stopSpeak();
    setState(() {
      selectedImage = null;
      disease = null;
      confidence = null;
      recommendation = null;
      displayedText = "";
      isProcessing = false;
      currentRecommendationModel = null;
    });
  }

  void _toggleLanguage() async {
    setState(() {
      isAmharic = !isAmharic;
      if (currentRecommendationModel != null) {
        recommendation = isAmharic
            ? (currentRecommendationModel!.contentAm ?? currentRecommendationModel!.content)
            : currentRecommendationModel!.content;
        _typingTimer?.cancel();
        _startTyping(recommendation!);
      }
    });
    await _savePreferences();
  }

  void _toggleTheme() async {
    setState(() {
      isDarkMode = !isDarkMode;
    });
    await _savePreferences();
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _scrollController.dispose();
    tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? _darkTheme() : _lightTheme(),
      home: Scaffold(
        drawer: _buildDrawer(context),
        appBar: _buildAppBar(),
        body: _buildBody(),
        floatingActionButton: _buildFloatingButton(),
      ),
    );
  }

  ThemeData _lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.green.shade700,
      colorScheme: ColorScheme.light(
        primary: Colors.green.shade700,
        secondary: Colors.green.shade300,
        tertiary: Colors.lime.shade400,
      ),
      scaffoldBackgroundColor: Colors.grey.shade50,
      cardTheme: const CardThemeData(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.green.shade400,
      colorScheme: ColorScheme.dark(
        primary: Colors.green.shade400,
        secondary: Colors.green.shade600,
        tertiary: Colors.lime.shade300,
      ),
      scaffoldBackgroundColor: Colors.grey.shade900,
      cardTheme: const CardThemeData(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.green.shade900,
        foregroundColor: Colors.white,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.eco, color: Colors.yellow.shade700),
          const SizedBox(width: 10),
          const Text("CoffeeGuard AI", style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
          onPressed: _toggleTheme,
          tooltip: isDarkMode ? "Light Mode" : "Dark Mode",
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          if (selectedImage == null) _buildImagePicker(),
          if (isProcessing && selectedImage != null) _buildProcessingWidget(),
          if (!isProcessing && disease != null) _buildResultCard(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade800,
            Colors.green.shade600,
            Colors.green.shade400,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.coffee, size: 40, color: Colors.white),
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Coffee Disease Detection",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "AI-Powered Analysis",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isAmharic
                        ? "ቡናዎን ለመጠበቅ የቅጠል ፎቶ ይንሱ"
                        : "Snap a leaf photo to protect your coffee",
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green.shade50, Colors.lime.shade50],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.green.shade200, width: 2),
        ),
        child: ImagePickerWidget(
          onImageSelected: handleImage,
        ),
      ),
    );
  }

  Widget _buildProcessingWidget() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(
                  selectedImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              const SizedBox(height: 15),
              Text(
                isAmharic ? "በመተንተን ላይ..." : "Analyzing your coffee leaf...",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final percent = confidence != null ? (confidence! * 100).toStringAsFixed(1) : "0";
    final statusColor = !isCoffeeLeaf
        ? Colors.orange
        : (disease != null && disease!.toLowerCase().contains("healthy"))
            ? Colors.green
            : Colors.red;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.green.shade50,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (selectedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      selectedImage!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor, width: 2),
                  ),
                  child: Text(
                    disease!,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (confidence != null) ...[
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isAmharic ? "ትክክለኛነት" : "Confidence",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text("$percent%", style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: confidence,
                            minHeight: 12,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation(statusColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lightbulb, color: Colors.amber.shade700),
                              const SizedBox(width: 8),
                              Text(
                                isAmharic ? "ምክር" : "Recommendation",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: TextButton.icon(
                              onPressed: _toggleLanguage,
                              icon: Icon(Icons.translate, color: Colors.green.shade700),
                              label: Text(
                                isAmharic ? "English" : "አማርኛ",
                                style: TextStyle(color: Colors.green.shade700),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        displayedText,
                        style: const TextStyle(height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (isSpeaking) {
                            _stopSpeak();
                          } else {
                            _speak(recommendation ?? "");
                          }
                        },
                        icon: Icon(isSpeaking ? Icons.stop : Icons.volume_up),
                        label: Text(isSpeaking 
                            ? (isAmharic ? "አቁም" : "Stop") 
                            : (isAmharic ? "ማንበብ" : "Read Aloud")),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _reset,
                        icon: const Icon(Icons.camera_alt),
                        label: Text(isAmharic ? "እንደገና ፎቶ አንሳ" : "Scan Again"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green.shade700,
                          side: BorderSide(color: Colors.green.shade700),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _reset,
                        icon: const Icon(Icons.clear),
                        label: Text(isAmharic ? "አጽዳ" : "Clear"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade700,
                          side: BorderSide(color: Colors.red.shade700),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingButton() {
    return FloatingActionButton.extended(
      onPressed: _reset,
      icon: const Icon(Icons.photo_camera),
      label: Text(isAmharic ? "አዲስ ፎቶ" : "New Scan"),
      backgroundColor: Colors.green.shade600,
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final role = currentUser?.role;

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade700, Colors.green.shade500],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.eco, size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "CoffeeGuard AI",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    if (currentUser != null)
                      Text(
                        currentUser!.email ?? "",
                        style: const TextStyle(color: Colors.white70),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  children: [
                    _buildDrawerItem(
                      icon: Icons.history,
                      title: isAmharic ? "ታሪክ" : "History",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HistoryScreen()),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.settings,
                      title: isAmharic ? "ቅንብሮች" : "Settings",
                      onTap: () {
                        _showSettingsDialog();
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.language,
                      title: isAmharic ? "ቋንቋ" : "Language",
                      trailing: Switch(
                        value: isAmharic,
                        onChanged: (val) => _toggleLanguage(),
                        activeColor: Colors.green,
                      ),
                    ),
                    _buildDrawerItem(
                      icon: isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      title: isAmharic ? "ጨለማ ሁነታ" : "Dark Mode",
                      trailing: Switch(
                        value: isDarkMode,
                        onChanged: (val) => _toggleTheme(),
                        activeColor: Colors.green,
                      ),
                    ),
                    if (role == "expert")
                      _buildDrawerItem(
                        icon: Icons.dashboard_customize,
                        title: isAmharic ? "የባለሙያ ዳሽቦርድ" : "Expert Dashboard",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ExpertDashboard()),
                          );
                        },
                      ),
                    if (role == "admin")
                      _buildDrawerItem(
                        icon: Icons.admin_panel_settings,
                        title: isAmharic ? "አስተዳዳሪ ዳሽቦርድ" : "Admin Dashboard",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AdminDashboard()),
                          );
                        },
                      ),
                    const Divider(height: 2, thickness: 1),
                    _buildDrawerItem(
                      icon: Icons.info_outline,
                      title: isAmharic ? "ስለ እኛ" : "About",
                      onTap: () => _showAboutDialog(),
                    ),
                    _buildDrawerItem(
                      icon: Icons.help_outline,
                      title: isAmharic ? "እገዛ" : "Help",
                      onTap: () => _showHelpDialog(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: currentUser == null
                    ? ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.login),
                        label: Text(isAmharic ? "ግባ" : "Login"),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                          setState(() {
                            currentUser = HiveService.getCurrentUser();
                          });
                        },
                      )
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.logout),
                        label: Text(isAmharic ? "ውጣ" : "Logout"),
                        onPressed: () async {
                          await HiveService.clearUserSession();
                          setState(() {
                            currentUser = null;
                          });
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.green.shade700),
      title: Text(title, style: TextStyle(color: Colors.grey.shade800)),
      trailing: trailing,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      hoverColor: Colors.green.shade50,
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAmharic ? "ቅንብሮች" : "Settings"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text(isAmharic ? "አማርኛ ቋንቋ" : "Amharic Language"),
              value: isAmharic,
              onChanged: (val) {
                _toggleLanguage();
                Navigator.pop(context);
              },
              activeColor: Colors.green,
            ),
            SwitchListTile(
              title: Text(isAmharic ? "ጨለማ ሁነታ" : "Dark Mode"),
              value: isDarkMode,
              onChanged: (val) {
                _toggleTheme();
                Navigator.pop(context);
              },
              activeColor: Colors.green,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isAmharic ? "ዝጋ" : "Close"),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAmharic ? "ስለ CoffeeGuard" : "About CoffeeGuard"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.eco, size: 60, color: Colors.green),
            const SizedBox(height: 10),
            Text(
              isAmharic
                  ? "CoffeeGuard የቡና በሽታዎችን ለመለየት AI የሚጠቀም በጣም ዘመናዊ መተግበሪያ ነው።"
                  : "CoffeeGuard is an advanced mobile application that uses AI to detect coffee leaf diseases.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              isAmharic ? "ስሪት 2.0.0" : "Version 2.0.0",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isAmharic ? "ዝጋ" : "Close"),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAmharic ? "እገዛ" : "Help"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAmharic
                  ? "1. ጥሩ ብርሃን ባለበት የቡና ቅጠል ፎቶ ይንሱ\n2. ፎቶው ግልጽ እና አንድ ቅጠል ላይ ያተኮረ ይሁን\n3. መተግበሪያው በሽታውን ይተነትናል\n4. ምክሮችን ይከተሉ"
                  : "1. Take a photo of a coffee leaf in good lighting\n2. Ensure the photo is clear and focused on one leaf\n3. The app will analyze the disease\n4. Follow the recommendations provided",
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isAmharic ? "ዝጋ" : "Close"),
          ),
        ],
      ),
    );
  }
}