import 'package:tunely/shared/model/tune.dart';

sealed class LyricsBatchState {
  const LyricsBatchState();
}

class LyricsBatchIdle extends LyricsBatchState {
  const LyricsBatchIdle();
}

class LyricsBatchProgress extends LyricsBatchState {
  final Tune currentTune;
  final int total;
  final int completed;
  final int skipped;
  final int notFound;

  const LyricsBatchProgress({
    required this.currentTune,
    required this.total,
    required this.completed,
    this.skipped = 0,
    this.notFound = 0,
  });

  double get progress => total > 0 ? completed / total : 0;
  int get remaining => total - completed;
}

class LyricsBatchDone extends LyricsBatchState {
  final int total;
  final int found;
  final int notFound;
  final int skipped;

  const LyricsBatchDone({
    required this.total,
    required this.found,
    required this.notFound,
    required this.skipped,
  });
}
