part of 'playlist_detail_cubit.dart';

sealed class PlaylistDetailState {}

class PlaylistDetailInitial extends PlaylistDetailState {}

class PlaylistDetailLoading extends PlaylistDetailState {}

class PlaylistDetailLoaded extends PlaylistDetailState {
  final List<Tune> tunes;

  PlaylistDetailLoaded({required this.tunes});

  PlaylistDetailLoaded copyWith({List<Tune>? tunes}) =>
      PlaylistDetailLoaded(tunes: tunes ?? this.tunes);
}

class PlaylistDetailError extends PlaylistDetailState {
  final String error;
  PlaylistDetailError({required this.error});
}
