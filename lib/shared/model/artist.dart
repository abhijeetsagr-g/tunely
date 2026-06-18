import 'package:tunely/shared/model/tune.dart';

class Artist {
  final int artistId;
  final String artist;
  final List<Tune> tunes;

  const Artist({
    required this.artist,
    required this.tunes,
    required this.artistId,
  });

  static List<Artist> fromTunes(List<Tune> tunes) {
    final Map<String, List<Tune>> artistMap = {};
    for (final tune in tunes) {
      for (final name in tune.artists) {
        artistMap.putIfAbsent(name, () => []).add(tune);
      }
    }
    return artistMap.entries
        .map(
          (e) =>
              Artist(artistId: e.key.hashCode, artist: e.key, tunes: e.value),
        )
        .toList();
  }
}
