import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../widgets/image_picker_widget.dart';
import '../../core/services/detection_service.dart';
import '../../core/services/sync_service.dart';
import '../detection/history_screen.dart';

class HeroHomeScreen extends StatefulWidget {
  const HeroHomeScreen({super.key});

  @override
  State<HeroHomeScreen> createState() => _HeroHomeScreenState();
}

class _HeroHomeScreenState extends State<HeroHomeScreen> {

  final DetectionService detectionService = DetectionService();
  final SyncService syncService = SyncService();

  final ScrollController _scrollController = ScrollController();

  bool isProcessing = false;

  File? selectedImage;
  String? disease;
  double? confidence;
  String? recommendation;

  String displayedText = "";
  Timer? _typingTimer;

  bool isCoffeeLeaf = true;

  @override
  void initState() {
    super.initState();
    detectionService.init();
  }

  Future<void> handleImage(File image) async {

    _typingTimer?.cancel();

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
        disease = "Detection Failed";
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
        disease = "Not a Coffee Leaf";
        confidence = detectedConfidence;
        recommendation =
            "Please capture a clear coffee leaf.\n\n• Use natural light\n• Focus one leaf\n• Avoid blur";
        isProcessing = false;
      });

      _startTyping(recommendation!);
      _scrollToResult();
      return;
    }

    final detectedRecommendation =
        result["recommendation"] ?? _smartRecommendation(detectedDisease);

    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult != ConnectivityResult.none) {
      syncService.syncDetections();
    }

    setState(() {
      disease = detectedDisease;
      confidence = detectedConfidence;
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
      return "Healthy plant 🌿\n\nKeep monitoring and maintain watering.";
    }
    return "Disease detected ⚠️\n\n• Remove infected leaves\n• Apply fungicide\n• Monitor daily";
  }

  void _reset() {
    _typingTimer?.cancel();

    setState(() {
      selectedImage = null;
      disease = null;
      confidence = null;
      recommendation = null;
      displayedText = "";
      isProcessing = false;
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final percent =
        confidence != null ? (confidence! * 100).toStringAsFixed(1) : "0";

    final statusColor = !isCoffeeLeaf
        ? Colors.orange
        : (disease != null && disease!.toLowerCase().contains("healthy"))
            ? Colors.green
            : Colors.red;

    return Scaffold(
      drawer: _buildDrawer(context),

      appBar: AppBar(
        title: const Text("CoffeeGuard"),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
      ),

      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [

            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.shade700,
                    Colors.green.shade400
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "CoffeeGuard",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "AI coffee disease detection",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// PICKER
            if (selectedImage == null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ImagePickerWidget(
                  onImageSelected: handleImage,
                ),
              ),

            /// PROCESSING
            if (isProcessing && selectedImage != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(
                        selectedImage!,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 10),
                    const Text("Processing..."),
                  ],
                ),
              ),

            /// RESULT
            if (!isProcessing && disease != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [

                        /// ✅ IMAGE FIRST (NEW)
                        if (selectedImage != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              selectedImage!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),

                        const SizedBox(height: 15),

                        Text(
                          disease!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),

                        const SizedBox(height: 10),

                        if (confidence != null)
                          Column(
                            children: [
                              LinearProgressIndicator(value: confidence),
                              const SizedBox(height: 5),
                              Text("Confidence: $percent%"),
                            ],
                          ),

                        const SizedBox(height: 20),

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "💡 Recommendation",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(displayedText),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _reset,
                                icon: const Icon(Icons.camera_alt),
                                label: const Text("Scan Again"),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _reset,
                                icon: const Icon(Icons.clear),
                                label: const Text("Clear"),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [

          DrawerHeader(
            decoration: BoxDecoration(color: Colors.green.shade700),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.eco, size: 40, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  "CoffeeGuard",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("History"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}