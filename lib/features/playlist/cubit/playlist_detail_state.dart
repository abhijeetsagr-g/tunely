part of 'playlist_detail_cubit.dart';

sealed class PlaylistDetailState {}

class PlaylistDetailInitial extends PlaylistDetailState {}

class PlaylistDetailLoading extends PlaylistDetailState {}

class PlaylistDetailLoaded extends PlaylistDetailState {
  final List<Tune> tunes;
  final SortType sortType;
  final SortOrder sortOrder;

  PlaylistDetailLoaded({
    required this.tunes,
    this.sortType = SortType.name,
    this.sortOrder = SortOrder.ascending,
  });

  List<Tune> get sortedTunes => sortTunes(tunes, sortType, sortOrder);

  PlaylistDetailLoaded copyWith({
    List<Tune>? tunes,
    SortType? sortType,
    SortOrder? sortOrder,
  }) =>
      PlaylistDetailLoaded(
        tunes: tunes ?? this.tunes,
        sortType: sortType ?? this.sortType,
        sortOrder: sortOrder ?? this.sortOrder,
      );
}

class PlaylistDetailError extends PlaylistDetailState {
  final String error;
  PlaylistDetailError({required this.error});
}
