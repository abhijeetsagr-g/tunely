import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tunely/features/playback/service/audio_engine.dart';
import 'package:tunely/features/playback/service/queue_sequence.dart';
import 'package:tunely/shared/model/tune.dart';

/// Recovers from a source that could not be loaded or played (deleted file,
/// unmounted storage, ...). Removes the failing song from the queue, notifies
/// the bloc, and advances to the next track.
class MissingSongHandler {
  final AudioEngine _engine;
  final QueueSequence _sequence;
  final void Function(Tune) _onUnavailable;
  final void Function() _onAdvanced;

  final Set<String> _failedPaths = {};
  int? _pendingFailedIndex;
  Tune? _pendingFailedTune;

  MissingSongHandler(
    this._engine,
    this._sequence, {
    required void Function(Tune) onUnavailable,
    required void Function() onAdvanced,
  }) : _onUnavailable = onUnavailable,
       _onAdvanced = onAdvanced;

  void reset() {
    _failedPaths.clear();
    _pendingFailedIndex = null;
    _pendingFailedTune = null;
  }

  void markAvailable(Tune tune) => _failedPaths.remove(tune.path);

  void handleError(PlayerException error, {Tune? fallbackTune}) {
    final sequence = _engine.sequenceState?.sequence;

    Tune? failed;
    if (fallbackTune != null) {
      failed = fallbackTune;
      _pendingFailedIndex = error.index;
      _pendingFailedTune = fallbackTune;
    } else if (_pendingFailedTune != null &&
        error.index == _pendingFailedIndex) {
      // Same failure redelivered (thrown future + error stream). The error
      // index is stale now that the source was removed, so reuse the tune the
      // first delivery identified.
      failed = _pendingFailedTune;
      _pendingFailedIndex = null;
      _pendingFailedTune = null;
    } else {
      _pendingFailedIndex = null;
      _pendingFailedTune = null;
      final index = error.index;
      if (index == null || index < 0 || sequence == null || index >= sequence.length) {
        return;
      }
      final tag = sequence[index].tag;
      if (tag is! Tune) return;
      failed = tag;
    }

    if (failed == null) return;
    if (!_failedPaths.add(failed.path)) return;

    final physicalIndex = sequence?.indexWhere((s) => s.tag == failed) ?? -1;
    if (physicalIndex == -1) {
      _failedPaths.remove(failed.path);
      return;
    }
    unawaited(_handleFailedTune(failed, physicalIndex));
  }

  Future<void> _handleFailedTune(Tune tune, int physicalIndex) async {
    _onUnavailable(tune);

    final effectiveIndex = _sequence.isShuffleEnabled
        ? _sequence.effectiveIndexOf(physicalIndex)
        : physicalIndex;

    if (_sequence.isShuffleEnabled && effectiveIndex != -1) {
      _sequence.removeAtEffective(effectiveIndex);
    }

    try {
      await _engine.removeAt(physicalIndex);
    } catch (e) {
      debugPrint('Failed to remove missing song from queue: $e');
    }

    await _advanceAfterFailure(physicalIndex, effectiveIndex);
  }

  Future<void> _advanceAfterFailure(
    int failedPhysicalIndex,
    int effectiveIndex,
  ) async {
    final sequence = _engine.sequenceState?.sequence;

    if (_sequence.isShuffleEnabled) {
      if (_sequence.isEmpty) {
        await _engine.stop();
        return;
      }
      int nextPhysical;
      if (effectiveIndex >= 0 && effectiveIndex < _sequence.length) {
        nextPhysical = _sequence.at(effectiveIndex)!;
      } else if (_engine.loopMode == LoopMode.all) {
        nextPhysical = _sequence.first;
      } else {
        await _engine.seek(Duration.zero);
        await _engine.pause();
        return;
      }
      await _engine.seekIndex(Duration.zero, nextPhysical);
    } else {
      if (sequence != null && failedPhysicalIndex < sequence.length) {
        await _engine.seekIndex(Duration.zero, failedPhysicalIndex);
      } else if (_engine.loopMode == LoopMode.all) {
        await _engine.seekIndex(Duration.zero, 0);
      } else {
        await _engine.seek(Duration.zero);
        await _engine.pause();
        return;
      }
    }

    _onAdvanced();
    unawaited(
      _engine.play().catchError((Object e) {
        debugPrint('Failed to resume after skipping missing song: $e');
      }),
    );
  }
}
