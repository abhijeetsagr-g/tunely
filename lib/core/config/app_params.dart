import 'package:tunely/data/model/tune.dart';

class AlbumViewParams {
  final int album;
  final List<Tune>? tunes;

  const AlbumViewParams({required this.album, this.tunes});
}
