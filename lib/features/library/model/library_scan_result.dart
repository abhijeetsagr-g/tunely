import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/shared/model/artist.dart';
import 'package:tunely/shared/model/tune.dart';

class LibraryScanResult {
  final List<Tune> tunes;
  final List<Artist> artists;
  final List<AlbumModel> albums;
  final List<GenreModel> genres;
  final List<PlaylistModel> playlists;

  LibraryScanResult({
    required this.tunes,
    required this.artists,
    required this.albums,
    required this.genres,
    required this.playlists,
  });
}
