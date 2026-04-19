import 'package:hive_ce/hive_ce.dart';

part 'lyrics_line.g.dart';

@HiveType(typeId: 1)
class LyricsLine {
  @HiveField(0)
  int timestamp;

  @HiveField(1)
  String text;

  LyricsLine({required this.timestamp, required this.text});
}
