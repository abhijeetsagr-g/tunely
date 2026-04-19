import 'package:hive_ce/hive_ce.dart';
import 'package:tunely/features/lyrics/model/lyrics_result.dart';

class LyricsRepository {
  final Box<LyricsResult> _box;

  LyricsRepository({required Box<LyricsResult> box}) : _box = box;

  bool exists(String key) {
    return _box.containsKey(key);
  }

  LyricsResult? get(String key) {
    return _box.get(key);
  }

  Future<void> save(String key, LyricsResult data) async {
    await _box.put(key, data);
  }

  Future<void> clear() async {
    await _box.clear();
  }

  Future<void> delete(String key) async {
    await _box.delete(key);
  }
}
