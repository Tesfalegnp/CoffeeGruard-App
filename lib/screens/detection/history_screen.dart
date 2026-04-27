import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool isAmharic = false;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    loadDetections();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isAmharic = prefs.getBool('isAmharic') ?? false;
      isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  void loadDetections() {
    final data = HiveService.getAllDetections();
    setState(() {
      detections = data.reversed.toList();
    });
  }

  int get total => detections.length;
  int get healthy => detections
      .where((d) => (d.diseaseLabel ?? "").toLowerCase().contains("healthy"))
      .length;
  int get diseased => total - healthy;
  double get successRate => total == 0 ? 0 : (healthy / total) * 100;

  Future<void> uploadAll() async {
    setState(() => isUploading = true);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isAmharic ? "ውሂብ በመላክ ላይ..." : "Uploading detections..."),
        backgroundColor: Colors.green,
      ),
    );
    
    await SyncService().syncDetections();
    loadDetections();
    setState(() => isUploading = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isAmharic ? "መላክ ተጠናቋል" : "Upload finished"),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> confirmDeleteItem(DetectionResultModel item) async {
    if (item.isSynced != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAmharic ? "ያልተላከ ውሂብ መሰረዝ አይቻልም" : "Cannot delete unsynced data"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
            const SizedBox(width: 10),
            Text(isAmharic ? "ማስወገድ" : "Delete Item"),
          ],
        ),
        content: Text(
          isAmharic ? "ይህ እርምጃ ሊቀለበስ አይችልም" : "This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              isAmharic ? "ሰርዝ" : "Cancel",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              isAmharic ? "ሰርዝ" : "Delete",
              style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await item.delete();
      loadDetections();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAmharic ? "ውሂብ ተሰርዟል" : "Deleted successfully"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> confirmClearAllSynced() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.delete_forever, color: Colors.red.shade700),
            const SizedBox(width: 10),
            Text(isAmharic ? "ሁሉንም ሰርዝ" : "Clear All Data"),
          ],
        ),
        content: Text(
          isAmharic ? "የተላኩ መዝገቦችን ሁሉ መሰረዝ ይፈልጋሉ?" : "Delete all synced records?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(isAmharic ? "አይ" : "No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              isAmharic ? "አዎ ሰርዝ" : "Yes, Delete All",
              style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final syncedItems = detections.where((e) => e.isSynced == true).toList();
      for (var item in syncedItems) {
        await item.delete();
      }
      loadDetections();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAmharic ? "ሁሉም ውሂብ ተሰርዟል" : "All cleared"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void openDetail(DetectionResultModel item) {
    final confidence = item.diseaseConfidence ?? 0;
    final diseaseLower = (item.diseaseLabel ?? "").toLowerCase();
    final isHealthy = diseaseLower.contains("healthy");
    final statusColor = isHealthy ? Colors.green : Colors.red;

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  isHealthy ? Colors.green.shade50 : Colors.red.shade50,
                ],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: statusColor, width: 2),
                    ),
                    child: Text(
                      item.diseaseLabel ?? "Unknown",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (item.imageLocalPath != null && File(item.imageLocalPath!).existsSync())
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(
                        File(item.imageLocalPath!),
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isAmharic ? "ትክክለኛነት" : "Confidence",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${(confidence * 100).toStringAsFixed(1)}%",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: statusColor,
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
                          valueColor: AlwaysStoppedAnimation(statusColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.blue.shade700),
                      const SizedBox(width: 10),
                      Text(
                        item.createdAt?.toString().substring(0, 16) ?? "",
                        style: TextStyle(color: Colors.blue.shade700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Chip(
                    avatar: Icon(
                      item.isSynced == true ? Icons.cloud_done : Icons.cloud_off,
                      size: 18,
                      color: item.isSynced == true ? Colors.green : Colors.orange,
                    ),
                    label: Text(
                      item.isSynced == true 
                          ? (isAmharic ? "ተልኳል" : "Synced")
                          : (isAmharic ? "ከመስመር ውጭ" : "Offline"),
                    ),
                    backgroundColor: item.isSynced == true
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(isAmharic ? "ዝጋ" : "Close"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildInsightCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade700,
            Colors.green.shade500,
            Colors.teal.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.analytics, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                isAmharic ? "የእርሻ መረጃ" : "Farm Insights",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statCard(
                  title: isAmharic ? "ጠቅላላ" : "Total",
                  value: total.toString(),
                  icon: Icons.analytics, 
                  color: Colors.white,
                ),
              _statCard(
                title: isAmharic ? "ጤናማ" : "Healthy",
                value: healthy.toString(),
                icon: Icons.health_and_safety,
                color: Colors.lightGreen.shade200,
              ),
              _statCard(
                title: isAmharic ? "በሽታ" : "Diseased",
                value: diseased.toString(),
                icon: Icons.warning,
                color: Colors.orange.shade200,
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isAmharic ? "ጤናማ መጠን" : "Healthy Rate",
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      "${successRate.toStringAsFixed(1)}%",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: successRate / 100,
                    minHeight: 10,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({required String title, required String value, required IconData icon, required Color color}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasSynced = detections.any((e) => e.isSynced == true);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_edu, color: Colors.yellow.shade700),
            const SizedBox(width: 10),
            Text(isAmharic ? "ታሪክ" : "Detection History"),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: isUploading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.cloud_upload_outlined),
            onPressed: isUploading ? null : uploadAll,
            tooltip: isAmharic ? "ሁሉንም ላክ" : "Upload All",
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: hasSynced ? confirmClearAllSynced : null,
            tooltip: isAmharic ? "የተላኩትን ሰርዝ" : "Clear Synced",
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => loadDetections(),
        color: Colors.green,
        child: detections.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_edu,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isAmharic ? "ምንም መረጃ የለም 🌿" : "No detections yet 🌿",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isAmharic ? "አዲስ ፎቶ በመንሳት ይጀምሩ" : "Start by scanning a coffee leaf",
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(15),
                children: [
                  buildInsightCard(),
                  const SizedBox(height: 15),
                  ...detections.map((item) => _buildHistoryCard(item)).toList(),
                ],
              ),
      ),
    );
  }

  Widget _buildHistoryCard(DetectionResultModel item) {
    final confidence = item.diseaseConfidence ?? 0;
    final diseaseLower = (item.diseaseLabel ?? "").toLowerCase();
    final isHealthy = diseaseLower.contains("healthy");
    final statusColor = isHealthy ? Colors.green : Colors.red;
    final isSynced = item.isSynced == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          onTap: () => openDetail(item),
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  isHealthy ? Colors.green.shade50 : Colors.red.shade50,
                ],
              ),
            ),
            child: Row(
              children: [
                // Image thumbnail
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: item.imageLocalPath != null && File(item.imageLocalPath!).existsSync()
                        ? Image.file(
                            File(item.imageLocalPath!),
                            width: 65,
                            height: 65,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: Colors.grey.shade200,
                            child: Icon(Icons.image_not_supported, color: Colors.grey.shade400),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.diseaseLabel ?? "Unknown",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: statusColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: statusColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              "${(confidence * 100).toStringAsFixed(1)}%",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: statusColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.createdAt?.toString().substring(0, 16) ?? "",
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status indicators
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isSynced ? Colors.green.shade100 : Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isSynced ? Icons.cloud_done : Icons.cloud_off,
                        size: 18,
                        color: isSynced ? Colors.green : Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (isSynced)
                      GestureDetector(
                        onTap: () => confirmDeleteItem(item),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.delete_outline, size: 14, color: Colors.red.shade700),
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