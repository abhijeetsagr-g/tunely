import 'package:tunely/shared/model/artist.dart';
import 'package:tunely/shared/model/tune.dart';

class LibraryRepository {
  List<Tune> _tuneCache = [];
  List<Artist> _artistCache = [];

  List<Tune> get tunes => _tuneCache;
  List<Artist> get artists => _artistCache;

  void saveTunes(List<Tune> tunes) => _tuneCache = tunes;
  void saveArtists(List<Artist> artists) => _artistCache = artists;

  void clear() {
    _tuneCache = [];
    _artistCache = [];
  }
}
