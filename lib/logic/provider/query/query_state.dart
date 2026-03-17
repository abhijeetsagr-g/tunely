import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/data/model/tune.dart';

class QueryState {
  final List<SongModel> filteredSongs;

  final bool isLoading;
  final String errorMessage;
  SearchResult? searchResult;

  QueryState({
    required this.filteredSongs,
    required this.isLoading,
    required this.errorMessage,
    this.searchResult,
  });

  QueryState copyWith({
    List<SongModel>? filteredSongs,
    bool? isLoading,
    String? errorMessage,
    SearchResult? searchResult,
  }) => QueryState(
    filteredSongs: filteredSongs ?? this.filteredSongs,
    isLoading: isLoading ?? this.isLoading,
    errorMessage: errorMessage ?? this.errorMessage,
    searchResult: searchResult ?? this.searchResult,
  );
}

class SearchResult {
  final List<Tune> songs;
  final List<AlbumModel> albums;
  final List<ArtistModel> artists;

  SearchResult({
    required this.songs,
    required this.albums,
    required this.artists,
  });
}
