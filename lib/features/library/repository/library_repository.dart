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
        print("TRACK INDEX  = ${a.title}: ${a.trackIndex}; ");
        final aTrack = a.trackIndex == null || a.trackIndex == 0
            ? null
            : a.trackIndex;
        final bTrack = b.trackIndex == null || b.trackIndex == 0
            ? null
            : b.trackIndex;
        if (aTrack != null && bTrack != null) return aTrack.compareTo(bTrack);
        if (aTrack != null) return -1;
        if (bTrack != null) return 1;
        return a.path.compareTo(b.path);
      });
  }

  void clear() {
    _tuneCache = [];
    _artistCache = [];
  }
}
