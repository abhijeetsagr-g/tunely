// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'management_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ManagementSettingsAdapter extends TypeAdapter<ManagementSettings> {
  @override
  final typeId = 4;

  @override
  ManagementSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ManagementSettings(
      artistDelimiters: fields[0] == null
          ? const ['/', ',', ';', '&', '+']
          : (fields[0] as List).cast<String>(),
      minDurationMs: fields[1] == null ? 10000 : (fields[1] as num).toInt(),
      excludedFolders: fields[2] == null
          ? const []
          : (fields[2] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ManagementSettings obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.artistDelimiters)
      ..writeByte(1)
      ..write(obj.minDurationMs)
      ..writeByte(2)
      ..write(obj.excludedFolders);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ManagementSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
