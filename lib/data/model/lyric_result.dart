import 'package:hive_flutter/hive_flutter.dart';
import 'package:tunely/data/model/lyric_line.dart';

part 'lyric_result.g.dart';

@HiveType(typeId: 3)
class LyricResult {
  @HiveField(0)
  final List<LyricLine> synced;

  @HiveField(1)
  final String? plain;

  @HiveField(2)
  final bool instrumental;

  LyricResult({required this.synced, this.plain, required this.instrumental});
}
