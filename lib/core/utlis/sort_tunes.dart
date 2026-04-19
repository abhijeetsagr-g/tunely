import 'package:tunely/shared/model/tune.dart';

enum SortType { name, duration, album, artist, dateAdded }

enum SortOrder { ascending, descending }

List<Tune> sortTunes(List<Tune> tunes, SortType sort, SortOrder order) {
  final sorted = [...tunes];
  switch (sort) {
    case SortType.name:
      sorted.sort((a, b) => a.title.compareTo(b.title));
    case SortType.duration:
      sorted.sort((a, b) => a.duration.compareTo(b.duration));
    case SortType.album:
      sorted.sort((a, b) => a.album.compareTo(b.album));
    case SortType.artist:
      sorted.sort((a, b) => a.artist.compareTo(b.artist));
    case SortType.dateAdded:
      sorted.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));
  }

  return order == SortOrder.descending ? sorted.reversed.toList() : sorted;
}
