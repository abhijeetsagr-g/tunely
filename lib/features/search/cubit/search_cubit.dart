import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/library/model/library_scan_result.dart';
import 'package:tunely/features/search/model/recent_item.dart';
import 'package:tunely/features/search/model/search_result.dart';
import 'package:tunely/features/search/repository/search_repository.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  Timer? _debounce;
  LibraryScanResult? _library;
  final List<RecentItem> _recentItems = [];
  final SearchRepository _repository;

  SearchCubit(this._repository) : super(const SearchIdle());

  Future<void> setLibrary(LibraryScanResult library) async {
    _library = library;
    await _loadRecentItems();
    emit(SearchIdle(recentItems: List.of(_recentItems)));
  }

  Future<void> _loadRecentItems() async {
    final data = await _repository.loadRecentItems();
    final library = _library;
    if (library == null) return;

    for (final item in data) {
      final resolved = _resolveItem(item, library);
      if (resolved != null) {
        _recentItems.add(resolved);
      }
    }
  }

  RecentItem? _resolveItem(RecentItemData data, LibraryScanResult library) {
    return switch (data.type) {
      'song' => _resolveSong(data, library),
      'album' => _resolveAlbum(data, library),
      'artist' => _resolveArtist(data, library),
      _ => null,
    };
  }

  RecentSongItem? _resolveSong(RecentItemData data, LibraryScanResult library) {
    final tune = data.songId != null
        ? library.tunes.where((t) => t.songId == data.songId).firstOrNull
        : null;
    if (tune != null) return RecentSongItem(tune);
    return null;
  }

  RecentAlbumItem? _resolveAlbum(RecentItemData data, LibraryScanResult library) {
    final album = data.albumId != null
        ? library.albums.where((a) => a.id == data.albumId).firstOrNull
        : null;
    if (album != null) return RecentAlbumItem(album);
    return null;
  }

  RecentArtistItem? _resolveArtist(RecentItemData data, LibraryScanResult library) {
    final artist = data.artistId != null
        ? library.artists.where((a) => a.artistId == data.artistId).firstOrNull
        : null;
    if (artist != null) return RecentArtistItem(artist);
    return null;
  }

  void search(String query) {
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      emit(SearchIdle(recentItems: List.of(_recentItems)));
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () {
      _runSearch(query.trim().toLowerCase());
    });
  }

  void clear() {
    _debounce?.cancel();
    emit(SearchIdle(recentItems: List.of(_recentItems)));
  }

  void setFilter(FilterMode mode) {
    final current = state;
    if (current is SearchLoaded) {
      emit(SearchLoaded(
        query: current.query,
        result: current.result,
        filterMode: mode,
      ));
    }
  }

  void addRecentItem(RecentItem item) {
    _recentItems.removeWhere((existing) => existing.title == item.title);
    _recentItems.insert(0, item);
    if (_recentItems.length > 10) {
      _recentItems.removeLast();
    }
    _repository.saveRecentItems(_recentItems);
  }

  void clearRecentItems() {
    _recentItems.clear();
    _repository.clearRecentItems();
    emit(SearchIdle(recentItems: const []));
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
