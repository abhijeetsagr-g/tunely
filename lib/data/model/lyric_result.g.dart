// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lyric_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LyricResultAdapter extends TypeAdapter<LyricResult> {
  @override
  final int typeId = 3;

  @override
  LyricResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LyricResult(
      synced: (fields[0] as List).cast<LyricLine>(),
      plain: fields[1] as String?,
      instrumental: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, LyricResult obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.synced)
      ..writeByte(1)
      ..write(obj.plain)
      ..writeByte(2)
      ..write(obj.instrumental);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LyricResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
