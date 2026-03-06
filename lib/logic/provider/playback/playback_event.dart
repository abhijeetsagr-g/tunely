part of 'playback_bloc.dart';

enum TuneSortType { title, artist, recentlyAdded, album }

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

  ProcessStateChange(this.isBuffering);
}

class PlaySong extends PlaybackEvent {
  final int index;
  final List<Tune> tune;

  PlaySong({required this.index, required this.tune});
}

class Play extends PlaybackEvent {}

class Pause extends PlaybackEvent {}

class PlayPrev extends PlaybackEvent {}

class PlayNext extends PlaybackEvent {}

class ToggleShuffle extends PlaybackEvent {}

class CycleRepeat extends PlaybackEvent {}

class SortTunes extends PlaybackEvent {
  final TuneSortType sort;
  SortTunes(this.sort);
}

class Seek extends PlaybackEvent {
  final Duration pos;
  Seek(this.pos);
}
