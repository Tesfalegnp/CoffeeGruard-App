import 'package:flutter/material.dart';

class ResultCard extends StatelessWidget {
  final String disease;
  final double confidence;
  final String recommendation;
  final String displayedText;
  final bool isCoffeeLeaf;
  final bool isSpeaking;
  final VoidCallback onSpeakToggle;
  final VoidCallback onReset;

  const ResultCard({
    super.key,
    required this.disease,
    required this.confidence,
    required this.recommendation,
    required this.displayedText,
    required this.isCoffeeLeaf,
    required this.isSpeaking,
    required this.onSpeakToggle,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (confidence * 100).toStringAsFixed(1);

    final color = !isCoffeeLeaf
        ? Colors.orange
        : disease.toLowerCase().contains("healthy")
            ? Colors.green
            : Colors.red;

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: value,
            child: child,
          ),
        );
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade50,
                Colors.white,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Disease Name with Icon
                Row(
                  children: [
                    Icon(
                      disease.toLowerCase().contains("healthy")
                          ? Icons.check_circle
                          : Icons.warning,
                      color: color,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        disease,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// Confidence Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Confidence",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "$percent%",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: confidence,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// Recommendation Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.eco, size: 20, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            "💡 Recommendation",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        displayedText,
                        style: const TextStyle(height: 1.5),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onSpeakToggle,
                        icon: Icon(
                          isSpeaking ? Icons.stop : Icons.volume_up,
                        ),
                        label: Text(
                          isSpeaking ? "Stop" : "Speak",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onReset,
                        icon: const Icon(Icons.refresh),
                        label: const Text(
                          "Scan Again",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}