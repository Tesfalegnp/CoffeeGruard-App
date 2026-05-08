import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/services/supabase_service.dart';
import '../../core/services/hive_service.dart';
import '../../models/user_model.dart';
import '../../providers/language_provider.dart';
import '../../providers/theme_provider.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  final SupabaseService service = SupabaseService();
  final ImagePicker picker = ImagePicker();

  UserModel? user;

  bool loading = true;
  bool isEditing = false;
  bool isSaving = false;

  File? selectedAvatar;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController countryController;
  late TextEditingController cityController;
  late TextEditingController farmLocationController;
  late TextEditingController farmSizeController;
  late TextEditingController cropsController;
  late TextEditingController expertiseController;
  late TextEditingController yearsController;
  late TextEditingController bioController;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    
    _animationController.forward();
    loadUser();
  }

  @override
  void dispose() {
    _animationController.dispose();
    nameController.dispose();
    phoneController.dispose();
    countryController.dispose();
    cityController.dispose();
    farmLocationController.dispose();
    farmSizeController.dispose();
    cropsController.dispose();
    expertiseController.dispose();
    yearsController.dispose();
    bioController.dispose();
    super.dispose();
  }

  void loadUser() {
    user = HiveService.getCurrentUser();

    if (user != null) {
      nameController = TextEditingController(text: user!.fullName ?? "");
      phoneController = TextEditingController(text: user!.phone ?? "");
      countryController = TextEditingController(text: user!.country ?? "");
      cityController = TextEditingController(text: user!.city ?? "");
      farmLocationController = TextEditingController(text: user!.farmLocation ?? "");
      farmSizeController = TextEditingController(text: user!.farmSize?.toString() ?? "");
      cropsController = TextEditingController(text: user!.crops?.join(", ") ?? "");
      expertiseController = TextEditingController(text: user!.expertise ?? "");
      yearsController = TextEditingController(text: user!.yearsExperience?.toString() ?? "");
      bioController = TextEditingController(text: user!.bio ?? "");
    }

    setState(() => loading = false);
  }

  Future<void> refreshFromServer() async {
    if (user == null) return;

    setState(() => loading = true);
    
    final fresh = await service.getUserById(user!.id);

    if (fresh != null) {
      await HiveService.updateCurrentUser(fresh);
      user = fresh;
      loadUser();
    }
    
    setState(() => loading = false);
    
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final code = lang.code;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          code == 'am' 
              ? "መገለጫ ተዘምኗል"
              : code == 'om'
              ? "Profiliin fooyyera'e"
              : "Profile refreshed",
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> pickAvatar() async {
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() {
        selectedAvatar = File(picked.path);
      });
    }
  }

  Future<void> saveProfile() async {
    if (user == null) return;

    setState(() => isSaving = true);

    String? avatarUrl = user!.avatarUrl;

    try {
      if (selectedAvatar != null) {
        avatarUrl = await service.uploadImage(
          selectedAvatar!,
          "${user!.id}_${DateTime.now().millisecondsSinceEpoch}.jpg",
        );
      }

      final List<String> cropsList =
                cropsController.text.trim().isEmpty
                    ? <String>[]
                    : cropsController.text
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();

      final success = await service.updateUserProfile(
        id: user!.id,
        fullName: nameController.text.trim(),
        phone: phoneController.text.trim(),
        avatarUrl: avatarUrl,
        farmLocation: farmLocationController.text.trim(),
        country: countryController.text.trim(),
        city: cityController.text.trim(),
        bio: bioController.text.trim(),
        crops: cropsList,
        farmSize: double.tryParse(farmSizeController.text.trim()),
        expertise: expertiseController.text.trim(),
        yearsExperience: int.tryParse(yearsController.text.trim()),
      );

      if (success) {
        user!
          ..fullName = nameController.text.trim()
          ..phone = phoneController.text.trim()
          ..avatarUrl = avatarUrl
          ..country = countryController.text.trim()
          ..city = cityController.text.trim()
          ..farmLocation = farmLocationController.text.trim()
          ..farmSize = double.tryParse(farmSizeController.text.trim())
          ..crops = cropsList
          ..expertise = expertiseController.text.trim()
          ..yearsExperience = int.tryParse(yearsController.text.trim())
          ..bio = bioController.text.trim();

        await HiveService.updateCurrentUser(user!);

        final lang = Provider.of<LanguageProvider>(context, listen: false);
        final code = lang.code;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              code == 'am'
                  ? "✅ መገለጫ በተሳካ ሁኔታ ተዘምኗል"
                  : code == 'om'
                  ? "✅ Profiliin fooyyera'e"
                  : "✅ Profile updated successfully",
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          isEditing = false;
          selectedAvatar = null;
        });
      } else {
        throw Exception("Update failed");
      }
    } catch (e) {
      final lang = Provider.of<LanguageProvider>(context, listen: false);
      final code = lang.code;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            code == 'am'
                ? "❌ ዝማኔ አልተሳካም: $e"
                : code == 'om'
                ? "❌ Fooyyessi hin milkoofne: $e"
                : "❌ Update failed: $e",
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => isSaving = false);
  }

  String tr(String en, String am, String om, String code) {
    if (code == "am") return am;
    if (code == "om") return om;
    return en;
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);
    final code = lang.code;
    final isDark = theme.currentTheme == AppThemeMode.dark;

    if (loading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              const SizedBox(height: 16),
              Text(
                tr("Loading profile...", "መገለጫ በመጫን ላይ...", "Profilii fe'amaa...", code),
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                tr("No user found", "ምንም ተጠቃሚ አልተገኘም", "Abbaan fayyadamtuu hin argamne", code),
                style: TextStyle(
                  fontSize: 18,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          tr("My Profile", "መገለጫ", "Profilii", code),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: refreshFromServer,
              tooltip: tr("Refresh", "አድስ", "Haaromsa", code),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(isEditing ? Icons.close : Icons.edit),
              onPressed: () {
                setState(() {
                  isEditing = !isEditing;
                  if (!isEditing) {
                    loadUser();
                  }
                });
              },
              tooltip: isEditing 
                  ? tr("Cancel", "ሰርዝ", "Haqi", code)
                  : tr("Edit Profile", "አርትዕ", "Gulaali", code),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Profile Header Section
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Avatar Section
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: selectedAvatar != null
                                  ? FileImage(selectedAvatar!) as ImageProvider
                                  : (user!.avatarUrl != null && user!.avatarUrl!.isNotEmpty)
                                      ? NetworkImage(user!.avatarUrl!)
                                      : null,
                              backgroundColor: Colors.green.shade100,
                              child: selectedAvatar == null &&
                                      (user!.avatarUrl == null || user!.avatarUrl!.isEmpty)
                                  ? Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.green.shade700,
                                    )
                                  : null,
                            ),
                          ),
                          if (isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: pickAvatar,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade700,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark ? Colors.black : Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Role Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade700,
                              Colors.green.shade500,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user!.role?.toUpperCase() ?? 
                              tr("FARMER", "አርሶ አደር", "QONNAAN BULTOO", code),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Email Display
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            user!.email ?? "",
                            style: TextStyle(
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Personal Information Section
              _buildSectionHeader(
                icon: Icons.person_outline,
                title: tr("Personal Information", "የግል መረጃ", "Odeeffannoo Dhuunfaa", code),
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              
              _buildField(
                label: tr("Full Name", "ሙሉ ስም", "Maqaa Guutuu", code),
                controller: nameController,
                isEditing: isEditing,
                isDark: isDark,
                icon: Icons.person,
              ),
              
              _buildField(
                label: tr("Phone Number", "ስልክ ቁጥር", "Lakkoofsa Bilbilaa", code),
                controller: phoneController,
                isEditing: isEditing,
                isDark: isDark,
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              
              const SizedBox(height: 20),
              
              // Address Information Section
              _buildSectionHeader(
                icon: Icons.location_on_outlined,
                title: tr("Address Information", "አድራሻ", "Teessoo", code),
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              
              _buildField(
                label: tr("Country", "ሀገር", "Biyda", code),
                controller: countryController,
                isEditing: isEditing,
                isDark: isDark,
                icon: Icons.flag,
              ),
              
              _buildField(
                label: tr("City", "ከተማ", "Magaala", code),
                controller: cityController,
                isEditing: isEditing,
                isDark: isDark,
                icon: Icons.location_city,
              ),
              
              _buildField(
                label: tr("Farm Location", "የእርሻ ቦታ", "Bakki Qonnaa", code),
                controller: farmLocationController,
                isEditing: isEditing,
                isDark: isDark,
                icon: Icons.agriculture,
              ),
              
              const SizedBox(height: 20),
              
              // Farming Information Section
              _buildSectionHeader(
                icon: Icons.eco_outlined,
                title: tr("Farming Information", "የእርሻ መረጃ", "Odeeffannoo Qonnaa", code),
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              
              _buildField(
                label: tr("Farm Size (hectares)", "የእርሻ መጠን (ሄክታር)", "Hamma Qonnaa (hektara)", code),
                controller: farmSizeController,
                isEditing: isEditing,
                isDark: isDark,
                icon: Icons.straighten,
                keyboardType: TextInputType.number,
              ),
              
              _buildField(
                label: tr("Crops (comma separated)", "ሰብሎች (በነጠላ ሰረዝ)", "Midhaan (argiddhaan addaan baasi)", code),
                controller: cropsController,
                isEditing: isEditing,
                isDark: isDark,
                icon: Icons.grass,
                maxLines: 2,
              ),
              
              const SizedBox(height: 20),
              
              // Professional Information Section (for Experts/Admins)
              if (user!.role == 'expert' || user!.role == 'admin')
                Column(
                  children: [
                    _buildSectionHeader(
                      icon: Icons.work_outline,
                      title: tr("Professional Information", "የሙያ መረጃ", "Odeeffannoo Miseensummaa", code),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    
                    _buildField(
                      label: tr("Expertise / Specialization", "ልዩ ችሎታ", "Dandeettii / Qaacaa addaa", code),
                      controller: expertiseController,
                      isEditing: isEditing,
                      isDark: isDark,
                      icon: Icons.school,
                    ),
                    
                    _buildField(
                      label: tr("Years of Experience", "የልምድ ዓመት", "Waggaa Muuxannoo", code),
                      controller: yearsController,
                      isEditing: isEditing,
                      isDark: isDark,
                      icon: Icons.timeline,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              
              // Bio Section
              _buildSectionHeader(
                icon: Icons.description_outlined,
                title: tr("Bio", "ስለእኔ", "Waa'ee koo", code),
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              
              _buildField(
                label: tr("Tell us about yourself", "ስለራስዎ ይንገሩን", "Waa'ee keessan nutti himaa", code),
                controller: bioController,
                isEditing: isEditing,
                isDark: isDark,
                icon: Icons.edit_note,
                maxLines: 4,
              ),
              
              const SizedBox(height: 30),
              
              // Save Button
              if (isEditing)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.shade700,
                        Colors.green.shade500,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: isSaving ? null : saveProfile,
                    child: isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.save, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                tr("Save Profile", "መገለጫ አስቀምጥ", "Profiliin Qus", code),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              
              const SizedBox(height: 20),
              
              // Info Note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tr(
                          "Your profile information helps us provide better recommendations and support.",
                          "የእርስዎ መገለጫ መረጃ የተሻለ ምክር እና ድጋፍ እንድናገኝ ይረዳናል።",
                          "Odeeffannoon profilii keessan gorsa fi deeggarsa fooyyaa'aa akka argattu nu gargaara.",
                          code,
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.green.shade700,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required bool isDark,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          enabled: isEditing,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: isEditing 
                  ? Colors.green.shade700 
                  : (isDark ? Colors.grey.shade500 : Colors.grey.shade600),
              fontSize: 13,
            ),
            prefixIcon: Icon(
              icon,
              color: isEditing 
                  ? Colors.green.shade700 
                  : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
              size: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.green.shade700,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: isEditing 
                ? (isDark ? const Color(0xFF2C2C2C) : Colors.white)
                : (isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade50),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}