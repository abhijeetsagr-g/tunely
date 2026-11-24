import 'dart:math';
import 'dart:typed_data';

import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/features/library/model/library_scan_result.dart';
import 'package:tunely/features/library/repository/library_repository.dart';
import 'package:tunely/features/library/helper/tune_parser.dart';
import 'package:tunely/features/settings/repository/management_repository.dart';
import 'package:tunely/shared/model/artist.dart';
import 'package:tunely/shared/model/tune.dart';

class LibraryService {
  static const int _minDurationMs = 60 * 1000;
  static const int _maxPerArtist = 2;

  final OnAudioQuery _audioQuery;
  final ManagementRepository _managementRepo;
  final LibraryRepository _libraryRepo;

  LibraryService(this._audioQuery, this._managementRepo, this._libraryRepo);

  Future<bool> hasPermission() => _audioQuery.permissionsStatus();

  Future<bool> requestPermission() => _audioQuery.checkAndRequest();

  Future<LibraryScanResult?> scan() async {
    final permission = await _audioQuery.checkAndRequest();
    if (!permission) return null;

    final songs = await _audioQuery.querySongs(
      sortType: SongSortType.DATE_ADDED,
      orderType: OrderType.DESC_OR_GREATER,
    );

    final settings = _managementRepo.get();
    final tunes = TuneParser.parse(songs, settings);
    final artists = _buildArtists(tunes);

    _libraryRepo.saveTunes(tunes);
    _libraryRepo.saveArtists(artists);

    final albums = await _audioQuery.queryAlbums(
      sortType: AlbumSortType.NUM_OF_SONGS,
      orderType: OrderType.ASC_OR_SMALLER,
    );
    final genres = await _audioQuery.queryGenres();

    return LibraryScanResult(
      tunes: tunes,
      artists: artists,
      albums: albums,
      genres: genres,
    );
  }

  List<Artist> _buildArtists(List<Tune> tunes) => Artist.fromTunes(tunes);

  List<Tune> getTunesByAlbum(int albumId) =>
      _libraryRepo.getTunesByAlbum(albumId);

  void removeTune(String path) => _libraryRepo.removeTune(path);

  // ---------------------------------------------------------------------------
  // Daily mix
  // ---------------------------------------------------------------------------

  int get _todaySeed => DateTime.now().millisecondsSinceEpoch ~/ 86400000;

  Future<List<Tune>> generateDailyMix(List<Tune> tunes) async {
    final todaySeed = _todaySeed;
    final settings = _managementRepo.get();
    final size = settings.dailyMixSize;
    final byPath = {for (final t in tunes) t.path: t};

    // Same day: restore the saved mix, topping up if songs were deleted.
    if (settings.dailyMixDateSeed == todaySeed &&
        settings.dailyMixTunePaths != null) {
      final restored = settings.dailyMixTunePaths!
          .map((p) => byPath[p])
          .whereType<Tune>()
          .toList();

      if (restored.isNotEmpty) {
        if (restored.length >= size) return restored;

        final fill = _buildMix(
          tunes,
          seed: todaySeed,
          count: size - restored.length,
          exclude: {
            ...restored.map((t) => t.path),
            ...?settings.dailyMixPreviousPaths,
          },
        );
        final mix = [...restored, ...fill];
        await _saveDailyMix(mix, todaySeed);
        return mix;
      }
    }

    // New day: whatever was saved last is "yesterday's" mix, so avoid it.
    final previous = settings.dailyMixTunePaths ?? const <String>[];
    final mix = _buildMix(
      tunes,
      seed: todaySeed,
      count: size,
      exclude: previous.toSet(),
    );
    await _saveDailyMix(mix, todaySeed, previousPaths: previous);
    return mix;
  }

  Future<List<Tune>> refreshDailyMix(List<Tune> tunes) async {
    final settings = _managementRepo.get();

    // Avoid both yesterday's songs and the mix currently on screen.
    final exclude = <String>{
      ...?settings.dailyMixPreviousPaths,
      ...?settings.dailyMixTunePaths,
    };

    // Time-based seed: every refresh differs, even across app restarts.
    final mix = _buildMix(
      tunes,
      seed: DateTime.now().microsecondsSinceEpoch,
      count: settings.dailyMixSize,
      exclude: exclude,
    );

    await _saveDailyMix(
      mix,
      _todaySeed,
      previousPaths: settings.dailyMixPreviousPaths,
    );
    return mix;
  }

  /// Weighted random pick (Efraimidis-Spirakis) with an artist cap.
  List<Tune> _buildMix(
    List<Tune> tunes, {
    required int seed,
    required int count,
    Set<String> exclude = const {},
  }) {
    final random = Random(seed);

    // Weighted shuffle: key = u^(1/w); higher weight tends to a larger key.
    final keyed = tunes.map((t) {
      final key = pow(random.nextDouble(), 1 / _weight(t)).toDouble();
      return (tune: t, key: key);
    }).toList()..sort((a, b) => b.key.compareTo(a.key));

    final perArtist = <String, int>{};
    final mix = <Tune>[];
    for (final e in keyed) {
      final artist = e.tune.artist;
      if ((perArtist[artist] ?? 0) >= _maxPerArtist) continue;
      perArtist[artist] = (perArtist[artist] ?? 0) + 1;
      mix.add(e.tune);
      if (mix.length >= count) break;
    }

    // Small library fallback: relax the artist cap, then the exclusions.
    if (mix.length < count) {
      final picked = mix.map((t) => t.path).toSet();

      final relaxed = keyed
          .map((e) => e.tune)
          .where((t) => !picked.contains(t.path))
          .take(count - mix.length)
          .toList();
      mix.addAll(relaxed);
      picked.addAll(relaxed.map((t) => t.path));

      if (mix.length < count) {
        final rest = tunes.where((t) => !picked.contains(t.path)).toList()
          ..shuffle(random);
        mix.addAll(rest.take(count - mix.length));
      }
    }

    return mix;
  }

  /// Higher weight = more likely to be picked. Tune these numbers.
  double _weight(Tune t) {
    var w = 1.0;

    // Uncomment once Tune tracks play stats:
    // w += min(t.playCount, 20) * 0.15;
    // if (t.isFavorite) w += 1.5;
    // final last = t.lastPlayed;
    // if (last != null && DateTime.now().difference(last).inDays < 2) {
    //   w *= 0.3; // played very recently: back off
    // }

    return w;
  }

  Future<void> _saveDailyMix(
    List<Tune> mix,
    int dateSeed, {
    List<String>? previousPaths,
  }) async {
    final current = _managementRepo.get();
    final updated = current.copyWith(
      dailyMixTunePaths: mix.map((t) => t.path).toList(),
      dailyMixDateSeed: dateSeed,
      dailyMixPreviousPaths: previousPaths ?? current.dailyMixPreviousPaths,
    );
    await _managementRepo.save(updated);
  }

  Future<Uint8List?> getAudioArt({
    required int id,
    required ArtworkType type,
  }) async => _audioQuery.queryArtwork(id, type);
}
