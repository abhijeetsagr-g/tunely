import 'package:hive_ce/hive_ce.dart';

part 'management_settings.g.dart';

@HiveType(typeId: 4)
class ManagementSettings extends HiveObject {
  @HiveField(0)
  final List<String> artistDelimiters;

  @HiveField(1)
  final int minDurationMs;

  @HiveField(2)
  final List<String> excludedFolders;

  ManagementSettings({
    this.artistDelimiters = const ['/', ',', ';', '&', '+'],
    this.minDurationMs = 10000,
    this.excludedFolders = const [],
  });

  ManagementSettings copyWith({
    List<String>? artistDelimiters,
    int? minDurationMs,
    List<String>? excludedFolders,
  }) => ManagementSettings(
    artistDelimiters: artistDelimiters ?? this.artistDelimiters,
    minDurationMs: minDurationMs ?? this.minDurationMs,
    excludedFolders: excludedFolders ?? this.excludedFolders,
  );

  Map<String, dynamic> toJson() => {
    'artistDelimiters': artistDelimiters,
    'minDurationMs': minDurationMs,
    'excludedFolders': excludedFolders,
  };

  factory ManagementSettings.fromJson(Map<String, dynamic> json) =>
      ManagementSettings(
        artistDelimiters: List<String>.from(json['artistDelimiters']),
        minDurationMs: json['minDurationMs'] as int,
        excludedFolders: List<String>.from(json['excludedFolders']),
      );
}
