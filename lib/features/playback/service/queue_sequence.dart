import 'dart:math';

import 'package:tunely/shared/model/tune.dart';

class QueueSequence {
  bool _shuffleEnabled = false;
  List<int> _shuffleIndices = [];

  bool get isShuffleEnabled => _shuffleEnabled;
  bool get isEmpty => _shuffleIndices.isEmpty;
  int get length => _shuffleIndices.length;
  int get first => _shuffleIndices.first;
  int get last => _shuffleIndices.last;

  void enable(int length, int currentPhysicalIndex) {
    _shuffleEnabled = true;
    _indicesFor(length, currentPhysicalIndex);
  }

  void disable(int length) {
    _shuffleEnabled = false;
    _shuffleIndices = List.generate(length, (i) => i);
  }

  /// Brings the index list in sync with the physical queue length.
  void sync(int length) {
    if (_shuffleIndices.length != length) {
      _shuffleIndices = List.generate(length, (i) => i);
      if (_shuffleEnabled) _shuffleIndices.shuffle(Random());
    }
  }

  void prime(int length, int currentPhysicalIndex) {
    _shuffleIndices = List.generate(length, (i) => i);
    if (_shuffleEnabled && _shuffleIndices.length > 1) {
      final current = _shuffleIndices.removeAt(currentPhysicalIndex);
      _shuffleIndices.shuffle(Random());
      _shuffleIndices.insert(0, current);
    }
  }

  List<Tune> effectiveQueue(List<Tune> physical) =>
      _shuffleIndices.map((i) => physical[i]).toList();

  int effectiveIndexOf(int physicalIndex) =>
      _shuffleIndices.indexOf(physicalIndex);

  int? at(int effectiveIndex) =>
      (effectiveIndex >= 0 && effectiveIndex < _shuffleIndices.length)
      ? _shuffleIndices[effectiveIndex]
      : null;

  int? nextPhysical(int currentEffective) =>
      currentEffective + 1 < _shuffleIndices.length
      ? _shuffleIndices[currentEffective + 1]
      : null;

  int? previousPhysical(int currentEffective) =>
      currentEffective > 0 ? _shuffleIndices[currentEffective - 1] : null;

  void add(int physicalIndex) => _shuffleIndices.add(physicalIndex);

  void addAtRandom(int physicalIndex) {
    _shuffleIndices.add(physicalIndex);
    final pos = Random().nextInt(_shuffleIndices.length);
    final item = _shuffleIndices.removeLast();
    _shuffleIndices.insert(pos, item);
  }

  void removeAtEffective(int effectiveIndex) {
    final physicalIndex = _shuffleIndices[effectiveIndex];
    _shuffleIndices.removeAt(effectiveIndex);
    for (int i = 0; i < _shuffleIndices.length; i++) {
      if (_shuffleIndices[i] > physicalIndex) _shuffleIndices[i]--;
    }
  }

  /// Reserves the physical slot for a new source inserted right after the
  /// currently playing one, keeping the effective order intact. Returns null
  /// when the current source is no longer part of the effective order.
  int? reserveInsertAfterCurrent(
    int currentPhysical, {
    required int physicalLength,
  }) {
    final effectiveCurrent = _shuffleIndices.indexOf(currentPhysical);
    if (effectiveCurrent == -1) return null;

    final insertEffective = effectiveCurrent + 1;
    if (insertEffective < _shuffleIndices.length) {
      final physicalTarget = _shuffleIndices[insertEffective];
      for (int i = 0; i < _shuffleIndices.length; i++) {
        if (_shuffleIndices[i] >= physicalTarget) _shuffleIndices[i]++;
      }
      _shuffleIndices.insert(insertEffective, physicalTarget);
      return physicalTarget;
    }

    final newIndex = physicalLength;
    _shuffleIndices.add(newIndex);
    return newIndex;
  }

  void move(int oldIndex, int newIndex) {
    final entry = _shuffleIndices.removeAt(oldIndex);
    _shuffleIndices.insert(newIndex, entry);
  }

  void _indicesFor(int length, int currentPhysicalIndex) {
    _shuffleIndices = List.generate(length, (i) => i);
    if (_shuffleIndices.length > 1) {
      final current = _shuffleIndices.removeAt(currentPhysicalIndex);
      _shuffleIndices.shuffle(Random());
      _shuffleIndices.insert(0, current);
    }
  }
}
