import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/data/model/tune.dart';
import 'package:tunely/logic/service/playback_service.dart';

part 'playback_event.dart';
part 'playback_state.dart';

class PlaybackBloc extends Bloc<PlaybackEvent, PlaybackState> {
  final PlaybackService _service;
  int? _pendingIndex;

  late final StreamSubscription<bool> _playSub;
  late final StreamSubscription<SequenceState?> _sequenceSub;
  late final StreamSubscription<Duration> _posSub;
  late final StreamSubscription<Duration?> _durSub;
  late final StreamSubscription<ProcessingState> _playerStateSub;
  PlaybackBloc(this._service)
    : super(
        PlaybackState(
          isPlaying: false,
          isBuffering: false,
          isLoading: true,
          isShuffleMode: false,
          hasNext: false,
          hasPrev: false,
          pos: Duration.zero,
          dur: Duration.zero,
          repeatMode: .none,
          tunes: [],
          queue: [],
          type: .recentlyAdded,
        ),
      ) {
    // Streams
    _playSub = _service.isPlaying.listen((event) => add(PlayingChange(event)));

    _sequenceSub = _service.sequenceStateStream.listen((event) {
      add(SequenceChange(event));
    });

    _posSub = _service.positionStream.listen(
      (event) => add(PositionChange(event)),
    );

    _durSub = _service.durationStream.listen((event) {
      if (event != null) add(DurationChange(event));
    });

    _playerStateSub = _service.playerStateStream.listen(
      (event) => add(ProcessStateChange(event == ProcessingState.buffering)),
    );

    // events
    on<PlaySong>((event, emit) async {
      _pendingIndex = event.index;
      await _service.playQueue(
        event.tune.map((e) => e.toMediaItem()).toList(),
        event.index,
      );
      _pendingIndex = null;
    });

    on<ShuffleAll>((event, emit) async {
      await _service.setShuffle(true);
      await _service.playQueue(
        event.tunes.map((e) => e.toMediaItem()).toList(),
        event.startIndex, // always start at 0, shuffle will reorder
      );
    });

    on<Play>((event, emit) async => await _service.play());
    on<Pause>((event, emit) async => await _service.pause());
    on<PlayNext>((event, emit) async => await _service.skipToNext());
    on<PlayPrev>((event, emit) async => await _service.skipToPrevious());

    on<Seek>((event, emit) async => await _service.seek(event.pos));
    on<PlayingChange>(
      (event, emit) => emit(state.copyWith(isPlaying: event.isPlaying)),
    );

    // important
    on<SequenceChange>((event, emit) {
      if (event.sequence.currentIndex == null) return;
      if (event.sequence.sequence.isEmpty) return;

      if (_pendingIndex != null &&
          event.sequence.currentIndex != _pendingIndex) {
        return;
      }

      final queue = event.sequence.effectiveSequence.map((source) {
        final item = source.tag as MediaItem;
        return state.tunes.firstWhere((t) => t.path == item.id);
      }).toList();
      final canLoop =
          event.sequence.loopMode == LoopMode.all ||
          event.sequence.loopMode == LoopMode.one;

      final shuffleIndices = event.sequence.shuffleIndices;
      final currentIndex = event.sequence.currentIndex!;

      // Find position of currentIndex within shuffleIndices
      final effectiveIndex = event.sequence.shuffleModeEnabled
          ? shuffleIndices.indexOf(currentIndex)
          : currentIndex;

      final currentItem =
          event.sequence.effectiveSequence[effectiveIndex].tag as MediaItem;
      final currentSong = state.tunes.firstWhereOrNull(
        (t) => t.path == currentItem.id,
      );
      final nextSong =
          (effectiveIndex + 1 < event.sequence.effectiveSequence.length)
          ? queue[effectiveIndex + 1]
          : null;

      emit(
        state.copyWith(
          currentSong: Optional(currentSong),
          nextSong: nextSong,
          queue: queue,

          isShuffleMode: event.sequence.shuffleModeEnabled,
          hasNext:
              canLoop ||
              (effectiveIndex + 1 < event.sequence.effectiveSequence.length),
          hasPrev: canLoop || (effectiveIndex > 0),

          repeatMode: switch (event.sequence.loopMode) {
            LoopMode.off => RepeatMode.none,
            LoopMode.one => RepeatMode.one,
            LoopMode.all => RepeatMode.all,
          },
        ),
      );
    });
    on<PositionChange>(
      (event, emit) => emit(state.copyWith(pos: event.position)),
    );
    on<DurationChange>(
      (event, emit) => emit(state.copyWith(dur: event.duration)),
    );

    on<ProcessStateChange>(
      (event, emit) => emit(state.copyWith(isBuffering: event.isBuffering)),
    );

    on<ToggleShuffle>((event, emit) async {
      await _service.setShuffle(!state.isShuffleMode);
    });

    on<CycleRepeat>((event, emit) async {
      final next = switch (state.repeatMode) {
        RepeatMode.none => RepeatMode.all,
        RepeatMode.all => RepeatMode.one,
        RepeatMode.one => RepeatMode.none,
      };
      await _service.setRepeat(switch (next) {
        RepeatMode.none => LoopMode.off,
        RepeatMode.all => LoopMode.all,
        RepeatMode.one => LoopMode.one,
      });
    });

    on<SortTunes>((event, emit) {
      final sorted = [...state.tunes];
      switch (event.sort) {
        case TuneSortType.title:
          sorted.sort((a, b) => a.title.compareTo(b.title));
        case TuneSortType.artist:
          sorted.sort((a, b) => a.artist.compareTo(b.artist));
        case TuneSortType.recentlyAdded:
          sorted.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        case TuneSortType.album:
          sorted.sort((a, b) => b.album.compareTo(a.album));
      }
      emit(state.copyWith(tunes: sorted, type: event.sort));
    });

    on<SongLoaded>(
      (event, emit) => emit(
        state.copyWith(
          isLoading: false,
          tunes: event.songs.map((e) => Tune.fromSongModel(e)).toList(),
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _playSub.cancel();
    _sequenceSub.cancel();
    _posSub.cancel();
    _durSub.cancel();
    _playerStateSub.cancel();

    return super.close();
  }
}
