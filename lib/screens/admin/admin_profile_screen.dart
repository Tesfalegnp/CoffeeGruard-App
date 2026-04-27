import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/services/hive_service.dart';
import '../../core/services/supabase_service.dart';
import '../../core/services/sync_service.dart';
import '../../models/user_model.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final SupabaseService _supabase = SupabaseService();
  final SyncService _sync = SyncService();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController locationController;

  UserModel? user;
  bool loading = true;
  bool isEditing = false;
  bool isSaving = false;

  File? selectedImage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ================= LOAD PROFILE =================
  Future<void> _loadProfile() async {
    final localUser = HiveService.getCurrentUser();

    if (localUser == null) {
      setState(() => loading = false);
      return;
    }

    try {
      final cloud = await _supabase.fetchUserById(localUser.id);

      if (cloud != null) {
        localUser
          ..fullName = cloud["full_name"]
          ..phone = cloud["phone"]
          ..avatarUrl = cloud["avatar_url"]
          ..role = cloud["role"]
          ..isActive = cloud["is_active"]
          ..adminLevel = cloud["admin_level"]
          ..lastLogin = cloud["last_login"]
          ..farmLocation = cloud["farm_location"];

        await HiveService.saveUserSession(localUser);
      }

      user = HiveService.getCurrentUser();
    } catch (e) {
      user = HiveService.getCurrentUser();
    }

    nameController = TextEditingController(text: user?.fullName ?? "");
    phoneController = TextEditingController(text: user?.phone ?? "");
    locationController = TextEditingController(text: user?.farmLocation ?? "");

    setState(() => loading = false);
  }

  // ================= PICK IMAGE =================
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  // ================= UPLOAD IMAGE =================
  Future<String?> _uploadImage(File file) async {
    final fileName = "${user!.id}_${DateTime.now().millisecondsSinceEpoch}.jpg";
    return await _supabase.uploadImage(file, fileName);
  }

  // ================= SAVE PROFILE =================
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || user == null) return;

    setState(() => isSaving = true);

    String? avatarUrl = user!.avatarUrl;

    try {
      // 1. Upload image if selected
      if (selectedImage != null) {
        avatarUrl = await _uploadImage(selectedImage!);
      }

      final updatedData = {
        "full_name": nameController.text,
        "phone": phoneController.text,
        "farm_location": locationController.text,
        "avatar_url": avatarUrl,
        "updated_at": DateTime.now().toIso8601String(),
      };

      // 2. CLOUD UPDATE FIRST
      final success =
          await _supabase.updateUserProfile(user!.id, updatedData);

      if (success) {
        user!
          ..fullName = nameController.text
          ..phone = phoneController.text
          ..farmLocation = locationController.text
          ..avatarUrl = avatarUrl;

        await HiveService.saveUserSession(user!);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Profile updated on cloud")),
        );
      } else {
        throw Exception("Cloud failed");
      }
    } catch (e) {
      // OFFLINE MODE
      user!
        ..fullName = nameController.text
        ..phone = phoneController.text
        ..farmLocation = locationController.text
        ..avatarUrl = user!.avatarUrl;

      await HiveService.updateCurrentUser(user!);

      Future.microtask(() => _sync.syncUserProfile());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("📴 Saved locally (sync later)")),
      );
    }

    setState(() {
      isSaving = false;
      isEditing = false;
      selectedImage = null;
    });
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Profile"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.close : Icons.edit),
            onPressed: () => setState(() => isEditing = !isEditing),
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ================= HEADER CARD =================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [

                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: selectedImage != null
                            ? FileImage(selectedImage!)
                            : (user?.avatarUrl != null
                                ? NetworkImage(user!.avatarUrl!)
                                : null) as ImageProvider?,
                        child: (selectedImage == null &&
                                user?.avatarUrl == null)
                            ? Text(
                                user?.email?[0].toUpperCase() ?? "A",
                                style: const TextStyle(fontSize: 30),
                              )
                            : null,
                      ),

                      if (isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: const CircleAvatar(
                              radius: 15,
                              child: Icon(Icons.camera_alt, size: 18),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    user?.email ?? "",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  Text(
                    "Role: ${user?.role ?? ""} | Level: ${user?.adminLevel ?? 1}",
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= FORM =================
            Form(
              key: _formKey,
              child: Column(
                children: [

                  TextFormField(
                    controller: nameController,
                    enabled: isEditing,
                    decoration: const InputDecoration(
                      labelText: "Full Name",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: phoneController,
                    enabled: isEditing,
                    decoration: const InputDecoration(
                      labelText: "Phone",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: locationController,
                    enabled: isEditing,
                    decoration: const InputDecoration(
                      labelText: "Farm Location",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (isEditing)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      icon: isSaving
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: const Text("Save Profile"),
                      onPressed: isSaving ? null : _saveProfile,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}