import 'package:flutter/material.dart';

class ModelPerformanceScreen extends StatelessWidget {
  const ModelPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Model Performance"),
        backgroundColor: Colors.green,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Accuracy: 92%"),
            Text("False Positives: 5%"),
            Text("False Negatives: 3%"),
          ],
        ),
      ),
    );
  }
}