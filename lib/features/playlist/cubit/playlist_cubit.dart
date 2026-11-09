import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/errors/app_error.dart';
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
      // Several LibraryCubit operations (daily mix refresh, recommended
      // albums, etc.) re-emit LibraryLoaded with the same tune list. Only
      // re-resolve the open playlist when the songs actually changed.
      if (identical(state.tunes, _tunes)) return;
      _tunes = state.tunes;
      final playlist = _currentDetail.playlist;
      if (playlist != null) loadPlaylistDetail(playlist);
    });
  }

  PlaylistDetail get _currentDetail => state is PlaylistsLoaded
      ? (state as PlaylistsLoaded).detail
      : const PlaylistDetail();

  /// Emits a single loaded state. Never emits an intermediate loading state,
  /// so mutations do not flash a spinner over the list.
  void _emitLoaded({PlaylistDetail? detail}) {
    if (isClosed) return;
    emit(
      PlaylistsLoaded(
        playlists: _repo.getAll(),
        detail: detail ?? _currentDetail,
      ),
    );
  }

  void _emitError(Object error, StackTrace stack, String origin) {
    if (isClosed) return;
    emit(PlaylistsError(AppError.from(error, stack, origin: origin)));
  }

  Future<void> loadPlaylists() async {
    try {
      _emitLoaded();
    } catch (e, st) {
      _emitError(e, st, 'PlaylistCubit.loadPlaylists');
    }
  }

  Future<void> loadPlaylistDetail(Playlist playlist) async {
    _emitLoaded(detail: PlaylistDetail(playlist: playlist, isLoading: true));
    try {
      final tunes = await _resolveAndPrune(playlist);
      _emitLoaded(
        detail: PlaylistDetail(playlist: playlist, tunes: tunes),
      );
    } catch (e, st) {
      _emitLoaded(
        detail: PlaylistDetail(
          playlist: playlist,
          error: AppError.from(
            e,
            st,
            origin: 'PlaylistCubit.loadPlaylistDetail',
          ),
        ),
      );
    }
  }

  Future<void> createPlaylist({
    required String name,
    String? description,
    List<String> songPaths = const [],
  }) async {
    try {
      await _repo.create(
        name: name,
        description: description,
        songPaths: songPaths,
      );
    } catch (e, st) {
      _emitError(e, st, 'PlaylistCubit.createPlaylist');
      return;
    }
    _emitLoaded();
  }

  Future<void> renamePlaylist(Playlist playlist, String name) async {
    // The repository mutates synchronously, so the new name/order is visible
    // before the disk write completes (optimistic UI).
    final pending = _repo.rename(playlist, name);
    _emitLoaded();
    await _persist(pending, 'PlaylistCubit.renamePlaylist');
  }

  Future<void> deletePlaylist(Playlist playlist) async {
    final deletingCurrent = _currentDetail.playlist?.key == playlist.key;
    try {
      await _repo.delete(playlist);
    } catch (e, st) {
      _emitError(e, st, 'PlaylistCubit.deletePlaylist');
      return;
    }
    if (deletingCurrent) {
      _emitLoaded(detail: const PlaylistDetail());
    } else {
      _emitLoaded();
    }
  }

  Future<void> setDescription(Playlist playlist, String? description) async {
    final pending = _repo.setDescription(playlist, description);
    _emitLoaded();
    await _persist(pending, 'PlaylistCubit.setDescription');
  }

  Future<void> addSongs(Playlist playlist, List<String> paths) async {
    if (paths.isEmpty) return;
    try {
      await _repo.addSongs(playlist, paths);
    } catch (e, st) {
      _emitError(e, st, 'PlaylistCubit.addSongs');
      return;
    }
    await _refreshFor(playlist);
  }

  Future<void> removeSong(Playlist playlist, String path) async {
    try {
      await _repo.removeSong(playlist, path);
    } catch (e, st) {
      _emitError(e, st, 'PlaylistCubit.removeSong');
      return;
    }
    await _refreshFor(playlist);
  }

  Future<void> reorderSongs(Playlist playlist, List<String> paths) async {
    try {
      await _repo.reorderSongs(playlist, paths);
    } catch (e, st) {
      _emitError(e, st, 'PlaylistCubit.reorderSongs');
      return;
    }
    await _refreshFor(playlist);
  }

  Future<void> _refreshFor(Playlist playlist) async {
    if (_currentDetail.playlist?.key != playlist.key) {
      _emitLoaded();
      return;
    }
    try {
      final tunes = await _resolveAndPrune(playlist);
      _emitLoaded(
        detail: PlaylistDetail(playlist: playlist, tunes: tunes),
      );
    } catch (e, st) {
      _emitLoaded(
        detail: PlaylistDetail(
          playlist: playlist,
          error: AppError.from(e, st, origin: 'PlaylistCubit.refreshPlaylist'),
        ),
      );
    }
  }

  Future<void> _persist(Future<void> pending, String origin) async {
    try {
      await pending;
    } catch (e, st) {
      _emitError(e, st, origin);
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
      await _repo.pruneMissing(playlist, resolved.map((t) => t.path).toList());
    }
    return resolved;
  }

  @override
  Future<void> close() {
    _librarySub.cancel();
    return super.close();
  }
}
