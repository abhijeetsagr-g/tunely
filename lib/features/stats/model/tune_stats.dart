import 'package:hive_ce/hive_ce.dart';
part 'tune_stats.g.dart';

@HiveType(typeId: 5)
class TuneStats extends HiveObject {
  @HiveField(0)
  String tuneId;

  @HiveField(1)
  int playCount;

  @HiveField(2)
  DateTime? lastPlayed;

  @HiveField(3)
  bool isLiked;

  TuneStats({
    required this.tuneId,
    this.playCount = 0,
    this.lastPlayed,
    this.isLiked = false,
  });
}
