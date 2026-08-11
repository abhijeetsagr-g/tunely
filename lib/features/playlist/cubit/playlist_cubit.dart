import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/playlist/model/playlist.dart';
import 'package:tunely/features/playlist/model/playlist_detail.dart';
import 'package:tunely/features/playlist/repository/playlist_repository.dart';
import 'package:tunely/shared/model/tune.dart';

part 'playlist_state.dart';

class PlaylistCubit extends Cubit<PlaylistState> {
  final PlaylistRepository _repo;
  late final StreamSubscription _librarySub;

  List<Tune> _tunes = const [];

  PlaylistCubit({
    required PlaylistRepository repo,
    required LibraryCubit library,
  }) : _repo = repo,
       super(PlaylistsLoading()) {
    if (library.state is LibraryLoaded) {
      _tunes = (library.state as LibraryLoaded).tunes;
    }
    _librarySub = library.stream.listen((state) {
      if (state is! LibraryLoaded) return;
      _tunes = state.tunes;
      if (_currentDetail.playlist != null) {
        loadPlaylistDetail(_currentDetail.playlist!);
      }
    });
  }

  PlaylistDetail get _currentDetail => state is PlaylistsLoaded
      ? (state as PlaylistsLoaded).detail
      : const PlaylistDetail();

  Future<void> loadPlaylists() async {
    final detail = _currentDetail;
    emit(PlaylistsLoading());
    try {
      emit(PlaylistsLoaded(playlists: _repo.getAll(), detail: detail));
    } catch (e) {
      emit(PlaylistsError(e.toString()));
    }
  }

  Future<void> loadPlaylistDetail(Playlist playlist) async {
    emit(
      PlaylistsLoaded(
        playlists: _repo.getAll(),
        detail: PlaylistDetail(playlist: playlist, isLoading: true),
      ),
    );
    try {
      final tunes = await _resolveAndPrune(playlist);
      emit(
        PlaylistsLoaded(
          playlists: _repo.getAll(),
          detail: PlaylistDetail(playlist: playlist, tunes: tunes),
        ),
      );
    } catch (e) {
      emit(
        PlaylistsLoaded(
          playlists: _repo.getAll(),
          detail: PlaylistDetail(playlist: playlist, error: e.toString()),
        ),
      );
    }
  }

  Future<void> createPlaylist({
    required String name,
    String? description,
    List<String> songPaths = const [],
  }) async {
    await _repo.create(
      name: name,
      description: description,
      songPaths: songPaths,
    );
    await loadPlaylists();
  }

  Future<void> renamePlaylist(Playlist playlist, String name) async {
    await _repo.rename(playlist, name);
    await loadPlaylists();
  }

  Future<void> deletePlaylist(Playlist playlist) async {
    await _repo.delete(playlist);
    await loadPlaylists();
  }

  Future<void> setDescription(Playlist playlist, String? description) async {
    await _repo.setDescription(playlist, description);
    await loadPlaylists();
  }

  Future<void> addSongs(Playlist playlist, List<String> paths) async {
    if (paths.isEmpty) return;
    await _repo.addSongs(playlist, paths);
    await _refreshFor(playlist);
  }

  Future<void> removeSong(Playlist playlist, String path) async {
    await _repo.removeSong(playlist, path);
    await _refreshFor(playlist);
  }

  Future<void> reorderSongs(Playlist playlist, List<String> paths) async {
    await _repo.reorderSongs(playlist, paths);
    await _refreshFor(playlist);
  }

  Future<void> _refreshFor(Playlist playlist) async {
    if (_currentDetail.playlist?.key == playlist.key) {
      await loadPlaylistDetail(playlist);
    } else {
      await loadPlaylists();
    }
  }

  Future<List<Tune>> _resolveAndPrune(Playlist playlist) async {
    final byPath = {for (final t in _tunes) t.path: t};
    final resolved = <Tune>[];
    final stale = <String>[];
    for (final path in playlist.songPaths) {
      final tune = byPath[path];
      if (tune == null) {
        stale.add(path);
      } else {
        resolved.add(tune);
      }
    }
    if (stale.isNotEmpty) {
      await _repo.reorderSongs(playlist, resolved.map((t) => t.path).toList());
    }
    return resolved;
  }

  @override
  Future<void> close() {
    _librarySub.cancel();
    return super.close();
  }
}
