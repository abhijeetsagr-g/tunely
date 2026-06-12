import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/features/library/service/library_service.dart';
import 'package:tunely/shared/model/artist.dart';
import 'package:tunely/shared/model/tune.dart';

part 'library_state.dart';

class LibraryCubit extends Cubit<LibraryState> {
  final LibraryService _service;

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
      final dailyMix = [...result.tunes..shuffle()].take(10).toList();

      emit(
        LibraryLoaded(
          tunes: result.tunes,
          artists: result.artists,
          albums: result.albums,
          genres: result.genres,
          playlists: result.playlists,
          dailyMix: dailyMix,
        ),
      );
    } catch (e) {
      emit(LibraryError(e.toString()));
    }
  }

  Future<void> rescan() => initialLoad();

  void reloadDailyMix() {
    final s = state;
    if (s is! LibraryLoaded) return;
    final reshuffled = [...s.tunes]..shuffle();
    emit(s.copyWith(dailyMix: reshuffled.take(10).toList()));
  }

  List<Tune> getTunesByAlbum(int albumId) => _service.getTunesByAlbum(albumId);
  List<Tune> getTunesByGenre(String genre) => _service.getTunesByGenre(genre);
}
