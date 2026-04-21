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
}
