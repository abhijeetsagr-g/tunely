import 'package:hive_ce/hive.dart';
import 'package:tunely/features/lyrics/model/lyric_result.dart';

class LyricsRepository {
  static const String _boxName = 'lyricsBox';

  late Box<LyricResult> _box;

  Future<void> init() async {
    _box = await Hive.openBox<LyricResult>(_boxName);
  }

  bool exists(String key) {
    return _box.containsKey(key);
  }

  LyricResult? get(String key) {
    return _box.get(key);
  }

  Future<void> save(String key, LyricResult data) async {
    await _box.put(key, data);
  }

  Future<void> clear() async {
    await _box.clear();
  }

  Future<void> delete(String key) async {
    await _box.delete(key);
  }
}
