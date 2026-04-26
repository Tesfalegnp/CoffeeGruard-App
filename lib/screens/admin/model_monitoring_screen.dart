import 'package:flutter/material.dart';
import '../../core/services/model_monitor_service.dart';

class ModelMonitoringScreen extends StatefulWidget {
  const ModelMonitoringScreen({super.key});

  @override
  State<ModelMonitoringScreen> createState() =>
      _ModelMonitoringScreenState();
}

class _ModelMonitoringScreenState
    extends State<ModelMonitoringScreen> {

  final ModelMonitorService _service = ModelMonitorService();

  List<Map<String, dynamic>> data = [];
  bool loading = true;

  double accuracy = 0;
  double errorRate = 0;

  Map<String, int> mistakes = {};

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);

    try {
      data = await _service.getEvaluations();

      accuracy = _service.calculateAccuracy(data);
      errorRate = _service.calculateErrorRate(data);

      mistakes = _service.getMisclassified(data);

    } catch (e) {
      print("❌ Model monitoring load error: $e");
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Model Monitoring"),
        backgroundColor: Colors.green, // ✅ FIXED (consistent theme)
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [

                  // ================= KPI CARDS =================
                  Row(
                    children: [
                      Expanded(
                        child: _card(
                          "Accuracy",
                          "${accuracy.toStringAsFixed(1)}%",
                          Colors.green,
                        ),
                      ),
                      Expanded(
                        child: _card(
                          "Error",
                          "${errorRate.toStringAsFixed(1)}%",
                          Colors.red,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ================= MISTAKES =================
                  const Text(
                    "Misclassified Patterns",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green, // optional consistency touch
                    ),
                  ),

                  const SizedBox(height: 10),

                  if (mistakes.isEmpty)
                    const Text(
                      "No misclassifications found 🎉",
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    ...mistakes.entries.map((e) {
                      return Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.error,
                            color: Colors.red,
                          ),
                          title: Text(e.key),
                          trailing: Text("x${e.value}"),
                        ),
                      );
                    }),

                  const SizedBox(height: 20),

                  // ================= RAW DATA =================
                  const Text(
                    "Recent Evaluations",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green, // optional consistency touch
                    ),
                  ),

                  const SizedBox(height: 10),

                  ...data.take(10).map((d) {
                    return Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.analytics,
                          color: Colors.green,
                        ),
                        title: Text("AI: ${d['disease_label']}"),
                        subtitle: Text("Expert: ${d['severity']}"),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }

  // ================= CARD =================
  Widget _card(String t, String v, Color c) {
    return Card(
      color: c.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              t,
              style: TextStyle(
                color: c,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              v,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}