import 'package:hive_flutter/hive_flutter.dart';
part 'lyric_line.g.dart';

@HiveType(typeId: 2)
class LyricLine {
  @HiveField(0)
  int timestamp;

  @HiveField(1)
  String text;

  LyricLine({required this.timestamp, required this.text});
}
