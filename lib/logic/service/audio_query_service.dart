import 'package:on_audio_query/on_audio_query.dart';

class AudioQueryService {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  // Request Permission
  Future<bool> _hasPermission() async {
    final hasPermission = await _audioQuery.permissionsStatus();
    if (hasPermission) return true;
    return _audioQuery.permissionsRequest();
  }

  Future<List<SongModel>> getFilteredSongs(
    AudiosFromType type,
    int target, {
    SongSortType sort = .TITLE,
  }) async {
    if (await _hasPermission() == false) return [];
    return await _audioQuery.queryAudiosFrom(type, target, sortType: sort);
  }

  Future<List<SongModel>> getSong({SongSortType sort = .TITLE}) async {
    if (await _hasPermission() == false) return [];
    return _audioQuery.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );
  }

  Future<List<AlbumModel>> getAlbums() => _audioQuery.queryAlbums();
  Future<List<ArtistModel>> getArtists() => _audioQuery.queryArtists();
  Future<List<PlaylistModel>> getPlaylists() => _audioQuery.queryPlaylists();
  Future<List<GenreModel>> getGenres() => _audioQuery.queryGenres();
}
