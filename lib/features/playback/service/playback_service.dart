import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
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
  final _player = AudioPlayer();
  int? _lastEmittedIndex;
  bool _isSwappingQueue = false;

  // Custom shuffle state
  bool _shuffleEnabled = false;
  List<int> _shuffleIndices = [];

  // Missing-song tracking
  final Set<String> _failedPaths = {};
  int? _pendingFailedIndex;
  Tune? _pendingFailedTune;

  // Custom stream for bloc (replaces just_audio's sequenceStateStream)
  final _customSequenceController =
      StreamController<CustomSequenceState>.broadcast();
  Stream<CustomSequenceState> get customSequenceStream =>
      _customSequenceController.stream;

  // Emits the Tune whenever a queued song can no longer be loaded/played
  final _unavailableController = StreamController<Tune>.broadcast();
  Stream<Tune> get onSongUnavailable => _unavailableController.stream;

  PlaybackService() {
    _init();
  }

  void _init() {
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _player.seek(Duration.zero);
        _player.pause();
      }
    });

    _player.errorStream.listen((error) => _handleLoadError(error));

    _player.playbackEventStream
        .map(_transformEvent)
        .handleError((e) => debugPrint('Playback event error: $e'))
        .pipe(playbackState);

    _player.sequenceStateStream.listen((_) {
      if (_isSwappingQueue) return;
      _emitCustomSequence();
    });
  }

  void _emitCustomSequence() {
    final seqState = _player.sequenceState;

    final physical = seqState.sequence;
    final physicalIndex = seqState.currentIndex;
    if (physicalIndex == null) return;
    if (physicalIndex >= physical.length) return;

    // Safety: sync _shuffleIndices if it got out of sync with physical
    if (_shuffleIndices.length != physical.length) {
      _shuffleIndices = List.generate(physical.length, (i) => i);
      if (_shuffleEnabled) _shuffleIndices.shuffle(Random());
    }

    final effectiveQueue = _shuffleEnabled
        ? _shuffleIndices.map((i) => (physical[i].tag as Tune)).toList()
        : physical.map((s) => s.tag as Tune).toList();

    final effectiveIndex = _shuffleEnabled
        ? _shuffleIndices.indexOf(physicalIndex)
        : physicalIndex;

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
        shuffleEnabled: _shuffleEnabled,
        repeatMode: seqState.loopMode,
      ),
    );
  }

  // Handles a source that could not be loaded/played (file deleted, unmounted
  // storage, ...). Reported either by the player's error stream or thrown from
  // a play/load call. Removes the song from the queue, notifies the bloc, and
  // advances to the next track.
  void _handleLoadError(PlayerException error, {Tune? fallbackTune}) {
    final sequence = _player.sequenceState.sequence;

    Tune? failed;
    if (fallbackTune != null) {
      failed = fallbackTune;
      _pendingFailedIndex = error.index;
      _pendingFailedTune = fallbackTune;
    } else if (_pendingFailedTune != null &&
        error.index == _pendingFailedIndex) {
      // Same failure redelivered (thrown future + error stream). The error
      // index is stale now that the source was removed, so reuse the tune the
      // first delivery identified.
      failed = _pendingFailedTune;
      _pendingFailedIndex = null;
      _pendingFailedTune = null;
    } else {
      _pendingFailedIndex = null;
      _pendingFailedTune = null;
      final index = error.index;
      if (index == null || index < 0 || index >= sequence.length) return;
      final tag = sequence[index].tag;
      if (tag is! Tune) return;
      failed = tag;
    }

    if (failed == null) return;
    if (!_failedPaths.add(failed.path)) return;

    final physicalIndex = sequence.indexWhere((s) => s.tag == failed);
    if (physicalIndex == -1) {
      _failedPaths.remove(failed.path);
      return;
    }
    _handleFailedTune(failed, physicalIndex);
  }

  Future<void> _handleFailedTune(Tune tune, int physicalIndex) async {
    _unavailableController.add(tune);

    final effectiveIndex = _shuffleEnabled
        ? _shuffleIndices.indexOf(physicalIndex)
        : physicalIndex;

    if (_shuffleEnabled && effectiveIndex != -1) {
      _shuffleIndices.removeAt(effectiveIndex);
      for (int i = 0; i < _shuffleIndices.length; i++) {
        if (_shuffleIndices[i] > physicalIndex) _shuffleIndices[i]--;
      }
    }

    try {
      await _player.removeAudioSourceAt(physicalIndex);
    } catch (e) {
      debugPrint('Failed to remove missing song from queue: $e');
    }

    await _advanceAfterFailure(physicalIndex, effectiveIndex);
  }

  Future<void> _advanceAfterFailure(
    int failedPhysicalIndex,
    int effectiveIndex,
  ) async {
    final sequence = _player.sequenceState.sequence;

    if (_shuffleEnabled) {
      if (_shuffleIndices.isEmpty) {
        await _player.stop();
        return;
      }
      int nextPhysical;
      if (effectiveIndex >= 0 && effectiveIndex < _shuffleIndices.length) {
        nextPhysical = _shuffleIndices[effectiveIndex];
      } else if (_player.loopMode == LoopMode.all) {
        nextPhysical = _shuffleIndices.first;
      } else {
        await _player.seek(Duration.zero);
        await _player.pause();
        return;
      }
      await _player.seek(Duration.zero, index: nextPhysical);
    } else {
      if (failedPhysicalIndex < sequence.length) {
        await _player.seek(Duration.zero, index: failedPhysicalIndex);
      } else if (_player.loopMode == LoopMode.all) {
        await _player.seek(Duration.zero, index: 0);
      } else {
        await _player.seek(Duration.zero);
        await _player.pause();
        return;
      }
    }

    _emitCustomSequence();
    unawaited(
      _player.play().catchError((Object e) {
        debugPrint('Failed to resume after skipping missing song: $e');
      }),
    );
  }

  PlaybackState _transformEvent(PlaybackEvent _) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
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
      processingState: switch (_player.processingState) {
        ProcessingState.idle => AudioProcessingState.idle,
        ProcessingState.ready => AudioProcessingState.ready,
        ProcessingState.loading => AudioProcessingState.loading,
        ProcessingState.buffering => AudioProcessingState.buffering,
        ProcessingState.completed => AudioProcessingState.completed,
      },
      playing: _player.playing,
      speed: _player.speed,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      queueIndex: _player.currentIndex,
      shuffleMode: _shuffleEnabled
          ? AudioServiceShuffleMode.all
          : AudioServiceShuffleMode.none,
      repeatMode: switch (_player.loopMode) {
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
    _lastEmittedIndex = null;
    _isSwappingQueue = true;
    _failedPaths.clear();
    _pendingFailedIndex = null;
    _pendingFailedTune = null;

    final playlist = tunes
        .map((t) => AudioSource.uri(Uri.parse(t.path), tag: t))
        .toList();

    try {
      await _player.setAudioSources(
        playlist,
        preload: true,
        initialIndex: startIndex,
        initialPosition: Duration.zero,
      );

      _shuffleIndices = List.generate(playlist.length, (i) => i);
      if (_shuffleEnabled && _shuffleIndices.length > 1) {
        final current = _shuffleIndices.removeAt(startIndex);
        _shuffleIndices.shuffle(Random());
        _shuffleIndices.insert(0, current);
      }

      _isSwappingQueue = false;
      if (autoPlay) await _player.play();
    } on PlayerException catch (e) {
      _isSwappingQueue = false;
      _handleLoadError(
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
      await _player.play();
    } on PlayerException catch (e) {
      _handleLoadError(e);
    }
  }

  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> stop() => _player.stop();
  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (!_shuffleEnabled) {
      if (_player.hasNext) return _player.seekToNext();
      await _player.seek(Duration.zero);
      return _player.pause();
    }
    final ci = _player.currentIndex;
    if (ci == null) return;
    final effectiveIndex = _shuffleIndices.indexOf(ci);
    if (effectiveIndex == -1) return;

    if (effectiveIndex < _shuffleIndices.length - 1) {
      await _player.seek(
        Duration.zero,
        index: _shuffleIndices[effectiveIndex + 1],
      );
    } else if (_player.loopMode == LoopMode.all) {
      await _player.seek(Duration.zero, index: _shuffleIndices[0]);
    } else {
      await _player.seek(Duration.zero);
      await _player.pause();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_player.position.inSeconds > 3) return _player.seek(Duration.zero);

    if (!_shuffleEnabled) return _player.seekToPrevious();

    final ci = _player.currentIndex;
    if (ci == null) return;
    final effectiveIndex = _shuffleIndices.indexOf(ci);
    if (effectiveIndex == -1) return;

    if (effectiveIndex > 0) {
      await _player.seek(
        Duration.zero,
        index: _shuffleIndices[effectiveIndex - 1],
      );
    } else if (_player.loopMode == LoopMode.all) {
      await _player.seek(Duration.zero, index: _shuffleIndices.last);
    } else {
      await _player.seek(Duration.zero);
    }
  }

  // Shuffle

  Future<void> setShuffle(bool enabled) async {
    _shuffleEnabled = enabled;
    final len = _player.sequenceState.sequence.length;
    if (enabled) {
      final ci = _player.currentIndex ?? 0;
      _shuffleIndices = List.generate(len, (i) => i);
      if (_shuffleIndices.length > 1) {
        final current = _shuffleIndices.removeAt(ci);
        _shuffleIndices.shuffle(Random());
        _shuffleIndices.insert(0, current);
      }
    } else {
      _shuffleIndices = List.generate(len, (i) => i);
    }
    _emitCustomSequence();
  }

  // Queue Management

  Future<void> addToQueue(Tune tune) async {
    final newIndex = _player.sequenceState.sequence.length;
    _failedPaths.remove(tune.path);
    if (_shuffleEnabled) {
      _shuffleIndices.add(newIndex);
      final pos = Random().nextInt(_shuffleIndices.length);
      final item = _shuffleIndices.removeLast();
      _shuffleIndices.insert(pos, item);
    } else {
      _shuffleIndices.add(newIndex);
    }
    await _player.addAudioSource(
      AudioSource.uri(Uri.parse(tune.path), tag: tune),
    );
  }

  Future<void> addManyToQueue(List<Tune> tunes) async {
    final start = _player.sequenceState.sequence.length;
    for (final t in tunes) {
      _failedPaths.remove(t.path);
    }
    for (int i = 0; i < tunes.length; i++) {
      if (_shuffleEnabled) {
        _shuffleIndices.add(start + i);
        final pos = Random().nextInt(_shuffleIndices.length);
        final item = _shuffleIndices.removeLast();
        _shuffleIndices.insert(pos, item);
      } else {
        _shuffleIndices.add(start + i);
      }
    }
    await _player.addAudioSources(
      tunes.map((t) => AudioSource.uri(Uri.parse(t.path), tag: t)).toList(),
    );
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    if (_shuffleEnabled) {
      final physicalIndex = _shuffleIndices[index];
      _shuffleIndices.removeAt(index);
      for (int i = 0; i < _shuffleIndices.length; i++) {
        if (_shuffleIndices[i] > physicalIndex) _shuffleIndices[i]--;
      }
      await _player.removeAudioSourceAt(physicalIndex);
    } else {
      await _player.removeAudioSourceAt(index);
    }
  }

  @override
  Future<void> removeQueueItem(MediaItem mediaItem) async {
    final index = queue.value.indexOf(mediaItem);
    if (index != -1) await removeQueueItemAt(index);
  }

  Future<void> playAfterThis(Tune tune) async {
    _failedPaths.remove(tune.path);
    if (_shuffleEnabled) {
      final ci = _player.currentIndex;
      if (ci == null) return;
      final shuffledCurrent = _shuffleIndices.indexOf(ci);
      if (shuffledCurrent == -1) return;
      final insertShuffled = shuffledCurrent + 1;

      if (insertShuffled < _shuffleIndices.length) {
        final physicalTarget = _shuffleIndices[insertShuffled];
        for (int i = 0; i < _shuffleIndices.length; i++) {
          if (_shuffleIndices[i] >= physicalTarget) _shuffleIndices[i]++;
        }
        _shuffleIndices.insert(insertShuffled, physicalTarget);
        await _player.insertAudioSource(
          physicalTarget,
          AudioSource.uri(Uri.parse(tune.path), tag: tune),
        );
      } else {
        final newIndex = _player.sequenceState.sequence.length;
        _shuffleIndices.add(newIndex);
        await _player.addAudioSource(
          AudioSource.uri(Uri.parse(tune.path), tag: tune),
        );
      }
    } else {
      final ci = _player.currentIndex;
      await _player.insertAudioSource(
        (ci ?? 0) + 1,
        AudioSource.uri(Uri.parse(tune.path), tag: tune),
      );
    }
  }

  // Reorder
  Future<void> moveQueueItem(int oldIndex, int newIndex) async {
    if (_shuffleEnabled) {
      final entry = _shuffleIndices.removeAt(oldIndex);
      _shuffleIndices.insert(newIndex, entry);
      _emitCustomSequence();
    } else {
      await _player.moveAudioSource(oldIndex, newIndex);
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (_shuffleEnabled) {
      if (index >= _shuffleIndices.length) return;
      await _player.seek(Duration.zero, index: _shuffleIndices[index]);
    } else {
      await _player.seek(Duration.zero, index: index);
    }
  }

  // Repeat / Speed
  Future<void> setRepeat(LoopMode mode) async =>
      await _player.setLoopMode(mode);

  @override
  Future<void> setSpeed(double speed) async => _player.setSpeed(speed);

  @override
  Future<void> onTaskRemoved() async {
    await _player.dispose();
    await _customSequenceController.close();
    await _unavailableController.close();
    return super.onTaskRemoved();
  }

  // Track‑changed stream
  final _trackController = StreamController<MediaItem>.broadcast();
  Stream<MediaItem> get onTrackChanged => _trackController.stream;

  // Getters for bloc

  Stream<bool> get isPlaying => _player.playingStream;
  Stream<ProcessingState> get playerStateStream =>
      _player.processingStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
}
