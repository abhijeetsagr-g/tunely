import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:tunely/features/stats/repository/stats_repository.dart';

/// Records a play once the listener has actually spent time on a track.
class StatsService {
  final StatsRepository repo;
  late final StreamSubscription<MediaItem> _trackSub;
  late final StreamSubscription<Duration> _positionSub;
  late final StreamSubscription<bool> _playingSub;

  MediaItem? _current;
  Duration _lastPosition = Duration.zero;
  Duration _listened = Duration.zero;
  bool _counted = false;
  bool _playing = false;

  /// A larger forward jump is treated as a seek, not listening time.
  static const _maxStep = Duration(seconds: 3);
  static const _maxThreshold = Duration(seconds: 30);
  static const _minThreshold = Duration(seconds: 5);

  StatsService({
    required Stream<MediaItem> trackChanges,
    required Stream<Duration> positions,
    required Stream<bool> playing,
    required this.repo,
  }) {
    _trackSub = trackChanges.listen(_handleTrackChange);
    _positionSub = positions.listen(_handlePosition);
    _playingSub = playing.listen((value) => _playing = value);
  }

  void _handleTrackChange(MediaItem item) {
    // The same track can be re-emitted when the queue or shuffle changes.
    if (item.id == _current?.id) return;

    _current = item;
    _lastPosition = Duration.zero;
    _listened = Duration.zero;
    _counted = false;
  }

  void _handlePosition(Duration position) {
    final item = _current;
    if (item == null) return;

    final previous = _lastPosition;
    _lastPosition = position;
    final delta = position - previous;

    if (delta < Duration.zero) {
      _handleBackwardJump(position);
      return;
    }

    if (!_playing || delta > _maxStep) return;

    _listened += delta;
    if (_counted || _listened < _threshold(item.duration)) return;

    _counted = true;
    _recordPlay(item);
  }

  void _handleBackwardJump(Duration position) {
    if (position > const Duration(seconds: 2)) return;

    _listened = Duration.zero;
    _counted = false;
  }

  void _recordPlay(MediaItem item) {
    final stats = repo.get(item.id);
    stats.playCount++;
    stats.lastPlayed = DateTime.now();
    repo.save(stats);

    final recent = repo.getRecentOrder();
    recent.remove(item.id);
    recent.insert(0, item.id);
    if (recent.length > 50) {
      recent.removeLast();
    }
    repo.saveRecentOrder(recent);

    unawaited(repo.flush());
  }

  Duration _threshold(Duration? duration) {
    if (duration == null || duration <= Duration.zero) {
      return const Duration(seconds: 15);
    }

    final half = Duration(milliseconds: duration.inMilliseconds ~/ 2);
    final capped = half < _maxThreshold ? half : _maxThreshold;
    final floored = capped < _minThreshold ? _minThreshold : capped;
    return floored < duration ? floored : duration;
  }

  Future<void> dispose() async {
    await _trackSub.cancel();
    await _positionSub.cancel();
    await _playingSub.cancel();
  }
}
