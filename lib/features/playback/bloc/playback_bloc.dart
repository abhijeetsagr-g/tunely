import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tunely/features/playback/service/playback_service.dart';
import 'package:tunely/shared/model/tune.dart';

part 'playback_event.dart';
part 'playback_state.dart';

class PlaybackBloc extends Bloc<PlaybackEvent, PlaybackState> {
  final PlaybackService _service;
  final List<StreamSubscription> _subscriptions = [];

  PlaybackBloc(this._service) : super(const PlaybackState()) {
    // Stream listeners — feed internal events into the bloc
    _subscriptions.addAll([
      _service.isPlaying.listen(
        (playing) => add(_PlayerStateUpdatedEvent(playing)),
      ),
      _service.positionStream.listen(
        (position) => add(_PositionUpdatedEvent(position)),
      ),
      _service.durationStream.listen(
        (duration) => add(_DurationUpdatedEvent(duration)),
      ),
      _service.playerStateStream.listen((processingState) {
        final status = switch (processingState) {
          ProcessingState.idle => PlaybackStatus.idle,
          ProcessingState.loading => PlaybackStatus.loading,
          ProcessingState.buffering => PlaybackStatus.buffering,
          ProcessingState.ready => PlaybackStatus.ready,
          ProcessingState.completed => PlaybackStatus.completed,
        };
        add(_ProcessingStateUpdatedEvent(status));
      }),
      _service.sequenceStateStream.listen((sequenceState) {
        final sequence = sequenceState.effectiveSequence;
        final index = sequenceState.currentIndex;
        if (index == null) return;

        final effectiveIndex = sequenceState.shuffleModeEnabled
            ? sequenceState.shuffleIndices.indexOf(index)
            : index;

        final queue = sequence.map((s) => s.tag as Tune).toList();
        final currentItem = effectiveIndex < queue.length
            ? queue[effectiveIndex]
            : null;

        add(
          _SequenceStateUpdatedEvent(
            currentItem: currentItem,
            queue: queue,
            currentIndex: effectiveIndex,
            shuffleMode: sequenceState.shuffleModeEnabled,
            repeatMode: sequenceState.loopMode,
          ),
        );
      }),
    ]);

    // Internal stream update handlers
    on<_PlayerStateUpdatedEvent>(
      (event, emit) => emit(state.copyWith(isPlaying: event.isPlaying)),
    );
    on<_PositionUpdatedEvent>(
      (event, emit) => emit(state.copyWith(position: event.position)),
    );
    on<_DurationUpdatedEvent>(
      (event, emit) => emit(state.copyWith(duration: event.duration)),
    );
    on<_ProcessingStateUpdatedEvent>(
      (event, emit) => emit(state.copyWith(status: event.status)),
    );
    on<_SequenceStateUpdatedEvent>(
      (event, emit) => emit(
        state.copyWith(
          currentItem: event.currentItem,
          queue: event.queue,
          currentIndex: event.currentIndex,
          shuffleEnabled: event.shuffleMode,
          repeatMode: event.repeatMode,
        ),
      ),
    );

    on<_BufferedPositionUpdatedEvent>(
      (event, emit) =>
          emit(state.copyWith(bufferedPosition: event.bufferedPosition)),
    );

    // Playback control handlers
    on<PlayQueueEvent>(
      (event, emit) async =>
          await _service.playQueue(event.items, event.startIndex),
    );

    on<PlayEvent>((event, emit) async => await _service.play());
    on<PauseEvent>((event, emit) async => await _service.pause());
    on<StopEvent>((event, emit) async => await _service.stop());

    on<SeekEvent>((event, emit) async => await _service.seek(event.position));
    on<SkipToNextEvent>((event, emit) async => await _service.skipToNext());
    on<SkipToPreviousEvent>(
      (event, emit) async => await _service.skipToPrevious(),
    );
    on<SkipToQueueItemEvent>(
      (event, emit) async => await _service.skipToQueueItem(event.index),
    );

    on<ShuffleAllEvent>((event, emit) async {
      final shuffled = List<Tune>.from(event.tunes)..shuffle();
      await _service.playQueue(shuffled, 0);
      await _service.setShuffle(true);
    });

    // Queue management handlers
    on<AddQueueItemEvent>(
      (event, emit) async => await _service.addToQueue(event.item),
    );
    on<AddQueueItemsEvent>(
      (event, emit) async => await _service.addManyToQueue(event.items),
    );

    // TODO: CHANGE
    on<RemoveQueueItemEvent>(
      (event, emit) async =>
          await _service.removeQueueItem(event.item.toMediaItem()),
    );
    on<RemoveQueueItemAtEvent>(
      (event, emit) async => await _service.removeQueueItemAt(event.index),
    );
    on<PlayAfterThisEvent>(
      (event, emit) async => await _service.playAfterThis(event.item),
    );

    // Settings handlers
    on<SetShuffleEvent>((event, emit) async {
      final enabled = !state.shuffleEnabled;
      await _service.setShuffle(enabled);
    });

    on<SetRepeatEvent>((event, emit) async {
      final mode = switch (state.repeatMode) {
        LoopMode.off => LoopMode.one,
        LoopMode.one => LoopMode.all,
        LoopMode.all => LoopMode.off,
      };

      await _service.setRepeat(mode);
    });
    on<SetSpeedEvent>((event, emit) async {
      await _service.setSpeed(event.speed);
      emit(state.copyWith(speed: event.speed));
    });

    // restore previous session
    on<RestoreSessionEvent>((event, emit) async {
      if (event.queue.isEmpty) return;
      await _service.playQueue(
        event.queue,
        event.currentIndex,
        autoPlay: false,
      );

      await _service.pause(); // just in case lol
      await _service.seek(event.position);
      await _service.setShuffle(event.shuffleEnabled);
      await _service.setRepeat(event.repeatMode);
      await _service.setSpeed(event.speed);
    });
  }

  @override
  Future<void> close() async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    return super.close();
  }
}
