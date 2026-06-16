part of 'playlist_cubit.dart';

sealed class PlaylistState {}

class PlaylistLoading extends PlaylistState {}

class LoadedPlaylist extends PlaylistState {
  final List<PlaylistModel> playlists;
  LoadedPlaylist({required this.playlists});
}

class PlaylistError extends PlaylistState {
  final String error;
  PlaylistError({required this.error});
}
