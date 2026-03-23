import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/data/model/play_history.dart';
import 'package:tunely/data/model/tune.dart';
import 'package:tunely/data/repository/history_repository.dart';
import 'package:tunely/data/repository/tune_repository.dart';

part 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final HistoryRepository _historyRepo;
  final TuneRepository _tuneRepo;
  int _recordCount = 0;

  HistoryCubit(this._historyRepo, this._tuneRepo) : super(const HistoryState());

  Future<void> record(Tune tune) async {
    if (tune.songId == null) return;
    await _historyRepo.record(
      PlayHistory()
        ..songId = tune.songId!
        ..path = tune.path
        ..title = tune.title
        ..artist = tune.artist
        ..playedAt = DateTime.now(),
    );
    _recordCount++;
    if (_recordCount == 1 || _recordCount % 3 == 0) await load();
  }

  Future<void> load() async {
    final recent = await _historyRepo.recentlyPlayed(limit: 5);
    final top = await _historyRepo.topPlayed(limit: 5);

    emit(HistoryState(recentTunes: _resolve(recent), topTunes: _resolve(top)));
  }

  Future<void> clearAll() async {
    await _historyRepo.clearAll();
    _recordCount = 0;
    emit(const HistoryState());
  }

  List<Tune> _resolve(List<PlayHistory> history) {
    return history
        .map((h) => _tuneRepo.findByPath(h.path))
        .whereType<Tune>()
        .toList();
  }
}
