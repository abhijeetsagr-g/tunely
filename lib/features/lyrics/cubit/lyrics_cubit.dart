import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/lyrics/model/lyrics_line.dart';
import 'package:tunely/features/lyrics/model/lyrics_result.dart';
import 'package:tunely/features/lyrics/service/lyrics_service.dart';
import 'package:tunely/shared/model/tune.dart';

part 'lyrics_state.dart';

class LyricsCubit extends Cubit<LyricsState> {
  final LyricsService _service;

  LyricsCubit(this._service) : super(const LyricsIdle());

  // Load lyrics for a tune
  Future<void> fetch(Tune tune) async {
    emit(const LyricsLoading());
    final result = await _service.fetchLyrics(tune);
    await Future.delayed(const Duration(milliseconds: 500));
    if (result == null) {
      emit(const LyricsNotFound());
      return;
    }
    emit(LyricsLoaded(result: result, tune: tune));
  }

  void setOffset(int offsetMs) {
    final s = state;
    if (s is! LyricsLoaded) return;
    emit(s.copyWith(temporaryOffset: offsetMs));
  }

  // Persist offset to cache
  Future<void> saveOffset(int offsetMs) async {
    final s = state;
    if (s is! LyricsLoaded) return;
    final updated = await _service.saveOffset(s.tune, offsetMs);
    if (updated == null) return;
    emit(s.copyWith(result: updated, temporaryOffset: 0));
  }

  // Edit a line and persist
  Future<void> editLine(int index, LyricsLine updated) async {
    final s = state;
    if (s is! LyricsLoaded) return;
    final result = await _service.editLine(s.tune, index, updated);
    if (result == null) return;
    emit(s.copyWith(result: result));
  }

  // Delete a line and persist
  Future<void> deleteLine(int index) async {
    final s = state;
    if (s is! LyricsLoaded) return;
    final result = await _service.deleteLine(s.tune, index);
    if (result == null) return;
    emit(s.copyWith(result: result));
  }

  // Add a new line and persist
  Future<void> addLine(LyricsLine line) async {
    final s = state;
    if (s is! LyricsLoaded) return;
    final result = await _service.addLine(s.tune, line);
    if (result == null) return;
    emit(s.copyWith(result: result));
  }

  // Edit plain lyrics and persist
  Future<void> editPlain(String plain) async {
    final s = state;
    if (s is! LyricsLoaded) return;
    final result = await _service.editPlain(s.tune, plain);
    if (result == null) return;
    emit(s.copyWith(result: result));
  }

  // Reload from LRCLIB (clears cache)
  Future<void> reload() async {
    final s = state;
    if (s is! LyricsLoaded) return;
    await fetch(s.tune);
  }

  // Manual search with custom title/artist
  Future<void> reloadManual(String title, String artist) async {
    final s = state;
    if (s is! LyricsLoaded) return;
    emit(const LyricsLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    final result = await _service.reloadLyricsManual(s.tune, title, artist);
    if (result == null) {
      emit(const LyricsNotFound());
      return;
    }
    emit(LyricsLoaded(result: result, tune: s.tune));
  }
}
