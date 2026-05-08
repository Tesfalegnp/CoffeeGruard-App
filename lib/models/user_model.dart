import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel extends HiveObject {

  @HiveField(0)
  String id;

  @HiveField(1)
  String email;

  @HiveField(2)
  String? fullName;

  @HiveField(3)
  String role;

  @HiveField(4)
  String? phone;

  @HiveField(5)
  String? avatarUrl;

  // =========================
  // FARM FIELDS
  // =========================

  @HiveField(6)
  String? farmLocation;

  @HiveField(7)
  double? farmSize;

  @HiveField(8)
  List<String>? crops;

  @HiveField(9)
  String? expertise;

  @HiveField(10)
  int? yearsExperience;

  @HiveField(11)
  String? organization;

  // =========================
  // ADMIN FIELDS
  // =========================

  @HiveField(12)
  int? adminLevel;

  @HiveField(13)
  bool? isActive;

  @HiveField(14)
  DateTime? lastLogin;

  @HiveField(15)
  DateTime? updatedAt;

  @HiveField(16)
  DateTime? createdAt;

  // =========================
  // 🔥 FIXED MISSING UI FIELDS
  // =========================

  @HiveField(17)
  String? country;

  @HiveField(18)
  String? city;

  @HiveField(19)
  String? bio;

  @HiveField(20)
  String? coverUrl;

  @HiveField(21)
  double? rating;

  @HiveField(22)
  int? totalReviews;

  // =========================
  // CONSTRUCTOR
  // =========================

  UserModel({
    required this.id,
    required this.email,
    required this.role,

    this.fullName,
    this.phone,
    this.avatarUrl,

    this.farmLocation,
    this.farmSize,
    this.crops,

    this.expertise,
    this.yearsExperience,
    this.organization,

    this.adminLevel,
    this.isActive,
    this.lastLogin,
    this.updatedAt,
    this.createdAt,

    this.country,
    this.city,
    this.bio,
    this.coverUrl,
    this.rating,
    this.totalReviews,
  });

  // =========================
  // FROM SUPABASE
  // =========================

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'] ?? '',
      role: json['role'] ?? 'farmer',

      fullName: json['full_name'],
      phone: json['phone'],
      avatarUrl: json['avatar_url'],

      farmLocation: json['farm_location'],
      farmSize: (json['farm_size'] != null)
          ? (json['farm_size'] as num).toDouble()
          : null,

      crops: json['crops'] != null
          ? List<String>.from(json['crops'])
          : null,

      expertise: json['expertise'],
      yearsExperience: json['years_experience'],
      organization: json['organization'],

      adminLevel: json['admin_level'],
      isActive: json['is_active'],

      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'])
          : null,

      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,

      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,

      // 🔥 FIXED NEW FIELDS
      country: json['country'],
      city: json['city'],
      bio: json['bio'],
      coverUrl: json['cover_url'],

      rating: (json['rating'] != null)
          ? (json['rating'] as num).toDouble()
          : null,

      totalReviews: json['total_reviews'],
    );
  }

  // =========================
  // TO SUPABASE
  // =========================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,

      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,

      'farm_location': farmLocation,
      'farm_size': farmSize,
      'crops': crops,

      'expertise': expertise,
      'years_experience': yearsExperience,
      'organization': organization,

      'admin_level': adminLevel,
      'is_active': isActive,
      'last_login': lastLogin?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),

      // 🔥 NEW FIELDS
      'country': country,
      'city': city,
      'bio': bio,
      'cover_url': coverUrl,
      'rating': rating,
      'total_reviews': totalReviews,
    };
  }
}