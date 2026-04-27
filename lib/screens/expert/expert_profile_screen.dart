import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/services/hive_service.dart';
import '../../core/services/supabase_service.dart';
import '../../core/services/sync_service.dart';
import '../../models/user_model.dart';

class ExpertProfileScreen extends StatefulWidget {
  const ExpertProfileScreen({super.key});

  @override
  State<ExpertProfileScreen> createState() =>
      _ExpertProfileScreenState();
}

class _ExpertProfileScreenState
    extends State<ExpertProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final SupabaseService _supabase = SupabaseService();
  final SyncService _sync = SyncService();

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController expertiseController;
  late TextEditingController experienceController;
  late TextEditingController organizationController;

  UserModel? user;
  bool loading = true;
  bool isEditing = false;
  bool isSaving = false;

  File? pickedImage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ================= LOAD =================
  Future<void> _loadProfile() async {
    final localUser = HiveService.getCurrentUser();

    if (localUser == null) {
      setState(() => loading = false);
      return;
    }

    try {
      final cloud =
          await _supabase.fetchUserById(localUser.id);

      if (cloud != null) {
        localUser.fullName = cloud["full_name"];
        localUser.phone = cloud["phone"];
        localUser.avatarUrl = cloud["avatar_url"];

        localUser.expertise = cloud["expertise"];
        localUser.yearsExperience =
            cloud["years_experience"];
        localUser.organization = cloud["organization"];

        localUser.isActive = cloud["is_active"] ?? true;

        await HiveService.saveUserSession(localUser);
      }
    } catch (_) {
      print("⚠️ Offline mode");
    }

    user = HiveService.getCurrentUser();

    nameController =
        TextEditingController(text: user?.fullName ?? "");
    phoneController =
        TextEditingController(text: user?.phone ?? "");
    expertiseController =
        TextEditingController(text: user?.expertise ?? "");
    experienceController = TextEditingController(
        text: user?.yearsExperience?.toString() ?? "");
    organizationController =
        TextEditingController(text: user?.organization ?? "");

    setState(() => loading = false);
  }

  // ================= IMAGE PICK =================
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img =
        await picker.pickImage(source: ImageSource.gallery);

    if (img != null) {
      setState(() {
        pickedImage = File(img.path);
      });
    }
  }

  // ================= SAVE =================
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (user == null) return;

    setState(() => isSaving = true);

    try {
      String? imageUrl = user!.avatarUrl;

      if (pickedImage != null) {
        imageUrl = await _supabase.uploadImage(
          pickedImage!,
          "expert_${user!.id}.jpg",
        );
      }

      user!
        ..fullName = nameController.text
        ..phone = phoneController.text
        ..expertise = expertiseController.text
        ..organization = organizationController.text
        ..yearsExperience =
            int.tryParse(experienceController.text)
        ..avatarUrl = imageUrl;

      // 💾 LOCAL SAVE
      await HiveService.updateCurrentUser(user!);

      // 🌐 CLOUD SYNC
      await _sync.syncUserProfile();

      setState(() {
        isEditing = false;
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Profile updated")),
      );
    } catch (e) {
      setState(() => isSaving = false);
      print("❌ Save error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Expert Profile"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.close : Icons.edit),
            onPressed: () =>
                setState(() => isEditing = !isEditing),
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ===== IMAGE =====
            Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundImage: pickedImage != null
                      ? FileImage(pickedImage!)
                      : (user?.avatarUrl != null
                          ? NetworkImage(user!.avatarUrl!)
                          : null) as ImageProvider?,
                  child: user?.avatarUrl == null &&
                          pickedImage == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                if (isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.camera_alt,
                            color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            Text(user?.email ?? "",
                style:
                    const TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 20),

            // ===== FORM =====
            Form(
              key: _formKey,
              child: Column(
                children: [

                  TextFormField(
                    controller: nameController,
                    enabled: isEditing,
                    decoration:
                        const InputDecoration(labelText: "Full Name"),
                  ),

                  TextFormField(
                    controller: phoneController,
                    enabled: isEditing,
                    decoration:
                        const InputDecoration(labelText: "Phone"),
                  ),

                  TextFormField(
                    controller: expertiseController,
                    enabled: isEditing,
                    decoration:
                        const InputDecoration(labelText: "Expertise"),
                  ),

                  TextFormField(
                    controller: experienceController,
                    enabled: isEditing,
                    decoration: const InputDecoration(
                        labelText: "Years Experience"),
                    keyboardType: TextInputType.number,
                  ),

                  TextFormField(
                    controller: organizationController,
                    enabled: isEditing,
                    decoration: const InputDecoration(
                        labelText: "Organization"),
                  ),

                  const SizedBox(height: 20),

                  if (isEditing)
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: const Size(double.infinity, 45),
                        ),
                        onPressed: isSaving ? null : _saveProfile,
                        child: isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Save"),
                        ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _info("Role", user?.role),
            _info("Expertise", user?.expertise),
            _info("Experience",
                user?.yearsExperience?.toString()),
          ],
        ),
      ),
    );
  }

  Widget _info(String title, String? value) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(value ?? "-"),
      ),
    );
  }
}