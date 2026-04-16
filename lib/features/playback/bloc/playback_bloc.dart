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
        final sequence = sequenceState.sequence;
        final index = sequenceState.currentIndex;

        // Tags are Tune instances set via toMediaItem() — cast back here
        final queue = sequence
            .map((s) => (s.tag as dynamic))
            .whereType<Tune>()
            .toList();

        final currentItem = index! < queue.length ? queue[index] : null;

        add(
          _SequenceStateUpdatedEvent(
            currentItem: currentItem,
            queue: queue,
            currentIndex: index,
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
        ),
      ),
    );
    on<_BufferedPositionUpdatedEvent>(
      (event, emit) =>
          emit(state.copyWith(bufferedPosition: event.bufferedPosition)),
    );

    // Playback control handlers
    on<PlayQueueEvent>((event, emit) async {
      await _service.playQueue(
        event.items.map((t) => t.toMediaItem()).toList(),
        event.startIndex,
      );
    });

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

    // Queue management handlers
    on<AddQueueItemEvent>(
      (event, emit) async =>
          await _service.addQueueItem(event.item.toMediaItem()),
    );
    on<AddQueueItemsEvent>(
      (event, emit) async => await _service.addQueueItems(
        event.items.map((t) => t.toMediaItem()).toList(),
      ),
    );
    on<RemoveQueueItemEvent>(
      (event, emit) async =>
          await _service.removeQueueItem(event.item.toMediaItem()),
    );
    on<RemoveQueueItemAtEvent>(
      (event, emit) async => await _service.removeQueueItemAt(event.index),
    );
    on<PlayAfterThisEvent>(
      (event, emit) async =>
          await _service.playAfterThis(event.item.toMediaItem()),
    );

    // Settings handlers
    on<SetShuffleEvent>((event, emit) async {
      await _service.setShuffle(event.enabled);
      emit(state.copyWith(shuffleEnabled: event.enabled));
    });
    on<SetRepeatEvent>((event, emit) async {
      await _service.setRepeat(event.mode);
      emit(state.copyWith(repeatMode: event.mode));
    });
    on<SetSpeedEvent>((event, emit) async {
      await _service.setSpeed(event.speed);
      emit(state.copyWith(speed: event.speed));
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
