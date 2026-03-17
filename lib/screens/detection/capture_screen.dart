import 'dart:io';
import 'package:flutter/material.dart';

import '../../widgets/image_picker_widget.dart';
import '../../core/utils/image_utils.dart';
import '../../core/services/detection_service.dart';
import '../../core/services/hive_service.dart';
import '../../core/services/sync_service.dart';
import '../../models/detection_result_model.dart';
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

    setState(() {
      selectedImage = image;
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

    final localPath = await ImageUtils.saveImageLocally(image);

    final detection = DetectionResultModel(

      id: DateTime.now().millisecondsSinceEpoch.toString(),

      imageLocalPath: localPath,

      imageUrl: null,

      isCoffeeLeaf: true,

      leafConfidence: result["leafConfidence"],

      diseaseLabel: disease,

      diseaseConfidence: confidence,

      recommendation: null,

      createdAt: DateTime.now(),

      isSynced: false,
    );

    await HiveService.saveDetection(detection);

    /// Trigger sync attempt
    await syncService.syncDetections();

    setState(() {

      isProcessing = false;

      status =
          "🌿 Disease: $disease\n"
          "Confidence: ${(confidence * 100).toStringAsFixed(2)}%\n"
          "💾 Saved locally\n"
          "☁ Sync attempted";

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

              ImagePickerWidget(
                onImageSelected: handleImage,
              ),

              const SizedBox(height: 20),

              if (selectedImage != null)
                Image.file(selectedImage!, height: 200),

              const SizedBox(height: 20),

              if (isProcessing)
                const CircularProgressIndicator(),

              const SizedBox(height: 20),

              Text(
                status,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

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