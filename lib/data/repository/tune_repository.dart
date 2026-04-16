import 'package:collection/collection.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/shared/model/tune.dart';

enum TuneSortType { title, artist, recentlyAdded, album }

class TuneRepository {
  List<Tune> _tunes = [];
  List<AlbumModel> _albums = [];
  List<ArtistModel> _artists = [];
  List<GenreModel> _genres = [];
  List<PlaylistModel> _playlists = [];

  Map<String, List<int>> _artistTuneMap = {};
  Map<String, int> _artistIdMap = {};
  Map<String, Tune> _tuneByPath = {};

  List<Tune> get tunes => List.unmodifiable(_tunes);
  List<AlbumModel> get albums => List.unmodifiable(_albums);
  List<ArtistModel> get artists => List.unmodifiable(_artists);
  List<GenreModel> get genres => List.unmodifiable(_genres);
  List<PlaylistModel> get playlists => List.unmodifiable(_playlists);
  List<String> get artistNames =>
      List.unmodifiable(_artistTuneMap.keys.toList());

  void loadAllSongs(List<SongModel> songs) {
    _tunes = songs.map((e) => Tune.fromSongModel(e)).toList();
    _tuneByPath = {for (final t in _tunes) t.path: t};
    _buildArtistMap();
  }

  void loadLibrary({
    required List<AlbumModel> albums,
    required List<ArtistModel> artists,
    required List<GenreModel> genres,
    required List<PlaylistModel> playlists,
  }) {
    _albums = albums;
    _artists = artists;
    _genres = genres;
    _playlists = playlists;
  }

  void _buildArtistMap() {
    _artistTuneMap = {};
    _artistIdMap = {};
    for (final tune in _tunes) {
      final artists = tune.artist.split('/').map((a) => a.trim());
      for (final artist in artists) {
        _artistTuneMap.putIfAbsent(artist, () => []).add(tune.songId!);
        if (tune.artistId != null) {
          _artistIdMap.putIfAbsent(artist, () => tune.artistId!);
        }
      }
    }
  }

  List<Tune> tunesByArtistName(String name) {
    final ids = _artistTuneMap[name] ?? [];
    return _tunes.where((t) => ids.contains(t.songId)).toList();
  }

  int? artistIdByName(String name) => _artistIdMap[name];

  List<Tune> sorted(List<Tune> tunes, TuneSortType type) {
    final copy = [...tunes];
    switch (type) {
      case TuneSortType.title:
        copy.sort((a, b) => a.title.compareTo(b.title));
      case TuneSortType.artist:
        copy.sort((a, b) => a.artist.compareTo(b.artist));
      case TuneSortType.recentlyAdded:
        copy.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
      case TuneSortType.album:
        copy.sort((a, b) => a.album.compareTo(b.album));
    }
    return copy;
  }

  List<Tune> loadRecommend([int count = 8]) =>
      (_tunes.toList()..shuffle()).take(count).toList();

  Tune? findByPath(String path) => _tuneByPath[path];
  AlbumModel? albumById(int id) => _albums.firstWhereOrNull((a) => a.id == id);
  ArtistModel? artistById(int id) =>
      _artists.firstWhereOrNull((a) => a.id == id);
  GenreModel? genreById(int id) => _genres.firstWhereOrNull((g) => g.id == id);
  PlaylistModel? playlistById(int id) =>
      _playlists.firstWhereOrNull((p) => p.id == id);

  List<AlbumModel> searchAlbums(String query) => _albums
      .where((a) => a.album.toLowerCase().contains(query.toLowerCase()))
      .toList();
  List<String> searchArtists(String query) => _artistTuneMap.keys
      .where((a) => a.toLowerCase().contains(query.toLowerCase()))
      .toList();
  List<Tune> searchTune(String query) =>
      _tunes.where((t) => t.title.toLowerCase().contains(query)).toList();
}
