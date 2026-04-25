import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/core/utlis/tune_praser.dart';
import 'package:tunely/features/music_management/model/management_settings.dart';
import 'package:tunely/shared/model/tune.dart';

class PlaylistService {
  final OnAudioQuery _query;

  PlaylistService({required OnAudioQuery query}) : _query = query;

  // fetch
  Future<List<PlaylistModel>> getPlaylists() async {
    return await _query.queryPlaylists();
  }

  Future<List<Tune>> getSongsFromPlaylist(
    int playlistId,
    ManagementSettings settings,
  ) async {
    final songs = await _query.queryAudiosFrom(
      AudiosFromType.PLAYLIST,
      playlistId,
    );

    return TuneParser.parse(songs, settings);
  }

  // CRUD
  Future<bool> createPlaylist(String name, {String? desc}) async {
    return await _query.createPlaylist(name, desc: desc);
  }

  Future<bool> renamePlaylist(int playlistId, String name) async {
    return await _query.renamePlaylist(playlistId, name);
  }

  Future<bool> deletePlaylist(int playlistId) async {
    return await _query.removePlaylist(playlistId);
  }

  // Tunes
  Future<bool> addTune(int playlistId, int songId) async {
    return await _query.addToPlaylist(playlistId, songId);
  }

  Future<List<int>> addTunes(int playlistId, List<int> songIds) async {
    final failed = <int>[];

    for (final id in songIds) {
      final result = await _query.addToPlaylist(playlistId, id);
      if (!result) failed.add(id);
    }

    return failed;
  }

  Future<bool> removeTune(int playlistId, int songId) async {
    return await _query.removeFromPlaylist(playlistId, songId);
  }
}
