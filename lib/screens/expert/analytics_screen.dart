import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {

  // 🔥 TEMP LOCAL DATA (NO REPOSITORY ERROR)
  int total = 25;
  int rust = 10;
  int healthy = 12;
  int rejected = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Real Analytics Engine"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ================= KPI CARDS =================
            Row(
              children: [
                _kpiCard("Total", total, Colors.blue),
                _kpiCard("Rust", rust, Colors.red),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _kpiCard("Healthy", healthy, Colors.green),
                _kpiCard("Rejected", rejected, Colors.orange),
              ],
            ),

            const SizedBox(height: 20),

            // ================= PIE CHART =================
            const Text(
              "Disease Distribution",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: rust.toDouble(),
                      title: "Rust",
                      color: Colors.red,
                    ),
                    PieChartSectionData(
                      value: healthy.toDouble(),
                      title: "Healthy",
                      color: Colors.green,
                    ),
                    PieChartSectionData(
                      value: rejected.toDouble(),
                      title: "Other",
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================= LINE CHART =================
            const Text(
              "Detection Trend",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 2),
                        FlSpot(1, 3),
                        FlSpot(2, 2),
                        FlSpot(3, 4),
                        FlSpot(4, 3),
                      ],
                      isCurved: true,
                      color: Colors.green,
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

  Widget _kpiCard(String title, int value, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(title,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(
                value.toString(),
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}