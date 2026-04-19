import 'package:hive_ce/hive_ce.dart';
import 'package:tunely/features/lyrics/model/lyrics_line.dart';

part 'lyrics_result.g.dart';

@HiveType(typeId: 2)
class LyricsResult {
  @HiveField(0)
  final List<LyricsLine> synced;

  @HiveField(1)
  final String? plain;

  @HiveField(2)
  final bool instrumental;

  @HiveField(3)
  int offsetMs;

  LyricsResult({
    required this.synced,
    this.plain,
    required this.instrumental,
    this.offsetMs = 0,
  });

  LyricsResult copyWith({
    List<LyricsLine>? synced,
    String? plain,
    bool? instrumental,
    int? offsetMs,
  }) => LyricsResult(
    synced: synced ?? this.synced,
    plain: plain ?? this.plain,
    instrumental: instrumental ?? this.instrumental,
    offsetMs: offsetMs ?? this.offsetMs,
  );
}
