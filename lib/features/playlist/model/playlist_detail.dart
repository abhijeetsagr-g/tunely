import 'package:tunely/features/playlist/model/playlist.dart';
import 'package:tunely/shared/model/tune.dart';

class PlaylistDetail {
  final Playlist? playlist;
  final List<Tune> tunes;
  final bool isLoading;
  final String? error;

  const PlaylistDetail({
    this.playlist,
    this.tunes = const [],
    this.isLoading = false,
    this.error,
  });
}
