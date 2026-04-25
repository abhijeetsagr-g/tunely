part of 'playlist_cubit.dart';

class PlaylistState {}

class LoadedPlaylist extends PlaylistState {
  final List<PlaylistModel> playlists;
  LoadedPlaylist({required this.playlists});
}

class ErrorPlaylist extends PlaylistState {
  final List<PlaylistModel> playlists;
  final String error;

  ErrorPlaylist({required this.playlists, required this.error});
}
