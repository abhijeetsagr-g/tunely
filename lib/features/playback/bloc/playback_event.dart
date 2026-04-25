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

class ChangeQueueOrder extends PlaybackEvent {
  final int oldIndex;
  final int newIndex;
  ChangeQueueOrder({required this.oldIndex, required this.newIndex});
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

class ShuffleAllEvent extends PlaybackEvent {
  final List<Tune> tunes;
  const ShuffleAllEvent(this.tunes);
}

// Settings
class SetShuffleEvent extends PlaybackEvent {
  const SetShuffleEvent();
}

class SetRepeatEvent extends PlaybackEvent {
  const SetRepeatEvent();
}

class SetSpeedEvent extends PlaybackEvent {
  final double speed;
  const SetSpeedEvent(this.speed);
}

// To Restore Previous Session
class RestoreSessionEvent extends PlaybackEvent {
  final List<Tune> queue;
  final int currentIndex;
  final Duration position;
  final bool shuffleEnabled;
  final LoopMode repeatMode;
  final double speed;

  const RestoreSessionEvent({
    required this.queue,
    required this.currentIndex,
    required this.position,
    required this.shuffleEnabled,
    required this.repeatMode,
    required this.speed,
  });
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
  final bool shuffleMode;
  final LoopMode repeatMode;
  const _SequenceStateUpdatedEvent({
    required this.currentItem,
    required this.queue,
    required this.currentIndex,
    required this.shuffleMode,
    required this.repeatMode,
  });
}
