import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ModelPerformanceScreen extends StatelessWidget {
  const ModelPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Model Performance Engine"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Model Metrics Overview",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Row(
              children: const [
                Expanded(child: _MetricCard(title: "Accuracy", value: "92%")),
                Expanded(child: _MetricCard(title: "Precision", value: "89%")),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: const [
                Expanded(child: _MetricCard(title: "Recall", value: "91%")),
                Expanded(child: _MetricCard(title: "F1 Score", value: "90%")),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              "Error Distribution",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: 5,
                      title: "FP",
                      color: Colors.red,
                    ),
                    PieChartSectionData(
                      value: 3,
                      title: "FN",
                      color: Colors.orange,
                    ),
                    PieChartSectionData(
                      value: 92,
                      title: "Correct",
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Confidence Trend",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 0.80),
                        FlSpot(1, 0.85),
                        FlSpot(2, 0.78),
                        FlSpot(3, 0.90),
                        FlSpot(4, 0.92),
                      ],
                      isCurved: true,
                      color: Colors.blue,
                      dotData: const FlDotData(show: false),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;

  const _MetricCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}