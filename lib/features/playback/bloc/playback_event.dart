part of 'playback_bloc.dart';

sealed class PlaybackEvent {
  const PlaybackEvent();
}

// Playback Controls
class PlayQueueEvent extends PlaybackEvent {
  final List<Tune> items;
  final int startIndex;
  const PlayQueueEvent(this.items, {this.startIndex = 0});
}

class PlayEvent extends PlaybackEvent {
  const PlayEvent();
}

class PauseEvent extends PlaybackEvent {
  const PauseEvent();
}

class StopEvent extends PlaybackEvent {
  const StopEvent();
}

class SeekEvent extends PlaybackEvent {
  final Duration position;
  const SeekEvent(this.position);
}

class SkipToNextEvent extends PlaybackEvent {
  const SkipToNextEvent();
}

class SkipToPreviousEvent extends PlaybackEvent {
  const SkipToPreviousEvent();
}

class SkipToQueueItemEvent extends PlaybackEvent {
  final int index;
  const SkipToQueueItemEvent(this.index);
}

// Queue Management
class AddQueueItemEvent extends PlaybackEvent {
  final Tune item;
  const AddQueueItemEvent(this.item);
}

class AddQueueItemsEvent extends PlaybackEvent {
  final List<Tune> items;
  const AddQueueItemsEvent(this.items);
}

class RemoveQueueItemEvent extends PlaybackEvent {
  final Tune item;
  const RemoveQueueItemEvent(this.item);
}

class RemoveQueueItemAtEvent extends PlaybackEvent {
  final int index;
  const RemoveQueueItemAtEvent(this.index);
}

class PlayAfterThisEvent extends PlaybackEvent {
  final Tune item;
  const PlayAfterThisEvent(this.item);
}

// Settings
class SetShuffleEvent extends PlaybackEvent {
  final bool enabled;
  const SetShuffleEvent(this.enabled);
}

class SetRepeatEvent extends PlaybackEvent {
  final LoopMode mode;
  const SetRepeatEvent(this.mode);
}

class SetSpeedEvent extends PlaybackEvent {
  final double speed;
  const SetSpeedEvent(this.speed);
}

// Internal — emitted by stream listeners inside the bloc
class _PlayerStateUpdatedEvent extends PlaybackEvent {
  final bool isPlaying;
  const _PlayerStateUpdatedEvent(this.isPlaying);
}

class _PositionUpdatedEvent extends PlaybackEvent {
  final Duration position;
  const _PositionUpdatedEvent(this.position);
}

class _DurationUpdatedEvent extends PlaybackEvent {
  final Duration? duration;
  const _DurationUpdatedEvent(this.duration);
}

class _BufferedPositionUpdatedEvent extends PlaybackEvent {
  final Duration bufferedPosition;
  const _BufferedPositionUpdatedEvent(this.bufferedPosition);
}

class _ProcessingStateUpdatedEvent extends PlaybackEvent {
  final PlaybackStatus status;
  const _ProcessingStateUpdatedEvent(this.status);
}

class _SequenceStateUpdatedEvent extends PlaybackEvent {
  final Tune? currentItem;
  final List<Tune> queue;
  final int currentIndex;
  const _SequenceStateUpdatedEvent({
    required this.currentItem,
    required this.queue,
    required this.currentIndex,
  });
}
