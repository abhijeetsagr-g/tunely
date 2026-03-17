import 'package:collection/collection.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/data/model/tune.dart';
import 'package:tunely/logic/provider/playback/playback_bloc.dart';

class TuneRepository {
  List<Tune> _tunes = [];
  List<AlbumModel> _albums = [];
  List<ArtistModel> _artists = [];
  List<GenreModel> _genres = [];
  List<PlaylistModel> _playlists = [];

  List<Tune> get tunes => List.unmodifiable(_tunes);
  List<AlbumModel> get albums => List.unmodifiable(_albums);
  List<ArtistModel> get artists => List.unmodifiable(_artists);
  List<GenreModel> get genres => List.unmodifiable(_genres);
  List<PlaylistModel> get playlists => List.unmodifiable(_playlists);

  void loadAllSongs(List<SongModel> songs) {
    _tunes = songs.map((e) => Tune.fromSongModel(e)).toList();
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

  List<Tune> sortTunes(TuneSortType type) {
    final sorted = [..._tunes];
    switch (type) {
      case TuneSortType.title:
        sorted.sort((a, b) => a.title.compareTo(b.title));
      case TuneSortType.artist:
        sorted.sort((a, b) => a.artist.compareTo(b.artist));
      case TuneSortType.recentlyAdded:
        sorted.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
      case TuneSortType.album:
        sorted.sort((a, b) => a.album.compareTo(b.album));
    }
    return sorted;
  }

  // Lookups
  Tune? findByPath(String path) =>
      _tunes.firstWhereOrNull((t) => t.path == path);
  AlbumModel? albumById(int id) => _albums.firstWhereOrNull((a) => a.id == id);
  ArtistModel? artistById(int id) =>
      _artists.firstWhereOrNull((a) => a.id == id);
  GenreModel? genreById(int id) => _genres.firstWhereOrNull((g) => g.id == id);
  PlaylistModel? playlistById(int id) =>
      _playlists.firstWhereOrNull((p) => p.id == id);

  // Search
  List<AlbumModel> searchAlbums(String query) => _albums
      .where((a) => a.album.toLowerCase().contains(query.toLowerCase()))
      .toList();
  List<ArtistModel> searchArtists(String query) => _artists
      .where((a) => a.artist.toLowerCase().contains(query.toLowerCase()))
      .toList();
  List<Tune> searchTune(String query) =>
      _tunes.where((t) => t.title.toLowerCase().contains(query)).toList();
}
