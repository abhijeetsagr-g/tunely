import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/lyrics/cubit/lyrics_batch_state.dart';
import 'package:tunely/features/lyrics/service/lyrics_service.dart';
import 'package:tunely/shared/model/tune.dart';

class LyricsBatchCubit extends Cubit<LyricsBatchState> {
  final LyricsService _service;

  bool _cancelled = false;
  bool _skipRequested = false;

  LyricsBatchCubit(this._service) : super(const LyricsBatchIdle());

  Future<void> start(List<Tune> tunes) async {
    if (state is! LyricsBatchIdle) return;

    _cancelled = false;

    final pending =
        tunes.where((t) => !_service.hasLyrics(t)).toList(growable: false);
    final total = pending.length;

    if (total == 0) {
      emit(const LyricsBatchDone(total: 0, found: 0, notFound: 0, skipped: 0));
      return;
    }

    int completed = 0;
    int skipped = 0;
    int notFound = 0;

    for (final tune in pending) {
      if (_cancelled) break;

      _skipRequested = false;
      emit(
        LyricsBatchProgress(
          currentTune: tune,
          total: total,
          completed: completed,
          skipped: skipped,
          notFound: notFound,
        ),
      );

      try {
        final result = await _service.fetchLyrics(tune);
        if (result == null) {
          notFound++;
        }
      } catch (_) {
        notFound++;
      }

      completed++;

      if (_skipRequested && !_cancelled) {
        skipped++;
      }

      if (!_cancelled) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
    }

    emit(
      LyricsBatchDone(
        total: total,
        found: completed - notFound - skipped,
        notFound: notFound,
        skipped: skipped,
      ),
    );
  }

  void skipCurrent() => _skipRequested = true;

  void cancel() => _cancelled = true;

  void reset() => emit(const LyricsBatchIdle());
}
