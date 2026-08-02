import 'dart:math';
import 'dart:typed_data';

import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/features/library/model/library_scan_result.dart';
import 'package:tunely/features/library/repository/library_repository.dart';
import 'package:tunely/core/utlis/tune_praser.dart';
import 'package:tunely/features/music_management/repository/management_repository.dart';
import 'package:tunely/shared/model/artist.dart';
import 'package:tunely/shared/model/tune.dart';

class LibraryService {
  final OnAudioQuery _audioQuery;
  final ManagementRepository _managementRepo;
  final LibraryRepository _libraryRepo;
  int _dailyMixRefreshCount = 0;

  LibraryService(this._audioQuery, this._managementRepo, this._libraryRepo);

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

  Future<List<Tune>> generateDailyMix(List<Tune> tunes) async {
    _dailyMixRefreshCount = 0;
    final todaySeed = DateTime.now().millisecondsSinceEpoch ~/ 86400000;
    final settings = _managementRepo.get();

    if (settings.dailyMixDateSeed == todaySeed &&
        settings.dailyMixTunePaths != null) {
      final savedPaths = settings.dailyMixTunePaths!.toSet();
      final restored = tunes.where((t) => savedPaths.contains(t.path)).toList();
      if (restored.isNotEmpty) return restored;
    }

    final random = Random(todaySeed);
    final mix = ([
      ...tunes,
    ]..shuffle(random)).take(settings.dailyMixSize).toList();
    await _saveDailyMix(mix, todaySeed);
    return mix;
  }

  Future<List<Tune>> refreshDailyMix(List<Tune> tunes) async {
    _dailyMixRefreshCount++;
    final todaySeed = DateTime.now().millisecondsSinceEpoch ~/ 86400000;
    final settings = _managementRepo.get();
    final seed = todaySeed + _dailyMixRefreshCount;
    final random = Random(seed);
    final size = settings.dailyMixSize * 2;
    final mix = ([...tunes]..shuffle(random)).take(size).toList();
    await _saveDailyMix(mix, todaySeed);
    return mix;
  }

  Future<void> _saveDailyMix(List<Tune> mix, int dateSeed) async {
    final updated = _managementRepo.get().copyWith(
      dailyMixTunePaths: mix.map((t) => t.path).toList(),
      dailyMixDateSeed: dateSeed,
    );
    await _managementRepo.save(updated);
  }

  Future<Uint8List?> getAudioArt({
    required int id,
    required ArtworkType type,
  }) async => _audioQuery.queryArtwork(id, type);
}
