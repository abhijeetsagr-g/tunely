import 'package:on_audio_query/on_audio_query.dart';

class QueryState {
  final List<AlbumModel> albums;
  final List<ArtistModel> artists;
  final List<GenreModel> genres;
  final List<PlaylistModel> playlists;
  final List<SongModel> filteredSongs;

  final bool isLoading;

  QueryState({
    required this.albums,
    required this.artists,
    required this.genres,
    required this.playlists,
    required this.filteredSongs,
    required this.isLoading,
  });

  QueryState copyWith({
    List<AlbumModel>? albums,
    List<ArtistModel>? artists,
    List<GenreModel>? genres,
    List<PlaylistModel>? playlists,
    List<SongModel>? filteredSongs,
    bool? isLoading,
  }) => QueryState(
    albums: albums ?? this.albums,
    artists: artists ?? this.artists,
    genres: genres ?? this.genres,
    playlists: playlists ?? this.playlists,
    filteredSongs: filteredSongs ?? this.filteredSongs,
    isLoading: isLoading ?? this.isLoading,
  );
}
