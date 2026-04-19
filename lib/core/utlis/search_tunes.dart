import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/shared/model/artist.dart';
import 'package:tunely/shared/model/tune.dart';

abstract class SearchFunctions {
  static List<Tune> filterTunes(List<Tune> tunes, String query) {
    if (query.trim().isEmpty) return tunes;
    final q = query.toLowerCase();
    return tunes.where((t) => t.title.toLowerCase().contains(q)).toList();
  }

  static List<Artist> filterArtist(List<Artist> artists, String query) {
    if (query.trim().isEmpty) return artists;
    final q = query.toLowerCase();
    return artists.where((a) => a.artist.toLowerCase().contains(q)).toList();
  }

  static List<AlbumModel> filterAlbum(List<AlbumModel> albums, String query) {
    if (query.trim().isEmpty) return albums;
    final q = query.toLowerCase();
    return albums.where((a) => a.album.toLowerCase().contains(q)).toList();
  }

  static List<GenreModel> filterGenre(List<GenreModel> genres, String query) {
    if (query.trim().isEmpty) return genres;
    final q = query.toLowerCase();
    return genres.where((g) => g.genre.toLowerCase().contains(q)).toList();
  }

  static List<PlaylistModel> filterPlaylist(
    List<PlaylistModel> playlist,
    String query,
  ) {
    if (query.trim().isEmpty) return playlist;
    final q = query.toLowerCase();
    return playlist.where((p) => p.playlist.toLowerCase().contains(q)).toList();
  }
}
