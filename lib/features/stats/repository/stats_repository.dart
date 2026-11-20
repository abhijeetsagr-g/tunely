import 'dart:async';
import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:tunely/features/stats/model/tune_stats.dart';

class StatsRepository {
  final Box<TuneStats> _box;
  final Box _meta;

  Stream<BoxEvent> watch() => _box.watch();

  StatsRepository(this._box, this._meta);

  TuneStats get(String id) {
    return _box.get(id) ?? TuneStats(tuneId: id);
  }

  void save(TuneStats stats) {
    _box.put(stats.tuneId, stats);
  }

  /// Forces pending writes to disk so a crash cannot lose the last play.
  Future<void> flush() async {
    await _box.flush();
    await _meta.flush();
  }

  void toggleLike(String id) {
    final stats = get(id);
    stats.isLiked = !stats.isLiked;
    save(stats);
    unawaited(flush());
  }

  List<String> getRecentOrder() {
    final raw = _meta.get('recent_order');
    if (raw == null) return [];
    return (jsonDecode(raw as String) as List).cast<String>();
  }

  void saveRecentOrder(List<String> order) {
    _meta.put('recent_order', jsonEncode(order));
  }

  void clearPlayCounts() {
    for (final stats in _box.values) {
      stats.playCount = 0;
      stats.lastPlayed = null;
      stats.save();
    }
    unawaited(flush());
  }

  void clearLikes() {
    for (final stats in _box.values) {
      if (stats.isLiked) {
        stats.isLiked = false;
        stats.save();
      }
    }
    unawaited(flush());
  }

  void clearRecentOrder() {
    saveRecentOrder([]);
    unawaited(flush());
  }
}
