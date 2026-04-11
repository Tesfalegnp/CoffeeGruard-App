import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../providers/admin_provider.dart';

class SystemAnalyticsScreen extends StatefulWidget {
  const SystemAnalyticsScreen({super.key});

  @override
  State<SystemAnalyticsScreen> createState() =>
      _SystemAnalyticsScreenState();
}

class _SystemAnalyticsScreenState
    extends State<SystemAnalyticsScreen> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<AdminProvider>(context, listen: false)
            .loadAnalytics());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("System Analytics"),
        backgroundColor: Colors.green,
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [

                // ===== KPI =====
                Row(
                  children: [
                    _card("Total", provider.totalDetections),
                    _card("Today", provider.todayDetections),
                  ],
                ),

                Row(
                  children: [
                    _card("Reviewed", provider.reviewed),
                    _card("Pending", provider.pending),
                  ],
                ),

                const SizedBox(height: 20),

                const Text("Detections Trend (7 days)"),

                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: provider.dailyDetections.entries
                              .toList()
                              .asMap()
                              .entries
                              .map((e) => FlSpot(
                                  e.key.toDouble(),
                                  e.value.value.toDouble()))
                              .toList(),
                          isCurved: true,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text("Disease Distribution"),

                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: provider.diseaseCount.entries
                          .map((e) => PieChartSectionData(
                                value: e.value.toDouble(),
                                title: e.key,
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _card(String t, int v) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Text(t),
              Text(
                "$v",
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}