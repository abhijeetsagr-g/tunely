part of 'playback_bloc.dart';

abstract class PlaybackEvent {}

class PlayingChange extends PlaybackEvent {
  final bool isPlaying;

  PlayingChange(this.isPlaying);
}

class SequenceChange extends PlaybackEvent {
  final SequenceState sequence;

  SequenceChange(this.sequence);
}

class SongLoaded extends PlaybackEvent {
  final List<SongModel> songs;

  SongLoaded(this.songs);
}

class PositionChange extends PlaybackEvent {
  final Duration position;

  PositionChange(this.position);
}

class DurationChange extends PlaybackEvent {
  final Duration? duration;

  DurationChange(this.duration);
}

class ProcessStateChange extends PlaybackEvent {
  final bool isBuffering;
  final bool isLoading;

  ProcessStateChange(this.isBuffering, this.isLoading);
}

class PlaySong extends PlaybackEvent {
  final int index;
  final List<Tune> tune;

  PlaySong({required this.index, required this.tune});
}

class Play extends PlaybackEvent {}

class Pause extends PlaybackEvent {}

class Seek extends PlaybackEvent {
  final Duration pos;

  Seek(this.pos);
}
