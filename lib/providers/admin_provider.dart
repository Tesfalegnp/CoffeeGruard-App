import 'package:flutter/material.dart';
import '../core/services/admin_service.dart';

class AdminProvider extends ChangeNotifier {
  final AdminService _service = AdminService();

  // ===============================
  // 👥 USERS
  // ===============================
  List<Map<String, dynamic>> users = [];
  bool userLoading = false;

  Future<void> loadUsers() async {
    userLoading = true;
    notifyListeners();

    users = await _service.getUsers();

    userLoading = false;
    notifyListeners();
  }

  Future<void> toggleUserStatus(String id, bool current) async {
    await _service.updateUser(id, {
      "is_active": !current,
    });
    await loadUsers();
  }

  Future<void> changeRole(String id, String role) async {
    await _service.updateUser(id, {
      "role": role,
    });
    await loadUsers();
  }

  Future<void> deleteUser(String id) async {
    await _service.deleteUser(id);
    await loadUsers();
  }

  // ===============================
  // 🗂 DETECTIONS
  // ===============================
  List<Map<String, dynamic>> detections = [];
  bool detectionLoading = false;

  Future<void> loadDetections() async {
    detectionLoading = true;
    notifyListeners();

    detections = await _service.getDetections();

    detectionLoading = false;
    notifyListeners();
  }

  Future<void> updateDetection(
    String id,
    Map<String, dynamic> data,
  ) async {
    await _service.updateDetection(id, data);
    await loadDetections();
  }

  Future<void> deleteDetection(
    String id,
    String? imageUrl,
  ) async {
    await _service.deleteDetection(id, imageUrl);
    await loadDetections();
  }

  // ===============================
  // 📊 ANALYTICS
  // ===============================
  bool analyticsLoading = false;

  int totalDetections = 0;
  int todayDetections = 0;
  int reviewed = 0;
  int pending = 0;
  int totalUsers = 0;

  Map<String, int> diseaseCount = {};
  Map<String, int> dailyDetections = {};

  Future<void> loadAnalytics() async {
    analyticsLoading = true;
    notifyListeners();

    final detectionsData = await _service.getDetections();
    final usersData = await _service.getUsers();

    // RESET
    totalDetections = 0;
    todayDetections = 0;
    reviewed = 0;
    pending = 0;
    totalUsers = 0;

    diseaseCount.clear();
    dailyDetections.clear();

    totalUsers = usersData.length;
    totalDetections = detectionsData.length;

    final today = DateTime.now();

    for (var d in detectionsData) {
      final disease = d["disease_label"] ?? "Unknown";
      diseaseCount[disease] = (diseaseCount[disease] ?? 0) + 1;

      final date = DateTime.tryParse(d["created_at"] ?? "");

      if (date != null) {
        final key = "${date.year}-${date.month}-${date.day}";
        dailyDetections[key] = (dailyDetections[key] ?? 0) + 1;

        if (date.year == today.year &&
            date.month == today.month &&
            date.day == today.day) {
          todayDetections++;
        }
      }

      if (d["is_reviewed"] == true) {
        reviewed++;
      } else {
        pending++;
      }
    }

    analyticsLoading = false;
    notifyListeners();
  }

  // ===============================
  // 🔥 FIX FOR YOUR UI (IMPORTANT)
  // ===============================

  /// ✅ THIS FIXES YOUR ERROR:
  /// provider.loading is missing
  bool get loading =>
      userLoading || detectionLoading || analyticsLoading;

  // ===============================
  // 🔥 INSIGHT
  // ===============================
  String get topDisease {
    if (diseaseCount.isEmpty) return "N/A";

    final top = diseaseCount.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );

    return "${top.key} (${top.value})";
  }
}