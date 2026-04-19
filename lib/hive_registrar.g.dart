import 'package:hive_ce/hive.dart';
import 'package:tunely/features/stats/model/tune_stats.dart';
import 'package:tunely/features/music_management/model/management_settings.dart';

extension HiveRegistrar on HiveInterface {
  void registerAdapters() {
    registerAdapter(TuneStatsAdapter());
    registerAdapter(ManagementSettingsAdapter());
  }
}
