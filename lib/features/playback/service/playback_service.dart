import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PlaybackService extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = AudioPlayer();

  PlaybackService() {
    _init();
  }

  // initialize on creating instance
  void _init() {
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _player.seek(Duration.zero);
        _player.pause();
      }
    });

    // converts events
    _player.playbackEventStream
        .map(_transformEvent)
        .handleError((e) => debugPrint('Playback event error: $e'))
        .pipe(playbackState);

    _player.sequenceStateStream.listen((state) {
      final index = state.currentIndex;

      if (index == null) return;
      final q = queue.value;
      if (index < q.length) {
        final item = q[index];

        mediaItem.add(item);
        _trackController.add(item);
      }
    });
  }

  PlaybackState _transformEvent(PlaybackEvent _) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],

      // Which actions are supported (for Android media session)
      systemActions: {
        MediaAction.stop,
        MediaAction.playPause,
        MediaAction.seek,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
        MediaAction.setShuffleMode,
        MediaAction.setRepeatMode,
      },
      // Mapping just_audio ProcessingState → audio_service AudioProcessingState
      processingState: switch (_player.processingState) {
        ProcessingState.idle => AudioProcessingState.idle,
        ProcessingState.ready => AudioProcessingState.ready,
        ProcessingState.loading => AudioProcessingState.loading,
        ProcessingState.buffering => AudioProcessingState.buffering,
        ProcessingState.completed => AudioProcessingState.completed,
      },

      // maping other
      playing: _player.playing,
      speed: _player.speed,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      queueIndex: _player.currentIndex,
      shuffleMode: _player.shuffleModeEnabled
          ? AudioServiceShuffleMode.all
          : AudioServiceShuffleMode.none,
      repeatMode: switch (_player.loopMode) {
        LoopMode.one => AudioServiceRepeatMode.one,
        LoopMode.all => AudioServiceRepeatMode.all,
        _ => AudioServiceRepeatMode.none,
      },
    );
  }

  // Playback Controls
  Future<void> playQueue(List<MediaItem> items, int startIndex) async {
    queue.add(items);
    final playlist = items
        .map((e) => AudioSource.uri(Uri.parse(e.id), tag: e))
        .toList();
    await _player.setAudioSources(
      playlist,
      preload: true,
      initialIndex: startIndex,
      shuffleOrder: DefaultShuffleOrder(),
      initialPosition: Duration.zero,
    );

    play();
  }

  // Basic Controls
  @override
  Future<void> play() => _player.play();
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> stop() => _player.stop();
  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (_player.hasNext) {
      _player.seekToNext();
    } else {
      _player.seek(Duration.zero);
      _player.pause();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_player.position.inSeconds > 3) {
      seek(Duration.zero);
    } else {
      _player.seekToPrevious();
    }
  }

  // Queue Management
  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    await _player.addAudioSource(
      AudioSource.uri(Uri.parse(mediaItem.id), tag: mediaItem),
    );

    final sequence = _player.sequenceState.sequence;
    updateQueue(sequence.map((s) => s.tag as MediaItem).toList());
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    await _player.addAudioSources(
      mediaItems
          .map((item) => AudioSource.uri(Uri.parse(item.id), tag: item))
          .toList(),
    );
    final sequence = _player.sequenceState.sequence;
    updateQueue(sequence.map((s) => s.tag as MediaItem).toList());
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    await _player.removeAudioSourceAt(index);
    final sequence = _player.sequenceState.sequence;
    updateQueue(sequence.map((s) => s.tag as MediaItem).toList());
  }

  @override
  Future<void> removeQueueItem(MediaItem mediaItem) async {
    final index = queue.value.indexOf(mediaItem);
    if (index != -1) await removeQueueItemAt(index);
  }

  Future<void> playAfterThis(MediaItem item) async {
    final insertIndex = (_player.currentIndex ?? 0) + 1;
    await _player.insertAudioSource(
      insertIndex,
      AudioSource.uri(Uri.parse(item.id), tag: item),
    );

    final sequence = _player.sequenceState.sequence;
    updateQueue(sequence.map((s) => s.tag as MediaItem).toList());
  }

  @override
  Future<void> skipToQueueItem(int index) async =>
      await _player.seek(Duration.zero, index: index);

  // Repeat/ Loop
  Future<void> setShuffle(bool enabled) async {
    if (enabled) await _player.shuffle();
    await _player.setShuffleModeEnabled(enabled);
  }

  @override
  Future<void> setSpeed(double speed) async => _player.setSpeed(speed);

  Future<void> setRepeat(LoopMode mode) async =>
      await _player.setLoopMode(mode);

  @override
  Future<void> onTaskRemoved() async {
    await _player.dispose();
    return super.onTaskRemoved();
  }

  // when new song is played
  final _trackController = StreamController<MediaItem>.broadcast();
  Stream<MediaItem> get onTrackChanged => _trackController.stream;

  // GETTERS

  Stream<bool> get isPlaying => _player.playingStream;
  Stream<ProcessingState> get playerStateStream =>
      _player.processingStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<SequenceState> get sequenceStateStream => _player.sequenceStateStream;
}
