import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tunely/data/model/play_history.dart';

class HistoryRepository {
  late final Isar _isar;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open([PlayHistorySchema], directory: dir.path);
  }

  Future<void> record(PlayHistory entry) async {
    await _isar.writeTxn(() => _isar.playHistorys.put(entry));
  }

  Future<List<PlayHistory>> recentlyPlayed({int limit = 20}) {
    return _isar.playHistorys
        .where()
        .sortByPlayedAtDesc()
        .limit(limit)
        .findAll();
  }

  Future<int> playCount(int songId) {
    return _isar.playHistorys.filter().songIdEqualTo(songId).count();
  }

  Future<List<PlayHistory>> topPlayed({int limit = 10}) async {
    final all = await _isar.playHistorys.where().findAll();
    final counts = <int, int>{};
    for (final h in all) {
      counts[h.songId] = (counts[h.songId] ?? 0) + 1;
    }
    final sorted = all.toSet().toList()
      ..sort(
        (a, b) => (counts[b.songId] ?? 0).compareTo(counts[a.songId] ?? 0),
      );
    return sorted.take(limit).toList();
  }
}
