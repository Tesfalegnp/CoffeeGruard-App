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

  /// 🚀 MANUAL UPLOAD
  Future<void> uploadAll() async {

    setState(() {
      isUploading = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Uploading detections...")),
    );

    await SyncService().syncDetections();

    loadDetections();

    setState(() {
      isUploading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Upload finished")),
    );
  }

  /// ❗ CONFIRM DELETE SINGLE
  Future<void> confirmDeleteItem(DetectionResultModel item) async {

    if (item.isSynced != true) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Item"),
        content: const Text(
            "Are you sure you want to delete this record?\n\nThis action cannot be undone."),
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
        const SnackBar(content: Text("Deleted successfully")),
      );
    }
  }

  /// ❗ CONFIRM CLEAR ALL
  Future<void> confirmClearAllSynced() async {

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Clear All Uploaded Data"),
        content: const Text(
            "Are you sure you want to delete ALL synced records?\n\nUnsynced data will be kept."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete All", style: TextStyle(color: Colors.red)),
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
        const SnackBar(content: Text("All uploaded data cleared")),
      );
    }
  }

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
                  item.imageLocalPath!.isNotEmpty &&
                  File(item.imageLocalPath!).existsSync())
                Image.file(
                  File(item.imageLocalPath!),
                  height: 200,
                )
              else
                const Icon(Icons.image, size: 120),

              const SizedBox(height: 15),

              Text(
                "Disease: ${item.diseaseLabel ?? "Unknown"}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Text(
                "Confidence: ${(confidence * 100).toStringAsFixed(2)} %",
              ),

              const SizedBox(height: 10),

              Text(
                "Date: ${item.createdAt != null
                    ? item.createdAt.toString().substring(0,16)
                    : "Unknown"}",
              ),

              const SizedBox(height: 10),

              Row(
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

                  const SizedBox(width: 5),

                  Text(
                    item.isSynced == true
                        ? "Synced"
                        : "Not Synced",
                  )
                ],
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

  @override
  Widget build(BuildContext context) {

    final hasSynced =
        detections.any((e) => e.isSynced == true);

    return Scaffold(

      appBar: AppBar(
        title: const Text("Detection History"),

        actions: [

          /// 🚀 UPLOAD
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

          /// 🧹 CLEAR ALL (WITH CONFIRM)
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: hasSynced ? confirmClearAllSynced : null,
          ),
        ],
      ),

      body: detections.isEmpty
          ? const Center(child: Text("No detections yet"))
          : ListView.builder(

              itemCount: detections.length,

              itemBuilder: (context, index) {

                final item = detections[index];
                final confidence = item.diseaseConfidence ?? 0;

                return Card(

                  margin: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),

                  child: ListTile(

                    onTap: () => openDetail(item),

                    leading: item.imageLocalPath != null &&
                            item.imageLocalPath!.isNotEmpty &&
                            File(item.imageLocalPath!).existsSync()
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.file(
                              File(item.imageLocalPath!),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.image),

                    title: Text(
                      item.diseaseLabel ?? "Unknown",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          "Confidence: ${(confidence * 100).toStringAsFixed(2)} %",
                        ),

                        Text(
                          item.createdAt != null
                              ? item.createdAt.toString().substring(0, 16)
                              : "Unknown date",
                          style: const TextStyle(fontSize: 12),
                        )
                      ],
                    ),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        Icon(
                          item.isSynced == true
                              ? Icons.cloud_done
                              : Icons.cloud_off,
                          color: item.isSynced == true
                              ? Colors.green
                              : Colors.orange,
                        ),

                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: item.isSynced == true
                              ? Colors.red
                              : Colors.grey,

                          onPressed: item.isSynced == true
                              ? () => confirmDeleteItem(item)
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}