part of 'playlist_cubit.dart';

sealed class PlaylistState {}

class PlaylistsLoading extends PlaylistState {}

class PlaylistsLoaded extends PlaylistState {
  final List<Playlist> playlists;
  final PlaylistDetail detail;

  PlaylistsLoaded({
    required this.playlists,
    this.detail = const PlaylistDetail(),
  });
}

class PlaylistsError extends PlaylistState {
  final String message;
  PlaylistsError(this.message);
}
