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
  final bool autoPlay;
  PlaySong({required this.index, required this.tune, this.autoPlay = true});
}

class SkipToQueueItem extends PlaybackEvent {
  final int index;
  SkipToQueueItem(this.index);
}

class AddToQueue extends PlaybackEvent {
  final Tune tune;
  AddToQueue(this.tune);
}

class PlayAfterThis extends PlaybackEvent {
  final Tune tune;
  PlayAfterThis(this.tune);
}

class ShuffleAll extends PlaybackEvent {
  final List<Tune> tunes;
  final int startIndex;

  ShuffleAll({required this.tunes})
    : startIndex = Random().nextInt(tunes.length);
}

class Play extends PlaybackEvent {}

class Pause extends PlaybackEvent {}

class PlayPrev extends PlaybackEvent {}

class PlayNext extends PlaybackEvent {}

class ToggleShuffle extends PlaybackEvent {}

class CycleRepeat extends PlaybackEvent {}

class SetSleepTimer extends PlaybackEvent {
  final Duration duration;
  SetSleepTimer(this.duration);
}

class CancelSleepTimer extends PlaybackEvent {}

class SleepTick extends PlaybackEvent {
  Duration remaining;

  SleepTick(this.remaining);
}

class Seek extends PlaybackEvent {
  final Duration pos;
  Seek(this.pos);
}
