import 'package:on_audio_query/on_audio_query.dart';

abstract class AudioQueryService {
  static final OnAudioQuery _audioQuery = OnAudioQuery();

  // Request Permission
  static Future<bool> _hasPermission() async =>
      _audioQuery.permissionsRequest();

  static Future<List<SongModel>> getFilteredSongs(
    AudiosFromType type,
    int target,
  ) async {
    if (await _hasPermission() == false) return [];
    return await _audioQuery.queryAudiosFrom(type, target);
  }

  static Future<List<SongModel>> getSong({SongSortType sort = .TITLE}) async {
    if (await _hasPermission() == false) return [];
    return _audioQuery.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );
  }

  // filters
  static Future<List<AlbumModel>> get getAlbums async =>
      _audioQuery.queryAlbums();
  static Future<List<ArtistModel>> get getArtists async =>
      _audioQuery.queryArtists();
  static Future<List<PlaylistModel>> get getPlaylists async =>
      _audioQuery.queryPlaylists();
  static Future<List<GenreModel>> get getGenres async =>
      _audioQuery.queryGenres();
}
