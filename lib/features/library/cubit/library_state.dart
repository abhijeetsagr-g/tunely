part of 'library_cubit.dart';

sealed class LibraryState {}

class LibraryInitial extends LibraryState {}

class LibraryLoading extends LibraryState {}

class LibraryLoaded extends LibraryState {
  final List<Tune> tunes;
  final List<Artist> artists;
  final List<AlbumModel> albums;
  final List<GenreModel> genres;
  final List<Tune> dailyMix;

  LibraryLoaded({
    required this.tunes,
    required this.artists,
    required this.albums,
    required this.genres,
    required this.dailyMix,
  });

  LibraryLoaded copyWith({
    List<Tune>? tunes,
    List<Artist>? artists,
    List<AlbumModel>? albums,
    List<GenreModel>? genres,
    List<Tune>? dailyMix,
  }) =>
      LibraryLoaded(
        tunes: tunes ?? this.tunes,
        artists: artists ?? this.artists,
        albums: albums ?? this.albums,
        genres: genres ?? this.genres,
        dailyMix: dailyMix ?? this.dailyMix,
      );
}

class LibraryError extends LibraryState {
  final String message;
  LibraryError(this.message);
}

class LibraryPermissionDenied extends LibraryState {}
