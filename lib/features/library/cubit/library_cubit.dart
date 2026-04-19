import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
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
      emit(
        LibraryLoaded(
          tunes: result.tunes,
          artists: result.artists,
          albums: result.albums,
          genres: result.genres,
          playlists: result.playlists,
        ),
      );
    } catch (e) {
      emit(LibraryError(e.toString()));
    }
  }
}
