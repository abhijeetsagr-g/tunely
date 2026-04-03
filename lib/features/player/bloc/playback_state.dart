part of 'playback_bloc.dart';

enum RepeatMode { none, one, all }

class PlaybackState {
  final bool isPlaying;
  final bool isBuffering;
  final bool isLoading;
  final bool isShuffleMode;
  final bool hasNext;
  final bool hasPrev;
  final List<Tune> queue;
  final Tune? currentSong;
  final int currentIndex;
  final Duration pos;
  final Duration dur;
  final RepeatMode repeatMode;
  final Duration? sleepTimer;
  final Tune? nextSong;

  PlaybackState({
    required this.isPlaying,
    required this.isBuffering,
    required this.isLoading,
    required this.isShuffleMode,
    required this.hasNext,
    required this.hasPrev,
    required this.pos,
    required this.dur,
    required this.repeatMode,
    required this.queue,
    this.currentSong,
    this.nextSong,
    this.sleepTimer,
    required this.currentIndex,
  });

  PlaybackState copyWith({
    bool? isPlaying,
    bool? isBuffering,
    bool? isLoading,
    bool? isShuffleMode,
    bool? hasNext,
    bool? hasPrev,
    Optional<Tune?>? currentSong,
    Duration? pos,
    Duration? dur,
    RepeatMode? repeatMode,
    List<Tune>? sortedTunes,
    List<Tune>? queue,
    Tune? nextSong,
    int? currentIndex,

    Optional<Duration?>? sleepTimer,
  }) => PlaybackState(
    isPlaying: isPlaying ?? this.isPlaying,
    isBuffering: isBuffering ?? this.isBuffering,
    isLoading: isLoading ?? this.isLoading,
    isShuffleMode: isShuffleMode ?? this.isShuffleMode,
    hasNext: hasNext ?? this.hasNext,
    hasPrev: hasPrev ?? this.hasPrev,
    currentSong: currentSong != null ? currentSong.value : this.currentSong,
    pos: pos ?? this.pos,
    dur: dur ?? this.dur,
    repeatMode: repeatMode ?? this.repeatMode,
    queue: queue ?? this.queue,
    nextSong: nextSong ?? this.nextSong,
    sleepTimer: sleepTimer != null ? sleepTimer.value : this.sleepTimer,
    currentIndex: currentIndex ?? this.currentIndex,
  );
}

class Optional<T> {
  final T? value;
  const Optional(this.value);
}
