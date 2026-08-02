part of 'playlist_bloc.dart';

sealed class PlaylistState {}

class PlaylistLoading extends PlaylistState {}

class LoadedPlaylist extends PlaylistState {
  final List<PlaylistModel> playlists;
  final PlaylistDetailState detail;
  LoadedPlaylist({
    required this.playlists,
    this.detail = const PlaylistDetailState(),
  });
}

class PlaylistError extends PlaylistState {
  final String error;
  PlaylistError({required this.error});
}

class PlaylistDetailState {
  final int? playlistId;
  final List<Tune> songs;
  final bool isLoading;
  final String? error;

  const PlaylistDetailState({
    this.playlistId,
    this.songs = const [],
    this.isLoading = false,
    this.error,
  });

  PlaylistDetailState copyWith({
    int? playlistId,
    List<Tune>? songs,
    bool? isLoading,
    String? error,
  }) => PlaylistDetailState(
    playlistId: playlistId ?? this.playlistId,
    songs: songs ?? this.songs,
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error,
  );
}
