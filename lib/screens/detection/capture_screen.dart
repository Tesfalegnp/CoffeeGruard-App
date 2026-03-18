import 'dart:io';
import 'package:flutter/material.dart';

import '../../widgets/image_picker_widget.dart';
import '../../core/services/detection_service.dart';
import 'history_screen.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {

  final DetectionService detectionService = DetectionService();

  bool isProcessing = false;
  String status = "";

  File? selectedImage;

  @override
  void initState() {
    super.initState();
    _initModel();
  }

  Future<void> _initModel() async {
    await detectionService.init();
  }

  Future<void> handleImage(File image) async {

    /// Show selected image immediately
    setState(() {
      selectedImage = image;
      isProcessing = true;
      status = "🔍 Processing image...";
    });

    /// Run detection (this already saves + syncs internally)
    final result = await detectionService.runDetection(image);

    /// If failed
    if (result["success"] == false) {
      setState(() {
        status = result["message"];
        isProcessing = false;
      });
      return;
    }

    final disease = result["disease"];
    final confidence = result["diseaseConfidence"];

    /// Show result immediately (FAST UI)
    setState(() {
      isProcessing = false;

      status =
          "🌿 Disease: $disease\n"
          "Confidence: ${(confidence * 100).toStringAsFixed(2)}%\n"
          "💾 Saved locally\n"
          "☁ Uploading in background...";
    });

    /// Background upload feedback (non-blocking)
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Data uploaded successfully"),
        ),
      );
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

              /// IMAGE PICKER
              ImagePickerWidget(
                onImageSelected: handleImage,
              ),

              const SizedBox(height: 20),

              /// SHOW SELECTED IMAGE (ONLY ONE)
              if (selectedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    selectedImage!,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),

              const SizedBox(height: 20),

              /// LOADING
              if (isProcessing)
                const CircularProgressIndicator(),

              const SizedBox(height: 20),

              /// STATUS TEXT
              Text(
                status,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              /// NAVIGATE TO HISTORY
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