import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../widgets/image_picker_widget.dart';
import '../../core/services/detection_service.dart';
import '../../core/services/sync_service.dart';
import 'history_screen.dart';
import 'result_screen.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {

  final DetectionService detectionService = DetectionService();
  final SyncService syncService = SyncService();

  bool isProcessing = false;
  String status = "";

  @override
  void initState() {
    super.initState();
    _initModel();
  }

  Future<void> _initModel() async {
    await detectionService.init();
  }

  Future<void> handleImage(File image) async {

    setState(() {
      isProcessing = true;
      status = "🔍 Processing image...";
    });

    final result = await detectionService.runDetection(image);

    /// ❌ Detection failed
    if (result["success"] == false) {
      setState(() {
        status = result["message"];
        isProcessing = false;
      });
      return;
    }

    /// ✅ Extract results
    final disease = result["disease"];
    final confidence = result["diseaseConfidence"];
    final recommendation =
        result["recommendation"] ?? "No recommendation available";

    /// 💾 Saved locally
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("💾 Saved locally"),
          duration: Duration(seconds: 2),
        ),
      );
    }

    /// 🌐 Check internet
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {

      /// ❌ No internet
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⚠️ No internet. Will sync later."),
            duration: Duration(seconds: 3),
          ),
        );
      }

    } else {

      /// ☁ Upload in background
      syncService.syncDetections().then((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("☁ Upload completed"),
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
    }

    setState(() {
      isProcessing = false;
      status = "";
    });

    /// 🚀 Navigate to Result Screen
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            image: image,
            disease: disease,
            confidence: confidence,
            recommendation: recommendation,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Coffee Detection"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: SingleChildScrollView(
          child: Column(

            children: [

              /// 📸 Image Picker
              ImagePickerWidget(
                onImageSelected: handleImage,
              ),

              const SizedBox(height: 20),

              /// ⏳ Loading
              if (isProcessing)
                Column(
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text("Processing... please wait"),
                  ],
                ),

              const SizedBox(height: 20),

              /// 🧾 Status
              if (status.isNotEmpty)
                Text(
                  status,
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 20),

              /// 📂 History Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HistoryScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.folder),
                label: const Text("View Saved Detections"),
              )
            ],
          ),
        ),
      ),
    );
  }
}