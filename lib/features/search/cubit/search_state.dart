part of 'search_cubit.dart';

sealed class SearchState {
  const SearchState();
}

class SearchIdle extends SearchState {
  const SearchIdle();
}

class SearchLoaded extends SearchState {
  final String query;
  final SearchResult result;

  const SearchLoaded({required this.query, required this.result});
}
