// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionAdapter extends TypeAdapter<Session> {
  @override
  final int typeId = 1;

  @override
  Session read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Session()
      ..currentPath = fields[0] as String
      ..positionMs = fields[1] as int
      ..queuePaths = (fields[2] as List).cast<String>();
  }

  @override
  void write(BinaryWriter writer, Session obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.currentPath)
      ..writeByte(1)
      ..write(obj.positionMs)
      ..writeByte(2)
      ..write(obj.queuePaths);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
