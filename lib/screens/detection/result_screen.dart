import 'dart:io';
import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final File image;
  final String disease;
  final double confidence;
  final String recommendation;

  const ResultScreen({
    super.key,
    required this.image,
    required this.disease,
    required this.confidence,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (confidence * 100).toStringAsFixed(2);

    Color statusColor;
    if (disease.toLowerCase().contains("healthy")) {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.red;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detection Result"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// 📸 IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                image,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            /// 🌿 DISEASE NAME
            Text(
              disease,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),

            const SizedBox(height: 10),

            /// 📊 CONFIDENCE BAR
            Column(
              children: [
                LinearProgressIndicator(
                  value: confidence,
                  minHeight: 10,
                ),
                const SizedBox(height: 5),
                Text("Confidence: $percent%"),
              ],
            ),

            const SizedBox(height: 20),

            /// 💡 RECOMMENDATION CARD
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "💡 Recommendation",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(recommendation),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 🔙 BACK BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Back"),
              ),
            )
          ],
        ),
      ),
    );
  }
}