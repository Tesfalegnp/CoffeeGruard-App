import 'dart:io';
import 'package:flutter/material.dart';

import '../../core/services/hive_service.dart';
import '../../core/services/sync_service.dart';
import '../../models/detection_result_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

  List<DetectionResultModel> detections = [];
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    loadDetections();
  }

  void loadDetections() {
    final data = HiveService.getAllDetections();

    setState(() {
      detections = data.reversed.toList();
    });
  }

  /// 📊 CALCULATE INSIGHTS (NEW 🔥)
  int get total => detections.length;

  int get healthy => detections
      .where((d) =>
          (d.diseaseLabel ?? "").toLowerCase().contains("healthy"))
      .length;

  int get diseased => total - healthy;

  double get successRate =>
      total == 0 ? 0 : (healthy / total) * 100;

  /// 🚀 MANUAL UPLOAD
  Future<void> uploadAll() async {

    setState(() => isUploading = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Uploading detections...")),
    );

    await SyncService().syncDetections();

    loadDetections();

    setState(() => isUploading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Upload finished")),
    );
  }

  /// ❗ DELETE SINGLE
  Future<void> confirmDeleteItem(DetectionResultModel item) async {

    if (item.isSynced != true) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Item"),
        content: const Text("This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await item.delete();
      loadDetections();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Deleted")),
      );
    }
  }

  /// ❗ CLEAR ALL SYNCED
  Future<void> confirmClearAllSynced() async {

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Clear Uploaded Data"),
        content: const Text("Delete all synced records only."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete All",
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {

      final syncedItems =
          detections.where((e) => e.isSynced == true).toList();

      for (var item in syncedItems) {
        await item.delete();
      }

      loadDetections();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cleared")),
      );
    }
  }

  /// 🔍 DETAIL VIEW
  void openDetail(DetectionResultModel item) {

    final confidence = item.diseaseConfidence ?? 0;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(item.diseaseLabel ?? "Detection"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              if (item.imageLocalPath != null &&
                  File(item.imageLocalPath!).existsSync())
                Image.file(File(item.imageLocalPath!), height: 180),

              const SizedBox(height: 10),

              Text("Confidence: ${(confidence * 100).toStringAsFixed(1)}%"),

              Text(
                item.createdAt?.toString().substring(0, 16) ?? "",
              ),

              const SizedBox(height: 10),

              Chip(
                label: Text(
                  item.isSynced == true ? "Synced" : "Offline",
                ),
                backgroundColor: item.isSynced == true
                    ? Colors.green.shade100
                    : Colors.orange.shade100,
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            )
          ],
        );
      },
    );
  }

  /// 📊 INSIGHT CARD (NEW 🔥)
  Widget buildInsightCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.green, Colors.teal],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [

          const Text(
            "Farm Insights",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _stat("Total", total),
              _stat("Healthy", healthy),
              _stat("Diseased", diseased),
            ],
          ),

          const SizedBox(height: 10),

          LinearProgressIndicator(
            value: successRate / 100,
            minHeight: 8,
            backgroundColor: Colors.white24,
          ),

          const SizedBox(height: 5),

          Text(
            "Healthy Rate: ${successRate.toStringAsFixed(1)}%",
            style: const TextStyle(color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget _stat(String title, int value) {
    return Column(
      children: [
        Text(
          "$value",
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ),
        Text(title, style: const TextStyle(color: Colors.white70))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    final hasSynced =
        detections.any((e) => e.isSynced == true);

    return Scaffold(

      appBar: AppBar(
        title: const Text("History"),
        backgroundColor: Colors.green.shade700,
        actions: [

          IconButton(
            icon: isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.cloud_upload),
            onPressed: isUploading ? null : uploadAll,
          ),

          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: hasSynced ? confirmClearAllSynced : null,
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async => loadDetections(),
        child: detections.isEmpty
            ? const Center(
                child: Text(
                  "No detections yet 🌿",
                  style: TextStyle(fontSize: 16),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(15),
                children: [

                  /// 📊 INSIGHT
                  buildInsightCard(),

                  const SizedBox(height: 15),

                  /// 📜 LIST
                  ...detections.map((item) {

                    final confidence = item.diseaseConfidence ?? 0;

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(

                        onTap: () => openDetail(item),

                        leading: item.imageLocalPath != null &&
                                File(item.imageLocalPath!).existsSync()
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(item.imageLocalPath!),
                                  width: 55,
                                  height: 55,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.image),

                        title: Text(
                          item.diseaseLabel ?? "Unknown",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),

                        subtitle: Text(
                          "${(confidence * 100).toStringAsFixed(1)}% • ${item.createdAt?.toString().substring(0, 16) ?? ""}",
                        ),

                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            Icon(
                              item.isSynced == true
                                  ? Icons.cloud_done
                                  : Icons.cloud_off,
                              color: item.isSynced == true
                                  ? Colors.green
                                  : Colors.orange,
                            ),

                            if (item.isSynced == true)
                              GestureDetector(
                                onTap: () =>
                                    confirmDeleteItem(item),
                                child: const Icon(Icons.delete,
                                    size: 18, color: Colors.red),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList()
                ],
              ),
      ),
    );
  }
}