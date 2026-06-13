import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/lyrics/model/lrclib_search_result.dart';
import 'package:tunely/features/lyrics/model/lyrics_line.dart';
import 'package:tunely/features/lyrics/model/lyrics_result.dart';
import 'package:tunely/features/lyrics/service/lyrics_service.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/shared/model/tune.dart';

part 'lyrics_state.dart';

class LyricsCubit extends Cubit<LyricsState> {
  final LyricsService _service;
  final PlaybackBloc _playbackBloc;

  StreamSubscription<PlaybackState>? _playbackSub;
  Timer? _debounce;

  final Map<String, LyricsResult> _sessionCache = {};

  String? _lastFetchedKey;
  String? _currentTuneKey;

  int _fetchGen = 0;

  LyricsCubit(this._service, this._playbackBloc) : super(const LyricsIdle()) {
    _playbackSub = _playbackBloc.stream.listen(_onPlaybackChanged);
  }

  String _tuneKey(Tune tune) => tune.songId?.toString() ?? tune.path;

  void _onPlaybackChanged(PlaybackState ps) {
    final tune = ps.currentItem;
    if (tune == null) return;

    final key = _tuneKey(tune);

    // Ignore playback position updates for the same song
    if (key == _currentTuneKey) return;

    _currentTuneKey = key;

    emit(LyricsLoading(tune));

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _fetch(tune));
  }

  Future<void> _fetch(Tune tune) async {
    final key = _tuneKey(tune);
    final gen = ++_fetchGen;

    if (_sessionCache.containsKey(key)) {
      _lastFetchedKey = key;

      emit(LyricsLoaded(result: _sessionCache[key]!, tune: tune));

      return;
    }

    try {
      final result = await _service.fetchLyrics(tune);

      if (gen != _fetchGen) return;

      if (result == null) {
        emit(const LyricsNotFound());
        return;
      }

      _sessionCache[key] = result;
      _lastFetchedKey = key;

      emit(LyricsLoaded(result: result, tune: tune));
    } catch (_) {
      emit(const LyricsNotFound());
    }
  }

  Future<void> fetchForTune(Tune tune) async {
    _debounce?.cancel();
    await _fetch(tune);
  }

  Future<List<LrcLibSearchResult>> searchLrclib() async {
    final tune = _playbackBloc.state.currentItem;
    if (tune == null) return [];
    return _service.searchLrclib(tune.title, tune.artist);
  }

  Future<void> selectSearchResult(LrcLibSearchResult result) async {
    final tune = _playbackBloc.state.currentItem;
    if (tune == null) return;

    final key = _tuneKey(tune);
    final gen = ++_fetchGen;

    emit(LyricsLoading(tune));

    try {
      final lyrics = await _service.saveSearchResult(tune, result);

      if (gen != _fetchGen) return;

      if (lyrics == null) {
        emit(const LyricsNotFound());
        return;
      }

      _sessionCache[key] = lyrics;
      _lastFetchedKey = key;

      emit(LyricsLoaded(result: lyrics, tune: tune));
    } catch (_) {
      emit(const LyricsNotFound());
    }
  }

  void setOffset(int offsetMs) {
    final s = state;
    if (s is! LyricsLoaded) return;

    emit(s.copyWith(temporaryOffset: offsetMs));
  }

  Future<void> saveOffset(int offsetMs) async {
    final s = state;
    if (s is! LyricsLoaded) return;

    final updated = await _service.saveOffset(s.tune, offsetMs);

    if (updated == null) return;

    final key = _tuneKey(s.tune);

    _sessionCache[key] = updated;

    emit(s.copyWith(result: updated, temporaryOffset: 0));
  }

  Future<void> editLine(int index, LyricsLine updated) async {
    final s = state;
    if (s is! LyricsLoaded) return;

    final result = await _service.editLine(s.tune, index, updated);

    if (result == null) return;

    final key = _tuneKey(s.tune);

    _sessionCache[key] = result;

    emit(s.copyWith(result: result));
  }

  Future<void> deleteLine(int index) async {
    final s = state;
    if (s is! LyricsLoaded) return;

    final result = await _service.deleteLine(s.tune, index);

    if (result == null) return;

    final key = _tuneKey(s.tune);

    _sessionCache[key] = result;

    emit(s.copyWith(result: result));
  }

  Future<void> addLine(LyricsLine line) async {
    final s = state;
    if (s is! LyricsLoaded) return;

    final result = await _service.addLine(s.tune, line);

    if (result == null) return;

    final key = _tuneKey(s.tune);

    _sessionCache[key] = result;

    emit(s.copyWith(result: result));
  }

  Future<void> editPlain(String plain) async {
    final s = state;
    if (s is! LyricsLoaded) return;

    final result = await _service.editPlain(s.tune, plain);

    if (result == null) return;

    final key = _tuneKey(s.tune);

    _sessionCache[key] = result;

    emit(s.copyWith(result: result));
  }

  Future<void> reload() async {
    final tune = _playbackBloc.state.currentItem;

    if (tune == null) return;

    final key = _tuneKey(tune);

    _sessionCache.remove(key);
    _lastFetchedKey = null;

    emit(LyricsLoading(tune));

    try {
      await _service.reloadLyrics(tune);
      await _fetch(tune);
    } catch (_) {
      emit(const LyricsNotFound());
    }
  }

  Future<void> clearCache() async {
    _sessionCache.clear();

    _lastFetchedKey = null;
    _currentTuneKey = null;

    await _service.clearCache();

    emit(const LyricsIdle());
  }

  Future<void> reloadManual(String title, String artist) async {
    final s = state;
    if (s is! LyricsLoaded) return;

    final key = _tuneKey(s.tune);

    _sessionCache.remove(key);

    final gen = ++_fetchGen;
    emit(LyricsLoading(s.tune));
    try {
      final result = await _service.reloadLyricsManual(s.tune, title, artist);

      if (gen != _fetchGen) return;

      if (result == null) {
        emit(const LyricsNotFound());
        return;
      }

      _sessionCache[key] = result;
      _lastFetchedKey = key;

      emit(LyricsLoaded(result: result, tune: s.tune));
    } catch (_) {
      emit(const LyricsNotFound());
    }
  }

  Future<void> importLrc(String lrcContent) async {
    final tune = _playbackBloc.state.currentItem;
    if (tune == null) return;

    final gen = ++_fetchGen;
    emit(LyricsLoading(tune));

    final result = await _service.importLrc(tune, lrcContent);

    if (gen != _fetchGen) return;

    if (result == null) {
      emit(const LyricsNotFound());
      return;
    }

    final key = _tuneKey(tune);

    _sessionCache[key] = result;
    _lastFetchedKey = key;

    emit(LyricsLoaded(result: result, tune: tune));
  }

  @override
  Future<void> close() async {
    _debounce?.cancel();
    await _playbackSub?.cancel();
    return super.close();
  }
}
