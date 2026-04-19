import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/shared/model/artist.dart';
import 'package:tunely/shared/model/tune.dart';

class SearchResult {
  final List<Artist> artists;
  final List<AlbumModel> albums;
  final List<Tune> tunes;
  final List<GenreModel> genres;
  final List<PlaylistModel> playlists;

  SearchResult({
    required this.artists,
    required this.albums,
    required this.tunes,
    required this.genres,
    required this.playlists,
  });
}
