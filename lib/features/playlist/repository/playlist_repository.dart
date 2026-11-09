import 'package:hive_ce/hive_ce.dart';
import 'package:tunely/features/playlist/model/playlist.dart';

class PlaylistRepository {
  final Box<Playlist> _box;

  /// Cached, already sorted snapshot. Invalidated on every mutation so
  /// repeated reads (e.g. several cubit emits per action) stay O(1).
  List<Playlist>? _cache;

  PlaylistRepository(this._box);

  Stream<BoxEvent> watch() => _box.watch();

  List<Playlist> getAll() {
    final cached = _cache;
    if (cached != null) return cached;
    final playlists = _box.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    _cache = playlists;
    return playlists;
  }

  Playlist? get(dynamic key) => _box.get(key);

  Future<Playlist> create({
    required String name,
    String? description,
    List<String> songPaths = const [],
  }) async {
    final now = DateTime.now();
    final playlist = Playlist(
      name: name,
      description: description,
      createdAt: now,
      updatedAt: now,
      songPaths: List.of(songPaths),
    );
    await _box.add(playlist);
    _invalidate();
    return playlist;
  }

  Future<void> rename(Playlist playlist, String name) async {
    playlist.name = name;
    _invalidate();
    await _touch(playlist);
  }

  Future<void> setDescription(Playlist playlist, String? description) async {
    playlist.description = description;
    _invalidate();
    await _touch(playlist);
  }

  Future<void> addSongs(Playlist playlist, Iterable<String> paths) async {
    final existing = playlist.songPaths.toSet();
    playlist.songPaths = List.of(playlist.songPaths)
      ..addAll(paths.where((p) => !existing.contains(p)));
    _invalidate();
    await _touch(playlist);
  }

  Future<void> removeSong(Playlist playlist, String path) async {
    playlist.songPaths = List.of(playlist.songPaths)
      ..removeWhere((p) => p == path);
    _invalidate();
    await _touch(playlist);
  }

  Future<void> reorderSongs(Playlist playlist, List<String> songPaths) async {
    playlist.songPaths = List.of(songPaths);
    _invalidate();
    await _touch(playlist);
  }

  /// Drops stale paths without treating it as a user edit.
  ///
  /// Unlike [reorderSongs], this does not bump [Playlist.updatedAt], so merely
  /// opening a playlist with missing files will not reorder the playlist list.
  Future<void> pruneMissing(Playlist playlist, List<String> songPaths) async {
    if (_sameOrder(playlist.songPaths, songPaths)) return;
    playlist.songPaths = List.of(songPaths);
    _invalidate();
    await playlist.save();
  }

  Future<void> delete(Playlist playlist) async {
    await playlist.delete();
    _invalidate();
  }

  Future<void> deleteByKey(dynamic key) async {
    await _box.delete(key);
    _invalidate();
  }

  Future<void> clear() async {
    await _box.clear();
    _invalidate();
  }

  Future<void> _touch(Playlist playlist) async {
    playlist.updatedAt = DateTime.now();
    await playlist.save();
  }

  void _invalidate() => _cache = null;

  bool _sameOrder(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
