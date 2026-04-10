import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpertSettingsScreen extends StatefulWidget {
  const ExpertSettingsScreen({super.key});

  @override
  State<ExpertSettingsScreen> createState() => _ExpertSettingsScreenState();
}

class _ExpertSettingsScreenState extends State<ExpertSettingsScreen> {
  bool autoSync = true;
  bool notifications = true;
  bool lowConfidenceFlag = true;
  bool darkMode = false;
  double confidenceThreshold = 0.5;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      autoSync = prefs.getBool("autoSync") ?? true;
      notifications = prefs.getBool("notifications") ?? true;
      lowConfidenceFlag = prefs.getBool("lowConfidenceFlag") ?? true;
      darkMode = prefs.getBool("darkMode") ?? false;
      confidenceThreshold = prefs.getDouble("confidenceThreshold") ?? 0.5;
    });
  }

  Future<void> saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    }
  }

  Widget _toggle(String title, String key, bool value, Function(bool) onChange) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      activeColor: Colors.green,
      onChanged: (val) {
        setState(() {
          onChange(val);
        });
        saveSetting(key, val);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expert Settings"),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          const Text(
            "System Controls",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          _toggle("Auto Sync", "autoSync", autoSync, (v) => autoSync = v),

          _toggle("Notifications", "notifications", notifications,
              (v) => notifications = v),

          _toggle("Low Confidence Flagging", "lowConfidenceFlag",
              lowConfidenceFlag, (v) => lowConfidenceFlag = v),

          const SizedBox(height: 20),

          const Text(
            "AI Threshold Control",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Text("Confidence Threshold: ${confidenceThreshold.toStringAsFixed(2)}"),

          Slider(
            value: confidenceThreshold,
            min: 0.1,
            max: 1.0,
            divisions: 9,
            label: confidenceThreshold.toStringAsFixed(2),
            activeColor: Colors.green,
            onChanged: (val) {
              setState(() {
                confidenceThreshold = val;
              });
              saveSetting("confidenceThreshold", val);
            },
          ),

          const SizedBox(height: 20),

          const Divider(),

          const SizedBox(height: 10),

          const Text(
            "Danger Zone",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
          ),

          const SizedBox(height: 10),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            icon: const Icon(Icons.warning),
            label: const Text("Reset Expert Settings"),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Settings Reset")),
                );
              }
              loadSettings();
            },
          ),
        ],
      ),
    );
  }
}