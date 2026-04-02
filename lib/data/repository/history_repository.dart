import 'package:hive_flutter/hive_flutter.dart';
import 'package:tunely/data/model/play_history.dart';
import 'package:tunely/data/model/session.dart';

class HistoryRepository {
  static const _boxName = 'play_history';
  late final Box<PlayHistory> _box;

  static const _sessionBox = 'session';
  late final Box<Session> _session;

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(PlayHistoryAdapter().typeId)) {
      Hive.registerAdapter(PlayHistoryAdapter());
    }
    if (!Hive.isAdapterRegistered(SessionAdapter().typeId)) {
      Hive.registerAdapter(SessionAdapter());
    }

    _box = await Hive.openBox<PlayHistory>(_boxName);
    _session = await Hive.openBox<Session>(_sessionBox);
  }

  Future<void> record(PlayHistory entry) async {
    await _box.add(entry);
    if (_box.length > 100) await _box.deleteAt(0);
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

  Future<void> saveSession({
    required String currentPath,
    required int positionMs,
    required List<String> queuePaths,
  }) async {
    final s = Session()
      ..currentPath = currentPath
      ..positionMs = positionMs
      ..queuePaths = queuePaths;
    await _session.put('latest', s);
  }

  Session? get lastSession => _session.get('latest');

  Future<void> clearAll() async {
    await _box.clear();
  }
}
