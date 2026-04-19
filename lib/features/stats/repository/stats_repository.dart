import 'package:hive_ce/hive.dart';
import 'package:tunely/features/stats/model/tune_stats.dart';

class StatsRepository {
  final Box<TuneStats> _box;

  Stream<BoxEvent> watch() => _box.watch();

  StatsRepository(this._box);

  TuneStats get(String id) {
    return _box.get(id) ?? TuneStats(tuneId: id);
  }

  void save(TuneStats stats) {
    _box.put(stats.tuneId, stats);
  }

  void toggleLike(String id) {
    final stats = get(id);
    stats.isLiked = !stats.isLiked;
    save(stats);
  }

  List<TuneStats> getAll() => _box.values.toList();
}
