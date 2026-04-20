import 'package:on_audio_query/on_audio_query.dart';
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

  LibraryService(this._audioQuery, this._managementRepo, this._libraryRepo);

  Future<LibraryScanResult?> scan() async {
    final permission = await _audioQuery.checkAndRequest();
    if (!permission) return null;

    final songs = await _audioQuery.querySongs();
    final settings = _managementRepo.get();
    final tunes = TuneParser.parse(songs, settings);
    final artists = _buildArtists(tunes);

    _libraryRepo.saveTunes(tunes);
    _libraryRepo.saveArtists(artists);

    final albums = await _audioQuery.queryAlbums();
    final genres = await _audioQuery.queryGenres();
    final playlists = await _audioQuery.queryPlaylists();

    return LibraryScanResult(
      tunes: tunes,
      artists: artists,
      albums: albums,
      genres: genres,
      playlists: playlists,
    );
  }

  List<Artist> _buildArtists(List<Tune> tunes) {
    final Map<String, List<int>> artistMap = {};

    for (final tune in tunes) {
      for (final name in tune.artists) {
        if (tune.songId != null) {
          artistMap.putIfAbsent(name, () => []).add(tune.songId!);
        }
      }
    }
    return artistMap.entries
        .map(
          (e) =>
              Artist(artistId: e.key.hashCode, artist: e.key, tunesId: e.value),
        )
        .toList();
  }
}
