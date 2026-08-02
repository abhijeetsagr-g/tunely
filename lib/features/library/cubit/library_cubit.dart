import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/features/library/service/library_service.dart';
import 'package:tunely/shared/model/artist.dart';
import 'package:tunely/shared/model/tune.dart';

part 'library_state.dart';

class LibraryCubit extends Cubit<LibraryState> {
  final LibraryService _service;
  static const int _recommendedCount = 5;

  LibraryCubit({required LibraryService service})
    : _service = service,
      super(LibraryInitial());

  Future<void> initialLoad() async {
    emit(LibraryLoading());
    try {
      final result = await _service.scan();
      if (result == null) {
        emit(LibraryPermissionDenied());
        return;
      }
      emit(
        LibraryLoaded(
          tunes: result.tunes,
          artists: result.artists,
          albums: result.albums,
          genres: result.genres,
          dailyMix: await _service.generateDailyMix(result.tunes),
          recommendedAlbums: _pickRandomAlbums(result.albums, result.tunes),
        ),
      );
    } catch (e) {
      emit(LibraryError(e.toString()));
    }
  }

  Future<void> rescan() => initialLoad();

  Future<void> reloadDailyMix() async {
    final s = state;
    if (s is! LibraryLoaded) return;
    final mix = await _service.refreshDailyMix(s.tunes);
    emit(s.copyWith(dailyMix: mix));
  }

  void refreshRecommendedAlbums() {
    final s = state;
    if (s is! LibraryLoaded) return;
    emit(s.copyWith(recommendedAlbums: _pickRandomAlbums(s.albums, s.tunes)));
  }

  List<AlbumModel> _pickRandomAlbums(
    List<AlbumModel> albums,
    List<Tune> tunes,
  ) {
    final songCountPerAlbum = <int, int>{};
    for (final t in tunes) {
      if (t.albumId != null) {
        songCountPerAlbum[t.albumId!] =
            (songCountPerAlbum[t.albumId!] ?? 0) + 1;
      }
    }
    final pool = albums
        .where((a) => (songCountPerAlbum[a.id] ?? 0) > 1)
        .toList()
      ..shuffle();
    return pool.take(_recommendedCount).toList();
  }

  List<Tune> getTunesByAlbum(int albumId) => _service.getTunesByAlbum(albumId);
  List<Artist> getArtistsFromTunes(List<Tune> tunes) => Artist.fromTunes(tunes);

  Artist? getFullArtist(Artist partial) {
    final s = state;
    if (s is! LibraryLoaded) return null;
    try {
      return s.artists.firstWhere((a) => a.artistId == partial.artistId);
    } catch (_) {
      return null;
    }
  }

  Future<Uint8List?> getAudioArt({
    required int id,
    required ArtworkType type,
  }) => _service.getAudioArt(id: id, type: type);
}
