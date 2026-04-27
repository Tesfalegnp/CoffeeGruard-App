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
      fullName: fields[2] as String?,
      role: fields[3] as String,
      farmName: fields[4] as String?,
      specialization: fields[5] as String?,
      phone: fields[6] as String?,
      avatarUrl: fields[7] as String?,
      isActive: fields[8] as bool?,
      adminLevel: fields[9] as int?,
      farmLocation: fields[10] as String?,
      farmSize: fields[11] as double?,
      crops: fields[12] as String?,
      expertise: fields[13] as String?,
      yearsExperience: fields[14] as int?,
      organization: fields[15] as String?,
      lastLogin: fields[16] as DateTime?,
      updatedAt: fields[17] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.fullName)
      ..writeByte(3)
      ..write(obj.role)
      ..writeByte(4)
      ..write(obj.farmName)
      ..writeByte(5)
      ..write(obj.specialization)
      ..writeByte(6)
      ..write(obj.phone)
      ..writeByte(7)
      ..write(obj.avatarUrl)
      ..writeByte(8)
      ..write(obj.isActive)
      ..writeByte(9)
      ..write(obj.adminLevel)
      ..writeByte(10)
      ..write(obj.farmLocation)
      ..writeByte(11)
      ..write(obj.farmSize)
      ..writeByte(12)
      ..write(obj.crops)
      ..writeByte(13)
      ..write(obj.expertise)
      ..writeByte(14)
      ..write(obj.yearsExperience)
      ..writeByte(15)
      ..write(obj.organization)
      ..writeByte(16)
      ..write(obj.lastLogin)
      ..writeByte(17)
      ..write(obj.updatedAt);
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
