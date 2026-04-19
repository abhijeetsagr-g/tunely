import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/library/model/library_scan_result.dart';
import 'package:tunely/features/search/model/search_result.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  Timer? _debounce;
  LibraryScanResult? _library;

  SearchCubit() : super(const SearchIdle());

  void setLibrary(LibraryScanResult library) {
    _library = library;
  }

  void search(String query) {
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      emit(const SearchIdle());
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () {
      _runSearch(query.trim().toLowerCase());
    });
  }

  void clear() {
    _debounce?.cancel();
    emit(const SearchIdle());
  }

  void _runSearch(String q) {
    if (_library == null) return;

    final tunes = _library!.tunes
        .where(
          (t) =>
              t.title.toLowerCase().contains(q) ||
              t.artist.toLowerCase().contains(q) ||
              t.album.toLowerCase().contains(q) ||
              t.genre.toLowerCase().contains(q),
        )
        .toList();

    final artists = _library!.artists
        .where((a) => a.artist.toLowerCase().contains(q))
        .toList();

    final albums = _library!.albums
        .where((a) => (a.album).toLowerCase().contains(q))
        .toList();

    final genres = _library!.genres
        .where((g) => (g.genre).toLowerCase().contains(q))
        .toList();

    final playlists = _library!.playlists
        .where((p) => (p.playlist).toLowerCase().contains(q))
        .toList();

    emit(
      SearchLoaded(
        query: q,
        result: SearchResult(
          tunes: tunes,
          artists: artists,
          albums: albums,
          genres: genres,
          playlists: playlists,
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
