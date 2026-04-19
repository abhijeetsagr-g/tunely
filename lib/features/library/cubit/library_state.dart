part of 'library_cubit.dart';

sealed class LibraryState {}

class LibraryInitial extends LibraryState {}

class LibraryLoading extends LibraryState {}

class LibraryLoaded extends LibraryState {
  final List<Tune> tunes;
  final List<Artist> artists;
  final List<AlbumModel> albums;
  final List<GenreModel> genres;
  final List<PlaylistModel> playlists;

  LibraryLoaded({
    required this.tunes,
    required this.artists,
    required this.albums,
    required this.genres,
    required this.playlists,
  });
}

class LibraryError extends LibraryState {
  final String message;
  LibraryError(this.message);
}

class LibraryPermissionDenied extends LibraryState {}
