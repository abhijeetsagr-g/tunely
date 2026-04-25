import 'package:tunely/shared/model/artist.dart';
import 'package:tunely/shared/model/tune.dart';

class LibraryRepository {
  List<Tune> _tuneCache = [];
  List<Artist> _artistCache = [];

  List<Tune> get tunes => _tuneCache;
  List<Artist> get artists => _artistCache;

  void saveTunes(List<Tune> tunes) => _tuneCache = tunes;
  void saveArtists(List<Artist> artists) => _artistCache = artists;

  List<Tune> getTunesByGenre(String genre) {
    return _tuneCache
        .where((tune) => tune.genre.toLowerCase() == genre.toLowerCase())
        .toList();
  }

  List<Tune> getTunesByAlbum(int albumId) {
    return _tuneCache.where((tune) => tune.albumId == albumId).toList()
      ..sort((a, b) {
        if (a.trackIndex == null && b.trackIndex == null) return 0;
        if (a.trackIndex == null) return 1;
        if (b.trackIndex == null) return -1;
        return a.trackIndex!.compareTo(b.trackIndex!);
      });
  }

  void clear() {
    _tuneCache = [];
    _artistCache = [];
  }
}
