import 'package:hive_ce/hive_ce.dart';

part 'lyric_line.g.dart';

@HiveType(typeId: 1)
class LyricLine {
  @HiveField(0)
  int timestamp;

  @HiveField(1)
  String text;

  LyricLine({required this.timestamp, required this.text});
}
