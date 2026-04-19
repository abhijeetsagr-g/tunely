import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/stats/repository/stats_repository.dart';
import 'package:tunely/features/stats/service/stats_service.dart';
import 'package:tunely/shared/model/tune.dart';

part 'stats_state.dart';

class StatsCubit extends Cubit<StatsState> {
  final StatsService service;
  late final StreamSubscription _sub;
  StatsRepository get _repo => service.repo;

  List<Tune>? _currentTunes;

  StatsCubit(this.service) : super(StatsInitial()) {
    _sub = service.repo.watch().listen((_) {
      if (_currentTunes != null) {
        load(_currentTunes!);
      }
    });
  }

  void load(List<Tune> tunes) {
    _currentTunes = tunes;
    emit(
      StatsLoaded(
        mostPlayed: _mostPlayed(tunes),
        recent: _recent(tunes),
        liked: _liked(tunes),
      ),
    );
  }

  List<Tune> _mostPlayed(List<Tune> tunes) {
    final stats = {for (final t in tunes) t.path: _repo.get(t.path)};
    final played = tunes.where((t) => stats[t.path]!.playCount > 0).toList();
    played.sort(
      (a, b) => stats[b.path]!.playCount.compareTo(stats[a.path]!.playCount),
    );
    return played;
  }

  List<Tune> _recent(List<Tune> tunes) {
    final stats = {for (final t in tunes) t.path: _repo.get(t.path)};
    final played = tunes
        .where((t) => stats[t.path]!.lastPlayed != null)
        .toList();
    played.sort(
      (a, b) =>
          stats[b.path]!.lastPlayed!.compareTo(stats[a.path]!.lastPlayed!),
    );
    return played;
  }

  List<Tune> _liked(List<Tune> tunes) {
    final stats = {for (final t in tunes) t.path: _repo.get(t.path)};
    return tunes.where((t) => stats[t.path]!.isLiked).toList();
  }

  void toggleLike(String path) {
    _repo.toggleLike(path);
  }

  bool isLiked(String path) => _repo.get(path).isLiked;
  int playCount(String path) => _repo.get(path).playCount;

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
