import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tunely/features/playback/service/audio_engine.dart';
import 'package:tunely/features/playback/service/missing_song_handler.dart';
import 'package:tunely/features/playback/service/queue_sequence.dart';
import 'package:tunely/shared/model/tune.dart';

class CustomSequenceState {
  final List<Tune> queue;
  final int currentIndex;
  final bool shuffleEnabled;
  final LoopMode repeatMode;

  const CustomSequenceState({
    required this.queue,
    required this.currentIndex,
    required this.shuffleEnabled,
    required this.repeatMode,
  });
}

class PlaybackService extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _engine = AudioEngine();
  final _sequence = QueueSequence();
  late final MissingSongHandler _missingSongHandler;

  int? _lastEmittedIndex;
  bool _isSwappingQueue = false;

  // Custom stream for bloc (replaces just_audio's sequenceStateStream)
  final _customSequenceController =
      StreamController<CustomSequenceState>.broadcast();
  Stream<CustomSequenceState> get customSequenceStream =>
      _customSequenceController.stream;

  // Emits the Tune whenever a queued song can no longer be loaded/played
  final _unavailableController = StreamController<Tune>.broadcast();
  Stream<Tune> get onSongUnavailable => _unavailableController.stream;

  // Track-changed stream
  final _trackController = StreamController<MediaItem>.broadcast();
  Stream<MediaItem> get onTrackChanged => _trackController.stream;

  PlaybackService() {
    _missingSongHandler = MissingSongHandler(
      _engine,
      _sequence,
      onUnavailable: _unavailableController.add,
      onAdvanced: _emitCustomSequence,
    );
    _init();
  }

  void _init() {
    _engine.errorStream.listen(_missingSongHandler.handleError);

    _engine.playbackEventStream
        .map(_transformEvent)
        .handleError((e) => debugPrint('Playback event error: $e'))
        .pipe(playbackState);

    _engine.sequenceStateStream.listen((_) {
      if (_isSwappingQueue) return;
      _emitCustomSequence();
    });
  }

  void _emitCustomSequence() {
    final seqState = _engine.sequenceState;
    if (seqState == null) return;

    final physical = seqState.sequence;
    final physicalIndex = seqState.currentIndex;
    if (physicalIndex == null) return;
    if (physicalIndex >= physical.length) return;

    // Safety: sync _shuffleIndices if it got out of sync with physical
    _sequence.sync(physical.length);

    final physicalTunes = physical.map((s) => s.tag as Tune).toList();
    final effectiveQueue = _sequence.effectiveQueue(physicalTunes);
    final effectiveIndex = _sequence.effectiveIndexOf(physicalIndex);

    if (effectiveIndex < 0 || effectiveIndex >= effectiveQueue.length) return;

    // Update audio_service (lock screen, OS controls)
    queue.add(effectiveQueue.map((t) => t.toMediaItem()).toList());
    mediaItem.add(effectiveQueue[effectiveIndex].toMediaItem());

    // Track change notification
    if (effectiveIndex != _lastEmittedIndex) {
      _lastEmittedIndex = effectiveIndex;
      _trackController.add(effectiveQueue[effectiveIndex].toMediaItem());
    }

    _customSequenceController.add(
      CustomSequenceState(
        queue: effectiveQueue,
        currentIndex: effectiveIndex,
        shuffleEnabled: _sequence.isShuffleEnabled,
        repeatMode: seqState.loopMode,
      ),
    );
  }

  PlaybackState _transformEvent(PlaybackEvent _) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_engine.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: {
        MediaAction.stop,
        MediaAction.playPause,
        MediaAction.seek,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
        MediaAction.setShuffleMode,
        MediaAction.setRepeatMode,
      },
      processingState: switch (_engine.processingState) {
        ProcessingState.idle => AudioProcessingState.idle,
        ProcessingState.ready => AudioProcessingState.ready,
        ProcessingState.loading => AudioProcessingState.loading,
        ProcessingState.buffering => AudioProcessingState.buffering,
        ProcessingState.completed => AudioProcessingState.completed,
      },
      playing: _engine.playing,
      speed: _engine.speed,
      updatePosition: _engine.position,
      bufferedPosition: _engine.bufferedPosition,
      queueIndex: _engine.currentIndex,
      shuffleMode: _sequence.isShuffleEnabled
          ? AudioServiceShuffleMode.all
          : AudioServiceShuffleMode.none,
      repeatMode: switch (_engine.loopMode) {
        LoopMode.one => AudioServiceRepeatMode.one,
        LoopMode.all => AudioServiceRepeatMode.all,
        _ => AudioServiceRepeatMode.none,
      },
    );
  }

  // Play Queue
  Future<void> playQueue(
    List<Tune> tunes,
    int startIndex, {
    bool autoPlay = true,
  }) async {
    if (tunes.isEmpty) return;
    startIndex = startIndex.clamp(0, tunes.length - 1);
    _lastEmittedIndex = null;
    _isSwappingQueue = true;
    _missingSongHandler.reset();

    try {
      await _engine.load(tunes, startIndex);
      _sequence.prime(tunes.length, startIndex);
      _isSwappingQueue = false;
      if (autoPlay) await _engine.play();
    } on PlayerException catch (e) {
      _isSwappingQueue = false;
      _missingSongHandler.handleError(
        e,
        fallbackTune: startIndex < tunes.length ? tunes[startIndex] : null,
      );
      return;
    }

    _emitCustomSequence();
  }

  // Basic Controls
  @override
  Future<void> play() async {
    try {
      await _engine.play();
    } on PlayerException catch (e) {
      _missingSongHandler.handleError(e);
    }
  }

  @override
  Future<void> pause() => _engine.pause();
  @override
  Future<void> stop() => _engine.stop();
  @override
  Future<void> seek(Duration position) => _engine.seek(position);

  @override
  Future<void> skipToNext() async {
    if (!_sequence.isShuffleEnabled) {
      if (_engine.hasNext) return _engine.seekToNext();
      await _engine.seek(Duration.zero);
      return _engine.pause();
    }
    final ci = _engine.currentIndex;
    if (ci == null) return;
    final effectiveIndex = _sequence.effectiveIndexOf(ci);
    if (effectiveIndex == -1) return;

    final next = _sequence.nextPhysical(effectiveIndex);
    if (next != null) {
      await _engine.seekIndex(Duration.zero, next);
    } else if (_engine.loopMode == LoopMode.all) {
      await _engine.seekIndex(Duration.zero, _sequence.first);
    } else {
      await _engine.seek(Duration.zero);
      await _engine.pause();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_engine.position.inSeconds > 3) return _engine.seek(Duration.zero);

    if (!_sequence.isShuffleEnabled) return _engine.seekToPrevious();

    final ci = _engine.currentIndex;
    if (ci == null) return;
    final effectiveIndex = _sequence.effectiveIndexOf(ci);
    if (effectiveIndex == -1) return;

    final prev = _sequence.previousPhysical(effectiveIndex);
    if (prev != null) {
      await _engine.seekIndex(Duration.zero, prev);
    } else if (_engine.loopMode == LoopMode.all) {
      await _engine.seekIndex(Duration.zero, _sequence.last);
    } else {
      await _engine.seek(Duration.zero);
    }
  }

  // Shuffle
  Future<void> setShuffle(bool enabled) async {
    final len = _engine.sequenceState?.sequence.length ?? 0;
    if (enabled) {
      _sequence.enable(len, _engine.currentIndex ?? 0);
    } else {
      _sequence.disable(len);
    }
    _emitCustomSequence();
  }

  // Queue Management
  Future<void> addToQueue(Tune tune) async {
    final newIndex = _engine.sequenceState?.sequence.length ?? 0;
    _missingSongHandler.markAvailable(tune);
    if (_sequence.isShuffleEnabled) {
      _sequence.addAtRandom(newIndex);
    } else {
      _sequence.add(newIndex);
    }
    await _engine.add(tune);
  }

  Future<void> addManyToQueue(List<Tune> tunes) async {
    final start = _engine.sequenceState?.sequence.length ?? 0;
    for (final t in tunes) {
      _missingSongHandler.markAvailable(t);
    }
    for (int i = 0; i < tunes.length; i++) {
      if (_sequence.isShuffleEnabled) {
        _sequence.addAtRandom(start + i);
      } else {
        _sequence.add(start + i);
      }
    }
    await _engine.addAll(tunes);
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    if (_sequence.isShuffleEnabled) {
      final physicalIndex = _sequence.at(index);
      if (physicalIndex == null) return;
      _sequence.removeAtEffective(index);
      await _engine.removeAt(physicalIndex);
    } else {
      await _engine.removeAt(index);
    }
  }

  @override
  Future<void> removeQueueItem(MediaItem mediaItem) async {
    final index = queue.value.indexOf(mediaItem);
    if (index != -1) await removeQueueItemAt(index);
  }

  Future<void> playAfterThis(Tune tune) async {
    _missingSongHandler.markAvailable(tune);
    if (_sequence.isShuffleEnabled) {
      final ci = _engine.currentIndex;
      if (ci == null) return;
      final target = _sequence.reserveInsertAfterCurrent(
        ci,
        physicalLength: _engine.sequenceState?.sequence.length ?? 0,
      );
      if (target == null) return;
      await _engine.insert(tune, target);
    } else {
      final ci = _engine.currentIndex;
      await _engine.insert(tune, (ci ?? 0) + 1);
    }
  }

  // Reorder
  Future<void> moveQueueItem(int oldIndex, int newIndex) async {
    if (_sequence.isShuffleEnabled) {
      _sequence.move(oldIndex, newIndex);
      _emitCustomSequence();
    } else {
      await _engine.move(oldIndex, newIndex);
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (_sequence.isShuffleEnabled) {
      final physical = _sequence.at(index);
      if (physical == null) return;
      await _engine.seekIndex(Duration.zero, physical);
    } else {
      await _engine.seekIndex(Duration.zero, index);
    }
  }

  // Repeat / Speed
  Future<void> setRepeat(LoopMode mode) => _engine.setLoopMode(mode);
  @override
  Future<void> setSpeed(double speed) => _engine.setSpeed(speed);

  @override
  Future<void> onTaskRemoved() async {
    await _engine.dispose();
    await _customSequenceController.close();
    await _unavailableController.close();
    return super.onTaskRemoved();
  }

  // Getters for bloc
  Stream<bool> get isPlaying => _engine.isPlaying;
  Stream<ProcessingState> get playerStateStream =>
      _engine.processingStateStream;
  Stream<Duration> get positionStream => _engine.positionStream;
  Stream<Duration?> get durationStream => _engine.durationStream;
}
