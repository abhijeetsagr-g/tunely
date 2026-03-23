import 'dart:async';
import 'dart:math';
import 'package:audio_service/audio_service.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tunely/data/model/tune.dart';
import 'package:tunely/data/repository/tune_repository.dart';
import 'package:tunely/logic/service/playback_service.dart';

part 'playback_event.dart';
part 'playback_state.dart';

class PlaybackBloc extends Bloc<PlaybackEvent, PlaybackState> {
  final PlaybackService _service;
  final TuneRepository _repo;

  int? _pendingIndex;
  Timer? _timer;
  Timer? _sleepCountdown;

  late final StreamSubscription<bool> _playSub;
  late final StreamSubscription<SequenceState?> _sequenceSub;
  late final StreamSubscription<Duration> _posSub;
  late final StreamSubscription<Duration?> _durSub;
  late final StreamSubscription<ProcessingState> _playerStateSub;

  PlaybackBloc(this._service, this._repo)
    : super(
        PlaybackState(
          isPlaying: false,
          isBuffering: false,
          isLoading: false,
          isShuffleMode: false,
          hasNext: false,
          hasPrev: false,
          pos: Duration.zero,
          dur: Duration.zero,
          repeatMode: RepeatMode.none,
          queue: [],
        ),
      ) {
    _playSub = _service.isPlaying.listen((e) => add(PlayingChange(e)));
    _sequenceSub = _service.sequenceStateStream.listen(
      (e) => add(SequenceChange(e)),
    );
    _posSub = _service.positionStream.listen((e) => add(PositionChange(e)));
    _durSub = _service.durationStream.listen((e) {
      if (e != null) add(DurationChange(e));
    });
    _playerStateSub = _service.playerStateStream.listen(
      (e) => add(ProcessStateChange(e == ProcessingState.buffering)),
    );

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
        event.startIndex,
      );
      await _service.setRepeat(.all);
    });

    on<Play>((event, emit) async => await _service.play());
    on<Pause>((event, emit) async => await _service.pause());
    on<PlayNext>((event, emit) async => await _service.skipToNext());
    on<PlayPrev>((event, emit) async => await _service.skipToPrevious());
    on<Seek>((event, emit) async => await _service.seek(event.pos));

    on<PlayingChange>(
      (event, emit) => emit(state.copyWith(isPlaying: event.isPlaying)),
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

    on<PositionChange>(
      (event, emit) => emit(state.copyWith(pos: event.position)),
    );
    on<DurationChange>(
      (event, emit) => emit(state.copyWith(dur: event.duration)),
    );
    on<ProcessStateChange>(
      (event, emit) => emit(state.copyWith(isBuffering: event.isBuffering)),
    );

    on<SequenceChange>((event, emit) {
      if (event.sequence.currentIndex == null) return;
      if (event.sequence.sequence.isEmpty) return;

      if (_pendingIndex != null &&
          event.sequence.currentIndex != _pendingIndex) {
        return;
      }

      final queue = event.sequence.effectiveSequence
          .map<Tune?>((source) {
            final item = source.tag as MediaItem;
            return state.queue.firstWhereOrNull((t) => t.path == item.id) ??
                _repo.findByPath(item.id);
          })
          .whereType<Tune>()
          .toList();

      final canLoop =
          event.sequence.loopMode == LoopMode.all ||
          event.sequence.loopMode == LoopMode.one;

      final shuffleIndices = event.sequence.shuffleIndices;
      final currentIndex = event.sequence.currentIndex!;

      final effectiveIndex = event.sequence.shuffleModeEnabled
          ? shuffleIndices.indexOf(currentIndex)
          : currentIndex;

      final currentItem =
          event.sequence.effectiveSequence[effectiveIndex].tag as MediaItem;
      final currentSong = _repo.findByPath(currentItem.id);
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

    on<SetSleepTimer>((event, emit) {
      _timer?.cancel();
      _sleepCountdown?.cancel();

      _timer = Timer(event.duration, () {
        _service.pause();
        add(CancelSleepTimer());
      });

      _sleepCountdown = Timer.periodic(const Duration(seconds: 1), (_) {
        if (state.sleepTimer == null) return;
        final remaining = state.sleepTimer! - const Duration(seconds: 1);
        if (remaining <= Duration.zero) {
          _sleepCountdown?.cancel();
        } else {
          add(SleepTick(remaining));
        }
      });

      emit(state.copyWith(sleepTimer: Optional(event.duration)));
    });

    on<SleepTick>(
      (event, emit) =>
          emit(state.copyWith(sleepTimer: Optional(event.remaining))),
    );

    on<CancelSleepTimer>((event, emit) {
      _timer?.cancel();
      _sleepCountdown?.cancel();
      emit(state.copyWith(sleepTimer: Optional(null)));
    });
  }

  @override
  Future<void> close() {
    _playSub.cancel();
    _sequenceSub.cancel();
    _posSub.cancel();
    _durSub.cancel();
    _playerStateSub.cancel();
    _timer?.cancel();
    _sleepCountdown?.cancel();
    return super.close();
  }
}
