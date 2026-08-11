import 'package:hive_ce/hive_ce.dart';
import 'package:tunely/features/playlist/model/playlist.dart';

class PlaylistRepository {
  final Box<Playlist> _box;

  PlaylistRepository(this._box);

  Stream<BoxEvent> watch() => _box.watch();

  List<Playlist> getAll() {
    final playlists = _box.values.toList();
    playlists.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
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
    return playlist;
  }

  Future<void> rename(Playlist playlist, String name) async {
    playlist.name = name;
    await _touch(playlist);
  }

  Future<void> setDescription(Playlist playlist, String? description) async {
    playlist.description = description;
    await _touch(playlist);
  }

  Future<void> addSongs(Playlist playlist, Iterable<String> paths) async {
    final existing = playlist.songPaths.toSet();
    playlist.songPaths = List.of(playlist.songPaths)
      ..addAll(paths.where((p) => !existing.contains(p)));
    await _touch(playlist);
  }

  Future<void> removeSong(Playlist playlist, String path) async {
    playlist.songPaths = List.of(playlist.songPaths)
      ..removeWhere((p) => p == path);
    await _touch(playlist);
  }

  Future<void> reorderSongs(Playlist playlist, List<String> songPaths) async {
    playlist.songPaths = List.of(songPaths);
    await _touch(playlist);
  }

  Future<void> delete(Playlist playlist) async {
    await playlist.delete();
  }

  Future<void> deleteByKey(dynamic key) async {
    await _box.delete(key);
  }

  Future<void> clear() async {
    await _box.clear();
  }

  Future<void> _touch(Playlist playlist) async {
    playlist.updatedAt = DateTime.now();
    await playlist.save();
  }
}
