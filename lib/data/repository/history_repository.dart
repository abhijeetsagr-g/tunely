import 'package:hive_flutter/hive_flutter.dart';
import 'package:tunely/data/model/play_history.dart';

class HistoryRepository {
  static const _boxName = 'play_history';
  late final Box<PlayHistory> _box;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(PlayHistoryAdapter());
    _box = await Hive.openBox<PlayHistory>(_boxName);
  }

  Future<void> record(PlayHistory entry) async {
    await _box.add(entry);
  }

  Future<List<PlayHistory>> recentlyPlayed({int limit = 20}) async {
    final all = _box.values.toList()
      ..sort((a, b) => b.playedAt.compareTo(a.playedAt));

    final seen = <int>{};
    final unique = <PlayHistory>[];
    for (final h in all) {
      if (seen.add(h.songId)) {
        unique.add(h);
        if (unique.length == limit) break;
      }
    }
    return unique;
  }

  Future<List<PlayHistory>> topPlayed({int limit = 10}) async {
    final all = _box.values.toList();

    final counts = <int, int>{};
    final latest = <int, PlayHistory>{};
    for (final h in all) {
      counts[h.songId] = (counts[h.songId] ?? 0) + 1;
      latest[h.songId] = h;
    }

    final sorted = latest.values.toList()
      ..sort((a, b) => counts[b.songId]!.compareTo(counts[a.songId]!));

    return sorted.take(limit).toList();
  }

  Future<int> playCount(int songId) async {
    return _box.values.where((h) => h.songId == songId).length;
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
