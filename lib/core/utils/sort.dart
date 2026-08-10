import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/shared/model/artist.dart';
import 'package:tunely/shared/model/tune.dart';

enum TuneSortType { name, dateAdded, duration }

enum AlbumSort { name, duration, songCount }

enum ArtistSort { name, songCount }

abstract class Sort {
  static List<Tune> sortTunes(
    List<Tune> tunes, {
    TuneSortType type = TuneSortType.name,
    bool ascending = true,
  }) {
    final sorted = [...tunes];
    sorted.sort((a, b) {
      final cmp = switch (type) {
        TuneSortType.name => a.title
            .toLowerCase()
            .compareTo(b.title.toLowerCase()),
        TuneSortType.dateAdded => a.dateAdded.compareTo(b.dateAdded),
        TuneSortType.duration => a.duration.compareTo(b.duration),
      };
      return ascending ? cmp : -cmp;
    });
    return sorted;
  }

  static List<AlbumModel> sortAlbums(
    List<AlbumModel> albums, {
    Map<int, Duration>? durations,
    AlbumSort type = AlbumSort.name,
    bool ascending = true,
  }) {
    final sorted = [...albums];
    sorted.sort((a, b) {
      final cmp = switch (type) {
        AlbumSort.name => a.album
            .toLowerCase()
            .compareTo(b.album.toLowerCase()),
        AlbumSort.songCount => a.numOfSongs.compareTo(b.numOfSongs),
        AlbumSort.duration => (durations?[a.id] ?? Duration.zero)
            .compareTo(durations?[b.id] ?? Duration.zero),
      };
      return ascending ? cmp : -cmp;
    });
    return sorted;
  }

  static List<Artist> sortArtists(
    List<Artist> artists, {
    ArtistSort type = ArtistSort.name,
    bool ascending = true,
  }) {
    final sorted = [...artists];
    sorted.sort((a, b) {
      final cmp = switch (type) {
        ArtistSort.name => a.artist
            .toLowerCase()
            .compareTo(b.artist.toLowerCase()),
        ArtistSort.songCount => a.tunes.length.compareTo(b.tunes.length),
      };
      return ascending ? cmp : -cmp;
    });
    return sorted;
  }
}
