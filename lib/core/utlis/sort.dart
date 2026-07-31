import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/shared/model/artist.dart';
import 'package:tunely/shared/model/tune.dart';

abstract class Sort {
  static List<Tune> sortTunes(List<Tune> tunes) {
    final sorted = [...tunes];
    sorted.sort(
      (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    );
    return sorted;
  }

  static List<AlbumModel> sortAlbums(List<AlbumModel> albums) {
    final sorted = [...albums];
    sorted.sort(
      (a, b) => (a.album).toLowerCase().compareTo((b.album).toLowerCase()),
    );
    return sorted;
  }

  static List<Artist> sortArtists(List<Artist> artists) {
    final sorted = [...artists];
    sorted.sort(
      (a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()),
    );
    return sorted;
  }
}
