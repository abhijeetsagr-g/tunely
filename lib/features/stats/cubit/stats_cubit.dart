import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/stats/repository/stats_repository.dart';
import 'package:tunely/features/stats/service/stats_service.dart';
import 'package:tunely/shared/model/tune.dart';

part 'stats_state.dart';

class StatsCubit extends Cubit<StatsState> {
  final StatsService service;
  late final StreamSubscription _sub;
  late final StreamSubscription _librarySub;
  StatsRepository get _repo => service.repo;

  List<Tune>? _currentTunes;

  StatsCubit(this.service, LibraryCubit library) : super(StatsInitial()) {
    debugPrint('[stats] StatsCubit constructed');
    final libraryState = library.state;
    debugPrint('[stats] library loaded at construct: ${libraryState is LibraryLoaded}');
    if (libraryState is LibraryLoaded) {
      load(libraryState.tunes);
    }
    _sub = service.repo.watch().listen((_) {
      debugPrint('[stats] box watch event fired');
      if (_currentTunes != null) {
        load(_currentTunes!);
      } else {
        debugPrint('[stats]   skipped: _currentTunes is null');
      }
    });
    _librarySub = library.stream.listen((state) {
      debugPrint('[stats] library stream event: $state');
      if (state is LibraryLoaded) load(state.tunes);
    });
  }

  void load(List<Tune> tunes) {
    _currentTunes = tunes;
    final mostPlayed = _mostPlayed(tunes);
    final recent = _recent(tunes);
    final liked = _liked(tunes);
    debugPrint(
      '[stats] load: tunes=${tunes.length} mostPlayed=${mostPlayed.length} '
      'recent=${recent.length} liked=${liked.length}',
    );
    for (final t in mostPlayed.take(5)) {
      debugPrint(
        '[stats]   top: "${t.title}" -> ${_repo.get(t.path).playCount} plays',
      );
    }
    emit(
      StatsLoaded(
        mostPlayed: mostPlayed,
        recent: recent,
        liked: liked,
      ),
    );
  }

  List<Tune> _mostPlayed(List<Tune> tunes) {
    final stats = {for (final t in tunes) t.path: _repo.get(t.path)};
    final played = tunes.where((t) => stats[t.path]!.playCount > 0).toList();
    played.sort(
      (a, b) => stats[b.path]!.playCount.compareTo(stats[a.path]!.playCount),
    );
    return played.take(50).toList();
  }

  List<Tune> _recent(List<Tune> tunes) {
    final tuneMap = {for (final t in tunes) t.path: t};
    final order = _repo.getRecentOrder();
    return order.map((path) => tuneMap[path]).whereType<Tune>().toList();
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

  void clearPlayCounts() {
    _repo.clearPlayCounts();
  }

  void clearLikes() {
    _repo.clearLikes();
  }

  void clearRecent() {
    _repo.clearRecentOrder();
  }

  @override
  Future<void> close() {
    _sub.cancel();
    _librarySub.cancel();
    return super.close();
  }
}
