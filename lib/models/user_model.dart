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
  String? farmName;

  @HiveField(5)
  String? specialization;

  @HiveField(6)
  String? phone;

  @HiveField(7)
  String? avatarUrl;

  // ================================
  // ✅ ADDED FIELDS (FROM SUPABASE)
  // ================================

  @HiveField(8)
  bool? isActive;

  @HiveField(9)
  int? adminLevel;

  @HiveField(10)
  String? farmLocation;

  @HiveField(11)
  double? farmSize;

  @HiveField(12)
  String? crops;

  @HiveField(13)
  String? expertise;

  @HiveField(14)
  int? yearsExperience;

  @HiveField(15)
  String? organization;

  @HiveField(16)
  DateTime? lastLogin;

  @HiveField(17)
  DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    required this.role,
    this.farmName,
    this.specialization,
    this.phone,
    this.avatarUrl,

    // defaults safe for backward compatibility
    this.isActive,
    this.adminLevel,
    this.farmLocation,
    this.farmSize,
    this.crops,
    this.expertise,
    this.yearsExperience,
    this.organization,
    this.lastLogin,
    this.updatedAt,
  });
}