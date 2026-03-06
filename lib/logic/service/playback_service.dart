import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class PlaybackService extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = AudioPlayer();

  PlaybackService() {
    _init();
  }

  void _init() {
    // set custom player state
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);

    // Listen to current Song
    _player.currentIndexStream.listen((index) {
      if (index == null) return;
      final q = queue.value;
      if (mediaItem.value?.id != q[index].id) {
        mediaItem.add(q[index]);
      }
    });
  }

  PlaybackState _transformEvent(PlaybackEvent _) {
    return PlaybackState(
      // notification script
      controls: [
        .skipToNext,
        if (_player.playing) .play else .pause,
        .skipToPrevious,
      ],

      // Which actions are supported (for Android media session)
      systemActions: {
        .stop,
        .playPause,
        .seek,
        .skipToNext,
        .skipToPrevious,
        .setShuffleMode,
        .setRepeatMode,
      },
      // Mapping just_audio ProcessingState → audio_service AudioProcessingState
      processingState: switch (_player.processingState) {
        .idle => .idle,
        .ready => .ready,
        .loading => .loading,
        .buffering => .buffering,
        .completed => .completed,
      },

      // maping other
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      queueIndex: _player.currentIndex,
      speed: _player.speed,

      shuffleMode: _player.shuffleModeEnabled
          ? AudioServiceShuffleMode.all
          : AudioServiceShuffleMode.none,
      repeatMode: switch (_player.loopMode) {
        LoopMode.one => .one,
        LoopMode.all => .all,
        _ => AudioServiceRepeatMode.none,
      },
    );
  }

  // Playback Controls
  Future<void> playQueue(List<MediaItem> items, int startIndex) async {
    queue.add(items);

    await _player.setAudioSources(
      items.map((e) => AudioSource.uri(Uri.parse(e.id), tag: e)).toList(),
      initialIndex: startIndex,
      initialPosition: Duration.zero,
    );

    mediaItem.add(items[startIndex]);
    play();
  }

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
      _player.stop();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_player.position.inSeconds > 3) {
      seek(.zero);
    } else {
      _player.seekToPrevious();
    }
  }

  Future<void> setShuffle(bool enabled) async {
    await _player.setShuffleModeEnabled(enabled);
  }

  Future<void> setRepeat(LoopMode mode) async {
    await _player.setLoopMode(mode);
  }

  @override
  Future<void> onTaskRemoved() async {
    await _player.dispose();
    return super.onTaskRemoved();
  }

  // GETTERS
  Stream<bool> get isPlaying => _player.playingStream;
  Stream<ProcessingState> get playerStateStream =>
      _player.processingStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<SequenceState> get sequenceStateStream => _player.sequenceStateStream;
}
