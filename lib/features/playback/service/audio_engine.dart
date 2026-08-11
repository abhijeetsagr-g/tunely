import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:tunely/shared/model/tune.dart';

class AudioEngine {
  final AudioPlayer _player = AudioPlayer();

  AudioEngine() {
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed &&
          _player.loopMode == LoopMode.off) {
        scheduleMicrotask(() {
          unawaited(_player.seek(Duration.zero));
          unawaited(_player.pause());
        });
      }
    });
  }

  // Streams
  Stream<bool> get isPlaying => _player.playingStream;
  Stream<ProcessingState> get processingStateStream =>
      _player.processingStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<SequenceState?> get sequenceStateStream => _player.sequenceStateStream;
  Stream<PlayerException> get errorStream => _player.errorStream;
  Stream<PlaybackEvent> get playbackEventStream => _player.playbackEventStream;

  // State snapshot
  SequenceState? get sequenceState => _player.sequenceState;
  ProcessingState get processingState => _player.processingState;
  int? get currentIndex => _player.currentIndex;
  bool get hasNext => _player.hasNext;
  bool get playing => _player.playing;
  Duration get position => _player.position;
  Duration get bufferedPosition => _player.bufferedPosition;
  LoopMode get loopMode => _player.loopMode;
  double get speed => _player.speed;

  Future<void> load(List<Tune> tunes, int initialIndex) async {
    await _player.setAudioSources(
      tunes
          .map((t) => AudioSource.uri(Uri.parse(t.path), tag: t))
          .toList(),
      preload: true,
      initialIndex: initialIndex,
      initialPosition: Duration.zero,
    );
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> stop() => _player.stop();
  Future<void> seek(Duration position) => _player.seek(position);
  Future<void> seekToNext() => _player.seekToNext();
  Future<void> seekToPrevious() => _player.seekToPrevious();
  Future<void> seekIndex(Duration position, int index) =>
      _player.seek(position, index: index);
  Future<void> setLoopMode(LoopMode mode) => _player.setLoopMode(mode);
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  Future<void> add(Tune tune) =>
      _player.addAudioSource(AudioSource.uri(Uri.parse(tune.path), tag: tune));
  Future<void> addAll(List<Tune> tunes) => _player.addAudioSources(
    tunes.map((t) => AudioSource.uri(Uri.parse(t.path), tag: t)).toList(),
  );
  Future<void> insert(Tune tune, int index) => _player.insertAudioSource(
    index,
    AudioSource.uri(Uri.parse(tune.path), tag: tune),
  );
  Future<void> removeAt(int index) => _player.removeAudioSourceAt(index);
  Future<void> move(int from, int to) => _player.moveAudioSource(from, to);

  Future<void> dispose() => _player.dispose();
}
