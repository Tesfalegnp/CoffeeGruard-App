import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart'; 
import '../../models/user_model.dart'; 

class SupabaseService {
  final client = Supabase.instance.client;

  // ===============================
  // 📸 UPLOAD IMAGE
  // ===============================
  Future<String?> uploadImage(File file, String fileName) async {
    try {
      final path = "uploads/$fileName";

      await client.storage
          .from('coffee-images')
          .upload(path, file);

      final publicUrl =
          client.storage.from('coffee-images').getPublicUrl(path);

      print("✅ Image uploaded: $publicUrl");

      return publicUrl;
    } catch (e) {
      print("❌ Upload error: $e");
      return null;
    }
  }

  // ===============================
  // ☁ INSERT DETECTION
  // ===============================
  Future<bool> insertDetection(Map<String, dynamic> data) async {
    try {
      await client.from('detections').insert(data);
      print("✅ Detection inserted");
      return true;
    } catch (e) {
      print("❌ Insert error: $e");
      return false;
    }
  }

      // ============================================
      // GET USER PROFILE BY ID
      // ============================================

      Future<UserModel?> getUserById(String id) async {
        try {
          final res = await client
              .from('users')
              .select()
              .eq('id', id)
              .maybeSingle();

          if (res == null) return null;

          return UserModel.fromJson(res);
        } catch (e) {
          print("GET USER ERROR: $e");
          return null;
        }
      }

  // ===============================
  // 📥 FETCH ALL DETECTIONS
  // ===============================
  Future<List<Map<String, dynamic>>> fetchDetections() async {
    try {
      final response = await client
          .from('detections')
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("❌ Fetch detections error: $e");
      return [];
    }
  }

  // ===============================
  // 🔥 FETCH ONLY PENDING
  // ===============================
  Future<List<Map<String, dynamic>>> fetchPendingDetections() async {
    try {
      final response = await client
          .from('detections')
          .select()
          .or('is_reviewed.eq.false,is_reviewed.is.null')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("❌ Pending fetch error: $e");
      return [];
    }
  }

  // ===============================
  // 📥 PAGINATION
  // ===============================
  Future<List<Map<String, dynamic>>> fetchDetectionsPaginated(
    int limit,
    int offset,
  ) async {
    try {
      final response = await client
          .from('detections')
          .select()
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("❌ Pagination error: $e");
      return [];
    }
  }

  // ===============================
  // 🧠 🔥 FIXED DETECTION REVIEW UPDATE
  // ===============================
  Future<bool> updateDetectionReview(
    String detectionId,
    Map<String, dynamic> data,
  ) async {
    try {
      print("📡 Updating detection ID: $detectionId");
      print("📦 Raw payload: $data");

      final safeData = Map<String, dynamic>.from(data);

      // FIX: normalize severity
      if (safeData.containsKey("severity")) {
        safeData["severity_level"] = safeData["severity"];
        safeData.remove("severity");
      }

      if (safeData.containsKey("is_reviewed")) {
        safeData["is_reviewed"] =
            safeData["is_reviewed"] == true;
      }

      final response = await client
          .from('detections')
          .update({
            ...safeData,
            "updated_at": DateTime.now().toIso8601String(),
          })
          .eq('id', detectionId)
          .select();

      print("📦 Supabase response: $response");

      if (response.isEmpty) {
        print("❌ UPDATE FAILED: No row matched or RLS issue");
        return false;
      }

      print("✅ UPDATE SUCCESS");
      return true;
    } catch (e) {
      print("❌ Review update error: $e");
      return false;
    }
  }

  // ===============================
  // 🗑 DELETE DETECTION
  // ===============================
  Future<bool> deleteDetection(String id) async {
    try {
      await client.from('detections').delete().eq('id', id);
      return true;
    } catch (e) {
      print("❌ Delete error: $e");
      return false;
    }
  }

  // ===============================
  // 🗑 DELETE IMAGE
  // ===============================
  Future<bool> deleteImageFromStorage(String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);

      final path = uri.pathSegments
          .skipWhile((e) => e != 'coffee-images')
          .skip(1)
          .join('/');

      await client.storage.from('coffee-images').remove([path]);

      return true;
    } catch (e) {
      print("❌ Storage delete error: $e");
      return false;
    }
  }

  // ===============================
  // 📥 UPDATE RECOMMENDATION
  // ===============================
  Future<bool> updateRecommendation(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await client.from('recommendations').update(data).eq('id', id);
      return true;
    } catch (e) {
      print("❌ Recommendation update error: $e");
      return false;
    }
  }

  // ===============================
  // 💡 GET RECOMMENDATION BY DISEASE
  // ===============================
  Future<Map<String, dynamic>?> getRecommendationByDisease(
    String disease,
  ) async {
    try {
      final response = await client
          .from('recommendations')
          .select()
          .ilike('disease_label', disease)
          .limit(1)
          .maybeSingle();

      return response;
    } catch (e) {
      print("❌ Recommendation fetch error: $e");
      return null;
    }
  }

  // ===============================
  // 📥 GET ALL RECOMMENDATIONS
  // ===============================
  Future<List<Map<String, dynamic>>> getAllRecommendations() async {
    try {
      final response = await client
          .from('recommendations')
          .select()
          .order('updated_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("❌ Fetch recommendations error: $e");
      return [];
    }
  }

  // ===============================
  // 🔐 LOGIN USER
  // ===============================
  Future<Map<String, dynamic>?> loginUser(
    String email,
    String password,
  ) async {
    try {
      final response = await client
          .from('users')
          .select()
          .eq('email', email)
          .eq('password', password)
          .maybeSingle();

      return response;
    } catch (e) {
      print("❌ Login error: $e");
      return null;
    }
  }

  // =====================================================
  // 👥 USER MANAGEMENT (ADMIN)
  // =====================================================

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    try {
      final response = await client
          .from('users')
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("❌ Fetch users error: $e");
      return [];
    }
  }

  Future<bool> createUser(Map<String, dynamic> data) async {
    try {
      await client.from('users').insert(data);
      return true;
    } catch (e) {
      print("❌ Create user error: $e");
      return false;
    }
  }

  Future<bool> updateUser(String id, Map<String, dynamic> data) async {
    try {
      final response = await client
          .from('users')
          .update({
            ...data,
            "updated_at": DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select();

      return response.isNotEmpty;
    } catch (e) {
      print("❌ Update user error: $e");
      return false;
    }
  }

  Future<bool> deleteUser(String id) async {
    try {
      await client.from('users').delete().eq('id', id);
      return true;
    } catch (e) {
      print("❌ Delete user error: $e");
      return false;
    }
  }

  // =====================================================
  // 🧠 MODEL MONITORING (FIXED + REQUIRED)
  // =====================================================

  Future<List<Map<String, dynamic>>> fetchModelEvaluationData() async {
    try {
      final response = await client
          .from('detections')
          .select()
          .eq('is_reviewed', true)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("❌ Model evaluation fetch error: $e");
      return [];
    }
  }
         // =====================================================
// 👤 ADMIN PROFILE (ADD ONLY 🔥)
// =====================================================

          Future<Map<String, dynamic>?> fetchUserById(String id) async {
            try {
              final response = await client
                  .from('users')
                  .select()
                  .eq('id', id)
                  .maybeSingle();

              return response;
            } catch (e) {
              print("❌ fetchUserById error: $e");
              return null;
            }
          }

                Future<bool> updateUserProfile({
                  required String id,
                  String? fullName,
                  String? phone,
                  String? avatarUrl,
                  String? farmLocation,
                  double? farmSize,
                  List<String>? crops,
                  String? expertise,
                  int? yearsExperience,
                  String? country,
                  String? city,
                  String? bio,
                }) async {
                  try {
                    final response = await client
                        .from('users')
                        .update({
                          "full_name": fullName,
                          "phone": phone,
                          "avatar_url": avatarUrl,
                          "farm_location": farmLocation,
                          "farm_size": farmSize,
                          "crops": crops,
                          "expertise": expertise,
                          "years_experience": yearsExperience,
                          "country": country,
                          "city": city,
                          "bio": bio,
                          "updated_at": DateTime.now().toIso8601String(),
                        })
                        .eq('id', id)
                        .select();

                    return response.isNotEmpty;
                  } catch (e) {
                    print("PROFILE UPDATE ERROR: $e");
                    return false;
                  }
                }
         // ==========================================
          // 👤 REGISTER USER (MANUAL TABLE REGISTER)
          // ==========================================
                  Future<bool> registerUser({
                    required String fullName,
                    required String email,
                    required String password,
                    String role = "farmer",
                  }) async {
                    try {
                      final cleanEmail = email.trim().toLowerCase();

                      // =====================================
                      // 1. CHECK EXISTING EMAIL
                      // =====================================
                      final existingUser = await client
                          .from('users')
                          .select('email')
                          .eq('email', cleanEmail)
                          .maybeSingle();

                      if (existingUser != null) {
                        print("⚠️ Email already registered");
                        return false;
                      }

                      // =====================================
                      // 2. GENERATE UUID (VERY IMPORTANT)
                      // =====================================
                      final userId = const Uuid().v4();

                      // =====================================
                      // 3. INSERT USER
                      // =====================================
                      await client.from('users').insert({
                        "id": userId,
                        "full_name": fullName.trim(),
                        "email": cleanEmail,
                        "password": password.trim(), // your requirement
                        "role": role,
                        "is_active": true,
                        "is_online": false,
                        "verified": false,
                        "login_count": 0,
                        "rating": 0,
                        "total_reviews": 0,
                        "created_at": DateTime.now().toIso8601String(),
                        "updated_at": DateTime.now().toIso8601String(),
                      });

                      print("✅ User registered successfully");
                      return true;
                    } catch (e) {
                      print("❌ REGISTER ERROR: $e");
                      return false;
                    }
                  }
                  // =======================================================
              // VERIFY USER BEFORE RESET
                    // =======================================================

                    Future<bool> verifyUserForReset({
                      required String fullName,
                      required String email,
                    }) async {
                      try {
                        final result = await client
                            .from('users')
                            .select()
                            .eq('email', email.trim().toLowerCase())
                            .eq('full_name', fullName.trim())
                            .maybeSingle();

                        return result != null;
                      } catch (e) {
                        print("VERIFY ERROR: $e");
                        return false;
                      }
                    }

                    // =======================================================
                    // RESET PASSWORD
                    // =======================================================

                    Future<bool> resetPasswordDirectly({
                      required String email,
                      required String newPassword,
                    }) async {
                      try {
                        await client
                            .from('users')
                            .update({
                              "password": newPassword.trim(),
                              "updated_at":
                                  DateTime.now().toIso8601String(),
                            })
                            .eq(
                              'email',
                              email.trim().toLowerCase(),
                            );

                        return true;
                      } catch (e) {
                        print("RESET ERROR: $e");
                        return false;
                      }
                    }
}