import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:tunely/features/stats/repository/stats_repository.dart';

class StatsService {
  final StatsRepository repo;
  String? _lastPlayedId;

  StatsService(Stream<MediaItem> stream, this.repo) {
    stream.listen(_handlePlay);
  }

  void _handlePlay(MediaItem item) {
    if (item.id == _lastPlayedId) {
      debugPrint('[stats] duplicate track (skipping): "${item.title}"');
      return;
    }
    _lastPlayedId = item.id;

    final stats = repo.get(item.id);
    stats.playCount++;
    stats.lastPlayed = DateTime.now();
    repo.save(stats);
    debugPrint('[stats] recorded play: "${item.title}" id=${item.id} count=${stats.playCount}');

    final recent = repo.getRecentOrder();
    recent.remove(item.id);
    recent.insert(0, item.id);
    if (recent.length > 50) {
      recent.removeLast();
    }
    repo.saveRecentOrder(recent);
  }
}
