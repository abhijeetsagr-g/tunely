part of 'search_cubit.dart';

enum FilterMode { all, songs, artists, albums }

sealed class SearchState {
  const SearchState();
}

class SearchIdle extends SearchState {
  final List<RecentItem> recentItems;

  const SearchIdle({this.recentItems = const []});
}

class SearchLoaded extends SearchState {
  final String query;
  final SearchResult result;
  final FilterMode filterMode;

  const SearchLoaded({
    required this.query,
    required this.result,
    this.filterMode = FilterMode.all,
  });
}
