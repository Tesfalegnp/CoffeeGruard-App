import 'package:flutter/material.dart';

class ExpertGuideScreen extends StatelessWidget {
  const ExpertGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expert Guide"),
        backgroundColor: Colors.green,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          const Text(
            "📘 Expert System Guide",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          _card(
            "1. Queue Review",
            "Review AI detections from farmers.\nValidate disease predictions and correct mistakes.",
          ),

          _card(
            "2. Analytics",
            "Monitor disease trends and system performance.\nHelp improve AI accuracy.",
          ),

          _card(
            "3. Model Monitoring",
            "Check AI model accuracy and performance metrics.\nIdentify weak predictions.",
          ),

          _card(
            "4. Recommendations",
            "Update farming advice in English and Amharic.\nImprove farmer guidance quality.",
          ),

          _card(
            "5. Sync System",
            "Synchronize local and cloud data.\nEnsure real-time updates between farmer and expert.",
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange),
            ),
            child: const Text(
              "💡 Tip: Always prioritize high-severity disease cases first.",
            ),
          )
        ],
      ),
    );
  }

  Widget _card(String title, String desc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(desc),
          ],
        ),
      ),
    );
  }
}