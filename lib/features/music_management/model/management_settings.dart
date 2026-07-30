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

  @HiveField(3)
  final int dailyMixSize;

  @HiveField(4)
  final List<String>? dailyMixTunePaths;

  @HiveField(5)
  final int? dailyMixDateSeed;

  ManagementSettings({
    this.artistDelimiters = const ['/', ',', ';', '&', '+'],
    this.minDurationMs = 5000,
    this.excludedFolders = const [],
    this.dailyMixSize = 10,
    this.dailyMixTunePaths,
    this.dailyMixDateSeed,
  });

  ManagementSettings copyWith({
    List<String>? artistDelimiters,
    int? minDurationMs,
    List<String>? excludedFolders,
    int? dailyMixSize,
    List<String>? dailyMixTunePaths,
    int? dailyMixDateSeed,
  }) => ManagementSettings(
    artistDelimiters: artistDelimiters ?? this.artistDelimiters,
    minDurationMs: minDurationMs ?? this.minDurationMs,
    excludedFolders: excludedFolders ?? this.excludedFolders,
    dailyMixSize: dailyMixSize ?? this.dailyMixSize,
    dailyMixTunePaths: dailyMixTunePaths ?? this.dailyMixTunePaths,
    dailyMixDateSeed: dailyMixDateSeed ?? this.dailyMixDateSeed,
  );

  Map<String, dynamic> toJson() => {
    'artistDelimiters': artistDelimiters,
    'minDurationMs': minDurationMs,
    'excludedFolders': excludedFolders,
    'dailyMixSize': dailyMixSize,
    if (dailyMixTunePaths != null) 'dailyMixTunePaths': dailyMixTunePaths,
    if (dailyMixDateSeed != null) 'dailyMixDateSeed': dailyMixDateSeed,
  };

  factory ManagementSettings.fromJson(Map<String, dynamic> json) =>
      ManagementSettings(
        artistDelimiters: List<String>.from(json['artistDelimiters']),
        minDurationMs: json['minDurationMs'] as int,
        excludedFolders: List<String>.from(json['excludedFolders']),
        dailyMixSize: json['dailyMixSize'] as int? ?? 10,
        dailyMixTunePaths: json['dailyMixTunePaths'] != null
            ? List<String>.from(json['dailyMixTunePaths'])
            : null,
        dailyMixDateSeed: json['dailyMixDateSeed'] as int?,
      );
}
