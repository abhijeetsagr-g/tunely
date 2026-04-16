part of 'playback_bloc.dart';

enum PlaybackStatus { idle, loading, buffering, ready, completed }

class PlaybackState {
  final bool isPlaying;
  final PlaybackStatus status;
  final Duration position;
  final Duration? duration;
  final Duration bufferedPosition;
  final double speed;
  final Tune? currentItem;
  final List<Tune> queue;
  final int? currentIndex;
  final bool shuffleEnabled;
  final LoopMode repeatMode;

  const PlaybackState({
    this.isPlaying = false,
    this.status = PlaybackStatus.idle,
    this.position = Duration.zero,
    this.duration,
    this.bufferedPosition = Duration.zero,
    this.speed = 1.0,
    this.currentItem,
    this.queue = const [],
    this.currentIndex,
    this.shuffleEnabled = false,
    this.repeatMode = LoopMode.off,
  });

  PlaybackState copyWith({
    bool? isPlaying,
    PlaybackStatus? status,
    Duration? position,
    Duration? duration,
    Duration? bufferedPosition,
    double? speed,
    Tune? currentItem,
    List<Tune>? queue,
    int? currentIndex,
    bool? shuffleEnabled,
    LoopMode? repeatMode,
  }) {
    return PlaybackState(
      isPlaying: isPlaying ?? this.isPlaying,
      status: status ?? this.status,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      speed: speed ?? this.speed,
      currentItem: currentItem ?? this.currentItem,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
    );
  }
}
