// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tune_stats.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TuneStatsAdapter extends TypeAdapter<TuneStats> {
  @override
  final int typeId = 0;

  @override
  TuneStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TuneStats(
      tuneId: fields[0] as String,
      playCount: (fields[1] as num).toInt(),
      lastPlayed: fields[2] as DateTime?,
      isLiked: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TuneStats obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.tuneId)
      ..writeByte(1)
      ..write(obj.playCount)
      ..writeByte(2)
      ..write(obj.lastPlayed)
      ..writeByte(3)
      ..write(obj.isLiked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TuneStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
