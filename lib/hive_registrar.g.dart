import 'package:hive_ce/hive.dart';
import 'package:tunely/features/lyrics/model/lyric_line.dart';
import 'package:tunely/features/lyrics/model/lyric_result.dart';
import 'package:tunely/features/stats/model/tune_stats.dart';

extension HiveRegistrar on HiveInterface {
  void registerAdapters() {
    registerAdapter(LyricLineAdapter());
    registerAdapter(LyricResultAdapter());
    registerAdapter(TuneStatsAdapter());
  }
}
