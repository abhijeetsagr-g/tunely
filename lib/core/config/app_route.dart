import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/data/model/tune.dart';

class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const player = '/player';
  static const album = '/album';
  static const filtered = '/filtered';
  static const generic = '/generic';
}

class AlbumViewArgs {
  final AlbumModel album;
  final List<Tune> tunes;
  const AlbumViewArgs({required this.album, required this.tunes});
}

enum FilterType { album, playlist, genres, artists }

class FilteredListArgs {
  final FilterType type;
  const FilteredListArgs(this.type);
}

class GenericViewArgs {
  final FilterType type;
  final String name;
  final int id;
  const GenericViewArgs({
    required this.type,
    required this.name,
    required this.id,
  });
}
