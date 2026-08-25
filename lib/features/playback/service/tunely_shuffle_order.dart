import 'package:just_audio/just_audio.dart';

/// [DefaultShuffleOrder] inserts new items at random positions, which is
/// correct for "add to queue" but cannot express deterministic operations
/// like "play next" or drag-to-reorder in the shuffled view.
///
/// This subclass keeps the default behaviour but lets callers pin the
/// effective position used by the next single-item [insert] performed by
/// just_audio's player primitives (addAudioSource, moveAudioSource, ...).
class TunelyShuffleOrder extends DefaultShuffleOrder {
  int? _pinnedPosition;

  TunelyShuffleOrder();

  /// Pins the effective position of the next single-item insert. The value
  /// is clamped when consumed, so positions past the end append.
  void pinNextInsert(int effectivePosition) {
    _pinnedPosition = effectivePosition < 0 ? 0 : effectivePosition;
  }

  void cancelPin() => _pinnedPosition = null;

  @override
  void insert(int index, int count) {
    if (count != 1 || _pinnedPosition == null) {
      return super.insert(index, count);
    }

    for (var i = 0; i < indices.length; i++) {
      if (indices[i] >= index) indices[i]++;
    }

    final pos = _pinnedPosition!.clamp(0, indices.length);
    _pinnedPosition = null;
    indices.insert(pos, index);
  }
}
