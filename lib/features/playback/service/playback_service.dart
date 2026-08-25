import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tunely/features/playback/service/audio_engine.dart';
import 'package:tunely/features/playback/service/missing_song_handler.dart';
import 'package:tunely/features/playback/service/tunely_shuffle_order.dart';
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
  late final MissingSongHandler _missingSongHandler;

  TunelyShuffleOrder get _order => _engine.shuffleOrder;

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

    final physicalIndex = seqState.currentIndex;
    if (physicalIndex == null) return;

    final shuffled = seqState.shuffleModeEnabled;
    final effectiveSources = seqState.effectiveSequence;
    if (physicalIndex >= effectiveSources.length) return;

    final effectiveIndex = shuffled
        ? _engine.shuffleIndices.indexOf(physicalIndex)
        : physicalIndex;
    if (effectiveIndex < 0 || effectiveIndex >= effectiveSources.length) return;

    final effectiveQueue = effectiveSources
        .map((s) => s.tag as Tune)
        .toList(growable: false);

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
        shuffleEnabled: shuffled,
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
      shuffleMode: _engine.shuffleModeEnabled
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
    if (_engine.hasNext) return _engine.seekToNext();
    await _engine.seek(Duration.zero);
    await _engine.pause();
  }

  @override
  Future<void> skipToPrevious() async {
    if (_engine.position.inSeconds > 3) return _engine.seek(Duration.zero);

    if (_engine.hasPrevious) return _engine.seekToPrevious();
    await _engine.seek(Duration.zero);
  }

  // Shuffle
  Future<void> setShuffle(bool enabled) async {
    if (enabled == _engine.shuffleModeEnabled) return;
    if (enabled) {
      await _engine.setShuffleModeEnabled(true);
      // Reshuffle with the current item at the head of the play order.
      await _engine.shuffle();
    } else {
      _order.cancelPin();
      await _engine.setShuffleModeEnabled(false);
    }
    _emitCustomSequence();
  }

  // Queue Management
  Future<void> addToQueue(Tune tune) async {
    _missingSongHandler.markAvailable(tune);
    _order.cancelPin(); // random insert position
    await _engine.add(tune);
  }

  Future<void> addManyToQueue(List<Tune> tunes) async {
    _order.cancelPin();
    for (final t in tunes) {
      _missingSongHandler.markAvailable(t);
    }
    await _engine.addAll(tunes);
  }

  /// Removes the item at [index] in the *effective* queue order.
  @override
  Future<void> removeQueueItemAt(int index) async {
    final physical = _effectiveToPhysical(index);
    if (physical == null) return;
    await _engine.removeAt(physical);
  }

  @override
  Future<void> removeQueueItem(MediaItem mediaItem) async {
    final index = queue.value.indexOf(mediaItem);
    if (index != -1) await removeQueueItemAt(index);
  }

  Future<void> playAfterThis(Tune tune) async {
    final ci = _engine.currentIndex;
    if (ci == null) return;
    _missingSongHandler.markAvailable(tune);

    if (_engine.shuffleModeEnabled) {
      final inv = _engine.shuffleIndices.indexOf(ci);
      if (inv != -1) _order.pinNextInsert(inv + 1);
    }
    await _engine.insert(tune, ci + 1);
  }

  // Reorder
  /// Moves the item at effective position [oldIndex] to [newIndex].
  ///
  /// Expressed as a single physical no-op move whose shuffle-order insert is
  /// pinned to the target effective slot, so playback is never interrupted.
  Future<void> moveQueueItem(int oldIndex, int newIndex) async {
    if (!_engine.shuffleModeEnabled) return _engine.move(oldIndex, newIndex);

    final indices = _engine.shuffleIndices;
    if (oldIndex < 0 || oldIndex >= indices.length) return;

    _order.cancelPin();
    final physical = indices[oldIndex];
    // The dragged entry leaves a gap first; compensate for it.
    _order.pinNextInsert(newIndex > oldIndex ? newIndex - 1 : newIndex);
    await _engine.move(physical, physical);
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    final physical = _effectiveToPhysical(index);
    if (physical == null) return;
    await _engine.seekIndex(Duration.zero, physical);
  }

  /// Maps an effective queue position to its physical playlist index.
  int? _effectiveToPhysical(int index) {
    if (!_engine.shuffleModeEnabled) return index;
    final indices = _engine.shuffleIndices;
    if (index < 0 || index >= indices.length) return null;
    return indices[index];
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
