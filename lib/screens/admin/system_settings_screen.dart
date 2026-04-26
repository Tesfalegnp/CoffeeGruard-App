import 'package:flutter/material.dart';
import '../../core/services/settings_service.dart';
import '../../models/system_settings_model.dart';
import '../../core/services/sync_service.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() =>
      _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  final SettingsService _service = SettingsService();
  final SyncService _syncService = SyncService();

  SystemSettingsModel settings = SystemSettingsModel();
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    settings = await _service.loadSettings();
    setState(() => loading = false);
  }

  Future<void> _save() async {
    await _service.saveSettings(settings);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Settings saved successfully")),
    );
  }

  Future<void> _reset() async {
    await _service.resetSettings();
    settings = SystemSettingsModel();
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Settings reset")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("System Settings"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
          )
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [

                // ================= AI SETTINGS =================
                const Text("🤖 AI Settings",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                SwitchListTile(
                  title: const Text("Auto Approve (High Confidence)"),
                  value: settings.autoApprove,
                  onChanged: (v) {
                    setState(() => settings.autoApprove = v);
                  },
                ),

                ListTile(
                  title: const Text("Confidence Threshold"),
                  subtitle: Slider(
                    value: settings.confidenceThreshold,
                    min: 0,
                    max: 1,
                    divisions: 10,
                    label:
                        "${(settings.confidenceThreshold * 100).toInt()}%",
                    onChanged: (v) {
                      setState(() => settings.confidenceThreshold = v);
                    },
                  ),
                ),

                const Divider(),

                // ================= EXPERT =================
                const Text("👨‍🔬 Expert Workflow",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                SwitchListTile(
                  title: const Text("Require Expert Review"),
                  value: settings.requireExpertReview,
                  onChanged: (v) {
                    setState(() => settings.requireExpertReview = v);
                  },
                ),

                const Divider(),

                // ================= SYSTEM =================
                const Text("⚙ System Behavior",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                SwitchListTile(
                  title: const Text("Offline Mode"),
                  value: settings.offlineMode,
                  onChanged: (v) {
                    setState(() => settings.offlineMode = v);
                  },
                ),

                SwitchListTile(
                  title: const Text("Auto Sync"),
                  value: settings.autoSync,
                  onChanged: (v) {
                    setState(() => settings.autoSync = v);
                  },
                ),

                const Divider(),

                // ================= LANGUAGE =================
                const Text("🌐 Language",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                DropdownButton<String>(
                  value: settings.language,
                  items: const [
                    DropdownMenuItem(value: "en", child: Text("English")),
                    DropdownMenuItem(value: "am", child: Text("Amharic")),
                  ],
                  onChanged: (v) {
                    setState(() => settings.language = v!);
                  },
                ),

                const SizedBox(height: 30),

                // ================= ACTIONS =================
                ElevatedButton.icon(
                  icon: const Icon(Icons.sync),
                  label: const Text("Run Full Sync"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () async {
                    await _syncService.fullSync();
                  },
                ),

                const SizedBox(height: 10),

                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text("Reset Settings"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: _reset,
                ),
              ],
            ),
    );
  }
}