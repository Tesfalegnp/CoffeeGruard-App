// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 1;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String,
      email: fields[1] as String,
      role: fields[3] as String,
      fullName: fields[2] as String?,
      phone: fields[4] as String?,
      avatarUrl: fields[5] as String?,
      farmLocation: fields[6] as String?,
      farmSize: fields[7] as double?,
      crops: (fields[8] as List?)?.cast<String>(),
      expertise: fields[9] as String?,
      yearsExperience: fields[10] as int?,
      organization: fields[11] as String?,
      adminLevel: fields[12] as int?,
      isActive: fields[13] as bool?,
      lastLogin: fields[14] as DateTime?,
      updatedAt: fields[15] as DateTime?,
      createdAt: fields[16] as DateTime?,
      country: fields[17] as String?,
      city: fields[18] as String?,
      bio: fields[19] as String?,
      coverUrl: fields[20] as String?,
      rating: fields[21] as double?,
      totalReviews: fields[22] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.fullName)
      ..writeByte(3)
      ..write(obj.role)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.avatarUrl)
      ..writeByte(6)
      ..write(obj.farmLocation)
      ..writeByte(7)
      ..write(obj.farmSize)
      ..writeByte(8)
      ..write(obj.crops)
      ..writeByte(9)
      ..write(obj.expertise)
      ..writeByte(10)
      ..write(obj.yearsExperience)
      ..writeByte(11)
      ..write(obj.organization)
      ..writeByte(12)
      ..write(obj.adminLevel)
      ..writeByte(13)
      ..write(obj.isActive)
      ..writeByte(14)
      ..write(obj.lastLogin)
      ..writeByte(15)
      ..write(obj.updatedAt)
      ..writeByte(16)
      ..write(obj.createdAt)
      ..writeByte(17)
      ..write(obj.country)
      ..writeByte(18)
      ..write(obj.city)
      ..writeByte(19)
      ..write(obj.bio)
      ..writeByte(20)
      ..write(obj.coverUrl)
      ..writeByte(21)
      ..write(obj.rating)
      ..writeByte(22)
      ..write(obj.totalReviews);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
