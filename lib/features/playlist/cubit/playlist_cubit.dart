import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/features/playlist/service/playlist_service.dart';
import 'package:tunely/features/music_management/repository/management_repository.dart';
import 'package:tunely/shared/model/tune.dart';

part 'playlist_state.dart';

class PlaylistCubit extends Cubit<PlaylistState> {
  final PlaylistService _service;
  final ManagementRepository _managementRepo;

  PlaylistCubit(this._service, this._managementRepo)
    : super(const PlaylistInitial());

  // Load all playlists
  Future<void> fetchPlaylists() async {
    emit(const PlaylistLoading());
    try {
      final playlists = await _service.fetchPlaylist();
      emit(PlaylistLoaded(playlists: playlists));
    } catch (e) {
      emit(PlaylistError('Failed to load playlists'));
    }
  }

  // Load songs inside a playlist
  Future<void> fetchTunes(int playlistId) async {
    final s = state;
    if (s is! PlaylistLoaded) return;
    emit(s.copyWith(loadingTunes: true));
    try {
      final settings = _managementRepo.get();
      final tunes = await _service.fetchTunesByPlaylistId(playlistId, settings);
      emit(
        s.copyWith(
          loadingTunes: false,
          tunesCache: {...s.tunesCache, playlistId: tunes},
        ),
      );
    } catch (e) {
      emit(s.copyWith(loadingTunes: false));
    }
  }

  // Create a new playlist
  Future<void> createPlaylist(String name) async {
    try {
      await _service.createPlaylist(name);
      await fetchPlaylists();
    } catch (e) {
      emit(PlaylistError('Failed to create playlist'));
    }
  }

  // Delete a playlist
  Future<void> removePlaylist(int playlistId) async {
    try {
      await _service.removePlaylist(playlistId);
      final s = state;
      if (s is! PlaylistLoaded) return;
      final updatedCache = {...s.tunesCache}..remove(playlistId);
      emit(
        s.copyWith(
          playlists: s.playlists.where((p) => p.id != playlistId).toList(),
          tunesCache: updatedCache,
        ),
      );
    } catch (e) {
      emit(PlaylistError('Failed to remove playlist'));
    }
  }

  // Rename a playlist
  Future<void> renamePlaylist(int playlistId, String newName) async {
    try {
      await _service.renamePlaylist(playlistId, newName);
      await fetchPlaylists();
    } catch (e) {
      emit(PlaylistError('Failed to rename playlist'));
    }
  }

  // Add a song to a playlist
  Future<void> addToPlaylist(int playlistId, Tune tune) async {
    if (tune.songId == null) return;
    try {
      await _service.addToPlaylist(playlistId, tune.songId!);
      // Invalidate cache for this playlist so next fetch is fresh
      final s = state;
      if (s is! PlaylistLoaded) return;
      final updatedCache = {...s.tunesCache}..remove(playlistId);
      emit(s.copyWith(tunesCache: updatedCache));
    } catch (e) {
      emit(PlaylistError('Failed to add song'));
    }
  }

  // Remove a song from a playlist
  Future<void> removeFromPlaylist(int playlistId, Tune tune) async {
    if (tune.songId == null) return;
    try {
      await _service.removeFromPlaylist(playlistId, tune.songId!);
      final s = state;
      if (s is! PlaylistLoaded) return;
      final updatedTunes = s.tunesCache[playlistId]
          ?.where((t) => t.songId != tune.songId)
          .toList();
      final updatedCache = {
        ...s.tunesCache,
        if (updatedTunes != null) playlistId: updatedTunes,
      };
      emit(s.copyWith(tunesCache: updatedCache));
    } catch (e) {
      emit(PlaylistError('Failed to remove song'));
    }
  }
}
