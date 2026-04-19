part of 'playlist_cubit.dart';

sealed class PlaylistState {
  const PlaylistState();
}

class PlaylistInitial extends PlaylistState {
  const PlaylistInitial();
}

class PlaylistLoading extends PlaylistState {
  const PlaylistLoading();
}

class PlaylistError extends PlaylistState {
  final String message;
  const PlaylistError(this.message);
}

class PlaylistLoaded extends PlaylistState {
  final List<PlaylistModel> playlists;
  final Map<int, List<Tune>> tunesCache;
  final bool loadingTunes;

  const PlaylistLoaded({
    required this.playlists,
    this.tunesCache = const {},
    this.loadingTunes = false,
  });

  PlaylistLoaded copyWith({
    List<PlaylistModel>? playlists,
    Map<int, List<Tune>>? tunesCache,
    bool? loadingTunes,
  }) => PlaylistLoaded(
    playlists: playlists ?? this.playlists,
    tunesCache: tunesCache ?? this.tunesCache,
    loadingTunes: loadingTunes ?? this.loadingTunes,
  );
}
