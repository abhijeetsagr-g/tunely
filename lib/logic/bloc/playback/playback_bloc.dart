import 'dart:async';

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
      await _service.playQueue(
        event.tune.map((e) => e.toMediaItem()).toList(),
        event.index,
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
    on<SequenceChange>((event, emit) {
      if (event.sequence.currentIndex == null) return;

      emit(
        state.copyWith(
          hasNext:
              (event.sequence.currentIndex! + 1 <
              event.sequence.sequence.length),
          hasPrev: (event.sequence.currentIndex! > 0),
          currentSong: Optional(
            state.tunes.firstWhereOrNull((t) {
              final item =
                  event.sequence.sequence[event.sequence.currentIndex!].tag
                      as MediaItem;
              return item.id == t.path;
            }),
          ),
          isShuffleMode: event.sequence.shuffleModeEnabled,
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
