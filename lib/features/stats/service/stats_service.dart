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
    debugPrint("TUNELY: ${item.title}");

    if (item.id == _lastPlayedId) return;
    _lastPlayedId = item.id;

    final stats = repo.get(item.id);
    stats.playCount++;
    stats.lastPlayed = DateTime.now();
    repo.save(stats);
  }
}
