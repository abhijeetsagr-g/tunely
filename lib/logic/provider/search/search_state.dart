import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/data/model/tune.dart';

class SearchState {
  final SearchResult? result;

  SearchState({this.result});

  SearchState copyWith({SearchResult? result}) =>
      SearchState(result: result ?? this.result);
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
