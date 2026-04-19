import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/features/library/utils/tune_praser.dart';
import 'package:tunely/features/music_management/model/management_settings.dart';
import 'package:tunely/shared/model/tune.dart';

class PlaylistService {
  final OnAudioQuery audioQuery;

  PlaylistService({required this.audioQuery});

  Future<void> createPlaylist(String name) async =>
      await audioQuery.createPlaylist(name);

  Future<void> removePlaylist(int playlistId) async =>
      audioQuery.removePlaylist(playlistId);

  Future<void> renamePlaylist(int playlistId, String newName) async =>
      audioQuery.renamePlaylist(playlistId, newName);

  Future<void> addToPlaylist(int playlistId, int songId) async =>
      audioQuery.addToPlaylist(playlistId, songId);

  Future<void> removeFromPlaylist(int playlistId, int songId) async =>
      await audioQuery.removeFromPlaylist(playlistId, songId);

  Future<List<PlaylistModel>> fetchPlaylist() async =>
      await audioQuery.queryPlaylists();

  Future<List<Tune>> fetchTunesByPlaylistId(
    int playlistId,
    ManagementSettings settings,
  ) async {
    final songs = await audioQuery.queryAudiosFrom(
      AudiosFromType.PLAYLIST,
      playlistId,
    );
    return TuneParser.parse(songs, settings);
  }
}
