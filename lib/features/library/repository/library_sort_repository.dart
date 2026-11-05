import 'package:shared_preferences/shared_preferences.dart';
import 'package:tunely/features/library/helper/sort.dart';

class LibrarySortRepo {
  final SharedPreferences _prefs;
  LibrarySortRepo(this._prefs);

  static const _tuneKey = 'sort_tunes';
  static const _albumKey = 'sort_albums';
  static const _artistKey = 'sort_artists';

  static Future<LibrarySortRepo> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LibrarySortRepo(prefs);
  }

  T _readEnum<T extends Enum>(String key, List<T> values, T fallback) {
    final raw = _prefs.getString('${key}_type');
    return values.firstWhere((e) => e.name == raw, orElse: () => fallback);
  }

  bool _readAsc(String key) => _prefs.getBool('${key}_asc') ?? true;

  bool _readHideSingles(String key) =>
      _prefs.getBool('${key}_hide_singles') ?? true;

  Future<void> _write(String key, Enum type, bool asc) async {
    await _prefs.setString('${key}_type', type.name);
    await _prefs.setBool('${key}_asc', asc);
  }

  // Tunes
  (TuneSortType, bool) getTuneSort() => (
    _readEnum(_tuneKey, TuneSortType.values, TuneSortType.name),
    _readAsc(_tuneKey),
  );
  Future<void> setTuneSort(TuneSortType t, bool asc) =>
      _write(_tuneKey, t, asc);

  // Albums
  (AlbumSort, bool) getAlbumSort() => (
    _readEnum(_albumKey, AlbumSort.values, AlbumSort.songCount),
    _readAsc(_albumKey),
  );
  Future<void> setAlbumSort(AlbumSort t, bool asc) => _write(_albumKey, t, asc);

  bool getAlbumHideSingles() => _readHideSingles(_albumKey);
  Future<void> setAlbumHideSingles(bool value) =>
      _prefs.setBool('${_albumKey}_hide_singles', value);

  // Artists
  (ArtistSort, bool) getArtistSort() => (
    _readEnum(_artistKey, ArtistSort.values, ArtistSort.name),
    _readAsc(_artistKey),
  );
  Future<void> setArtistSort(ArtistSort t, bool asc) =>
      _write(_artistKey, t, asc);

  bool getArtistHideSingles() => _readHideSingles(_artistKey);
  Future<void> setArtistHideSingles(bool value) =>
      _prefs.setBool('${_artistKey}_hide_singles', value);
}
