// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecommendationModelAdapter extends TypeAdapter<RecommendationModel> {
  @override
  final int typeId = 2;

  @override
  RecommendationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecommendationModel(
      id: fields[0] as String,
      diseaseLabel: fields[1] as String,
      severity: fields[2] as String,
      title: fields[3] as String,
      content: fields[4] as String,
      priority: fields[5] as String,
      updatedAt: fields[6] as DateTime?,
      titleAm: fields[7] as String?,
      contentAm: fields[8] as String?,
      titleOm: fields[9] as String?,
      contentOm: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RecommendationModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.diseaseLabel)
      ..writeByte(2)
      ..write(obj.severity)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.content)
      ..writeByte(5)
      ..write(obj.priority)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.titleAm)
      ..writeByte(8)
      ..write(obj.contentAm)
      ..writeByte(9)
      ..write(obj.titleOm)
      ..writeByte(10)
      ..write(obj.contentOm);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecommendationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
