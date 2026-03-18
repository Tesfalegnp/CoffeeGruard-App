import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../widgets/image_picker_widget.dart';
import '../../core/services/detection_service.dart';
import '../../core/services/sync_service.dart';
import 'history_screen.dart';

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

    if (result["success"] == false) {
      setState(() {
        status = result["message"];
        isProcessing = false;
      });
      return;
    }

    final disease = result["disease"];
    final confidence = result["diseaseConfidence"];

    /// ✅ POPUP: Saved locally
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("💾 Saved locally"),
          duration: Duration(seconds: 2),
        ),
      );
    }

    /// ✅ CHECK INTERNET
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {

      /// ❌ No internet
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⚠️ No internet. Connect Wi-Fi to upload."),
            duration: Duration(seconds: 3),
          ),
        );
      }

    } else {

      /// ✅ Internet → sync
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

      status =
          "🌿 Disease: $disease\n"
          "Confidence: ${(confidence * 100).toStringAsFixed(2)}%";
    });
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

              /// 📸 Image Picker (ONLY image display here)
              ImagePickerWidget(
                onImageSelected: handleImage,
              ),

              const SizedBox(height: 20),

              /// ⏳ Loading
              if (isProcessing)
                const CircularProgressIndicator(),

              const SizedBox(height: 20),

              /// 🧾 Result
              Text(
                status,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              /// 📂 History
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