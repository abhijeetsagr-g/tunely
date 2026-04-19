// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lyrics_line.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LyricsLineAdapter extends TypeAdapter<LyricsLine> {
  @override
  final typeId = 1;

  @override
  LyricsLine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LyricsLine(
      timestamp: (fields[0] as num).toInt(),
      text: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LyricsLine obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.text);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LyricsLineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
