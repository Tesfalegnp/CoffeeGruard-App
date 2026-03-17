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

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    required this.role,
    this.farmName,
    this.specialization,
    this.phone,
    this.avatarUrl,
  });
}