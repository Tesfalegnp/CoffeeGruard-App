// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detection_result_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DetectionResultModelAdapter extends TypeAdapter<DetectionResultModel> {
  @override
  final int typeId = 0;

  @override
  DetectionResultModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DetectionResultModel(
      id: fields[0] as String,
      imageLocalPath: fields[1] as String?,
      imageUrl: fields[2] as String?,
      isCoffeeLeaf: fields[3] as bool,
      leafConfidence: fields[4] as double?,
      diseaseLabel: fields[5] as String?,
      diseaseConfidence: fields[6] as double?,
      recommendation: fields[7] as String?,
      createdAt: fields[8] as DateTime,
      isSynced: fields[9] as bool,
      latitude: fields[10] as double?,
      longitude: fields[11] as double?,
      isReviewed: fields[12] as bool,
      expertNote: fields[13] as String?,
      severityLevel: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DetectionResultModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.imageLocalPath)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.isCoffeeLeaf)
      ..writeByte(4)
      ..write(obj.leafConfidence)
      ..writeByte(5)
      ..write(obj.diseaseLabel)
      ..writeByte(6)
      ..write(obj.diseaseConfidence)
      ..writeByte(7)
      ..write(obj.recommendation)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.isSynced)
      ..writeByte(10)
      ..write(obj.latitude)
      ..writeByte(11)
      ..write(obj.longitude)
      ..writeByte(12)
      ..write(obj.isReviewed)
      ..writeByte(13)
      ..write(obj.expertNote)
      ..writeByte(14)
      ..write(obj.severityLevel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetectionResultModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
