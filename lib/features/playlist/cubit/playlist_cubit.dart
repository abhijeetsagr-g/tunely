import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/features/music_management/model/management_settings.dart';
import 'package:tunely/features/playlist/service/playlist_service.dart';
import 'package:tunely/shared/model/tune.dart';

part 'playlist_state.dart';

class PlaylistCubit extends Cubit<PlaylistState> {
  final PlaylistService _service;
  PlaylistCubit({required PlaylistService service})
    : _service = service,
      super(PlaylistState());

  // load playlists
  Future<void> loadPlaylist() async {
    final playlists = await _service.getPlaylists();
    emit(LoadedPlaylist(playlists: playlists));
  }

  // fetch songs from playlist
  Future<List<Tune>> getSongs(
    int playlistId,
    ManagementSettings settings,
  ) async => await _service.getSongsFromPlaylist(playlistId, settings);

  // CRUD FOR Playlist
  Future<void> createPlaylist({required String name, String? desc}) async {
    await _service.createPlaylist(name, desc: desc);
    await loadPlaylist();
  }

  Future<void> renamePlaylist(int playlistId, String newName) async {
    await _service.renamePlaylist(playlistId, newName);
    await loadPlaylist();
  }

  Future<void> deletePlaylist(int playlistId) async {
    await _service.deletePlaylist(playlistId);
    await loadPlaylist();
  }

  Future<void> addTune(int playlistId, int songId) async {
    await _service.addTune(playlistId, songId);
  }

  Future<void> addTunes(int playlistId, List<int> songIds) async {
    await _service.addTunes(playlistId, songIds);
  }

  Future<void> removeTune(int playlistId, int songId) async {
    await _service.removeTune(playlistId, songId);
  }
}
