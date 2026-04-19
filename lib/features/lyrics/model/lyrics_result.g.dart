// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lyrics_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LyricsResultAdapter extends TypeAdapter<LyricsResult> {
  @override
  final typeId = 2;

  @override
  LyricsResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LyricsResult(
      synced: (fields[0] as List).cast<LyricsLine>(),
      plain: fields[1] as String?,
      instrumental: fields[2] as bool,
      offsetMs: fields[3] == null ? 0 : (fields[3] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, LyricsResult obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.synced)
      ..writeByte(1)
      ..write(obj.plain)
      ..writeByte(2)
      ..write(obj.instrumental)
      ..writeByte(3)
      ..write(obj.offsetMs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LyricsResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
