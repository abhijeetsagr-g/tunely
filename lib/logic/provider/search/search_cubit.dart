import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/data/repository/tune_repository.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final TuneRepository _repo;

  SearchCubit(this._repo) : super(SearchState());

  void search(String query) {
    if (query.trim().isEmpty) {
      emit(SearchState());
      return;
    }
    emit(
      SearchState(
        result: SearchResult(
          songs: _repo.searchTune(query),
          albums: _repo.searchAlbums(query),
          artists: _repo.searchArtists(query),
        ),
      ),
    );
  }

  void clear() => emit(SearchState());
}
