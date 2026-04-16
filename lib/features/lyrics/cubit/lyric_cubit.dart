import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/data/model/lyric_result.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/service/lyrics_service.dart';

part 'lyric_state.dart';

class LyricCubit extends Cubit<LyricsState> {
  final LyricsService _service;

  LyricCubit(this._service) : super(LyricsInitial());

  Future<void> loadLyrics(Tune tune) async {
    emit(LyricsLoading());

    try {
      final result = await _service.fetchLyrics(tune);

      if (result == null) {
        emit(LyricsNotFound());
        return;
      }

      if (result.instrumental) {
        emit(LyricsInstrumental());
        return;
      }

      emit(LyricsLoaded(result));
    } catch (e) {
      emit(LyricsNotFound());
    }
  }

  Future<void> reloadLyrics(Tune tune) async {
    emit(LyricsLoading());
    try {
      final result = await _service.reloadLyrics(tune);
      if (result == null) {
        emit(LyricsNotFound());
        return;
      }
      if (result.instrumental) {
        emit(LyricsInstrumental());
        return;
      }
      emit(LyricsLoaded(result));
    } catch (e) {
      emit(LyricsNotFound());
    }
  }

  Future<void> reloadLyricsManual(
    Tune tune,
    String title,
    String artist,
  ) async {
    emit(LyricsLoading());
    try {
      final result = await _service.reloadLyricsManual(tune, title, artist);
      if (result == null) {
        emit(LyricsNotFound());
        return;
      }
      if (result.instrumental) {
        emit(LyricsInstrumental());
        return;
      }
      emit(LyricsLoaded(result));
    } catch (e) {
      emit(LyricsNotFound());
    }
  }
}
