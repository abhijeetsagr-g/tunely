import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/stats/repository/stats_repository.dart';
import 'package:tunely/shared/model/tune.dart';

part 'stats_state.dart';

class StatsCubit extends Cubit<StatsState> {
  final StatsRepository repo;
  late final StreamSubscription _sub;

  List<Tune>? _currentTunes;
  StatsCubit(this.repo) : super(StatsInitial()) {
    _sub = repo.watch().listen((_) {
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
    final sorted = [...tunes];

    sorted.sort((a, b) {
      final bCount = repo.get(b.path).playCount;
      final aCount = repo.get(a.path).playCount;
      return bCount.compareTo(aCount);
    });

    return sorted;
  }

  List<Tune> _recent(List<Tune> tunes) {
    final sorted = [...tunes];

    sorted.sort((a, b) {
      final bTime = repo.get(b.path).lastPlayed ?? DateTime(0);
      final aTime = repo.get(a.path).lastPlayed ?? DateTime(0);
      return bTime.compareTo(aTime);
    });

    return sorted;
  }

  List<Tune> _liked(List<Tune> tunes) {
    return tunes.where((t) => repo.get(t.path).isLiked).toList();
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
