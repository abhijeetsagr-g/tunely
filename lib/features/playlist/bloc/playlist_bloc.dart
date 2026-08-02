import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/features/music_management/model/management_settings.dart';
import 'package:tunely/features/playlist/service/playlist_service.dart';
import 'package:tunely/shared/model/tune.dart';

part 'playlist_event.dart';
part 'playlist_state.dart';

class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  final PlaylistService _service;
  ManagementSettings? _lastSettings;

  PlaylistBloc({required PlaylistService service})
    : _service = service,
      super(PlaylistLoading()) {
    on<LoadPlaylistsEvent>(_onLoadPlaylists);
    on<CreatePlaylistEvent>(_onCreatePlaylist);
    on<RenamePlaylistEvent>(_onRenamePlaylist);
    on<DeletePlaylistEvent>(_onDeletePlaylist);
    on<LoadSongsEvent>(_onLoadSongs);
    on<RemoveSongEvent>(_onRemoveSong);
    on<AddSongsEvent>(_onAddSongs);
  }

  PlaylistDetailState get _currentDetail =>
      state is LoadedPlaylist
      ? (state as LoadedPlaylist).detail
      : const PlaylistDetailState();

  Future<void> _onLoadPlaylists(
    LoadPlaylistsEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    final detail = _currentDetail;
    emit(PlaylistLoading());
    try {
      final playlists = await _service.getPlaylists();
      emit(LoadedPlaylist(playlists: playlists, detail: detail));
    } catch (e) {
      emit(PlaylistError(error: e.toString()));
    }
  }

  Future<void> _onCreatePlaylist(
    CreatePlaylistEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    await _service.createPlaylist(event.name, desc: event.desc);
    await _loadPlaylists(emit);

    if (event.songIds != null &&
        event.songIds!.isNotEmpty &&
        state is LoadedPlaylist) {
      final playlists = (state as LoadedPlaylist).playlists;
      final created = playlists.lastWhere((p) => p.playlist == event.name);
      await _service.addTunes(created.id, event.songIds!);
      await _loadPlaylists(emit);
    }
  }

  Future<void> _onRenamePlaylist(
    RenamePlaylistEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    await _service.renamePlaylist(event.playlistId, event.newName);
    await _loadPlaylists(emit);
  }

  Future<void> _onDeletePlaylist(
    DeletePlaylistEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    await _service.deletePlaylist(event.playlistId);
    await _loadPlaylists(emit);
  }

  Future<void> _onLoadSongs(
    LoadSongsEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    _lastSettings = event.settings;
    final playlists = state is LoadedPlaylist
        ? (state as LoadedPlaylist).playlists
        : const <PlaylistModel>[];
    emit(
      LoadedPlaylist(
        playlists: playlists,
        detail: PlaylistDetailState(
          playlistId: event.playlistId,
          isLoading: true,
        ),
      ),
    );
    try {
      final tunes = await _service.getSongsFromPlaylist(
        event.playlistId,
        event.settings,
      );
      if (state is! LoadedPlaylist) return;
      emit(
        LoadedPlaylist(
          playlists: (state as LoadedPlaylist).playlists,
          detail: PlaylistDetailState(
            playlistId: event.playlistId,
            songs: tunes,
          ),
        ),
      );
    } catch (e) {
      if (state is! LoadedPlaylist) return;
      emit(
        LoadedPlaylist(
          playlists: (state as LoadedPlaylist).playlists,
          detail: PlaylistDetailState(
            playlistId: event.playlistId,
            error: e.toString(),
          ),
        ),
      );
    }
  }

  Future<void> _onRemoveSong(
    RemoveSongEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    final s = state;
    if (s is! LoadedPlaylist || s.detail.playlistId != event.playlistId) return;
    final updated = List<Tune>.from(s.detail.songs)
      ..removeWhere((t) => t.songId == event.songId);
    emit(
      LoadedPlaylist(
        playlists: s.playlists,
        detail: s.detail.copyWith(songs: updated),
      ),
    );
    await _service.removeTune(event.playlistId, event.songId);
  }

  Future<void> _onAddSongs(
    AddSongsEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    if (event.songIds.isEmpty) return;
    await _service.addTunes(event.playlistId, event.songIds);
    final settings = _lastSettings;
    if (settings != null) {
      await _onLoadSongs(
        LoadSongsEvent(playlistId: event.playlistId, settings: settings),
        emit,
      );
    }
  }

  Future<void> _loadPlaylists(Emitter<PlaylistState> emit) =>
      _onLoadPlaylists(LoadPlaylistsEvent(), emit);
}
