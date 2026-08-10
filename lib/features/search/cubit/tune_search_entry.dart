part of 'search_cubit.dart';

class TuneSearchEntry {
  final Tune tune;
  final String titleLc;
  final String artistLc;
  final String albumLc;
  final String genreLc;

  TuneSearchEntry(this.tune)
    : titleLc = tune.title.toLowerCase(),
      artistLc = tune.artist.toLowerCase(),
      albumLc = tune.album.toLowerCase(),
      genreLc = tune.genre.toLowerCase();
}

List<TuneSearchEntry>? tuneIndex;
List<MapEntry<Artist, String>>? artistIndex;
List<MapEntry<AlbumModel, String>>? albumIndex;
