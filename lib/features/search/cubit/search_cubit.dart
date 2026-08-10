import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/library/model/library_scan_result.dart';
import 'package:tunely/features/search/model/recent_item.dart';
import 'package:tunely/features/search/model/recent_item_data.dart';
import 'package:tunely/features/search/model/search_result.dart';
import 'package:tunely/features/search/repository/search_repository.dart';
import 'package:tunely/shared/model/artist.dart';
import 'package:tunely/shared/model/tune.dart';

part 'search_state.dart';
part 'tune_search_entry.dart';

class SearchCubit extends Cubit<SearchState> {
  Timer? _debounce;
  LibraryScanResult? _library;
  final List<RecentItem> _recentItems = [];
  final SearchRepository _repository;
  late final StreamSubscription _librarySub;

  SearchCubit(this._repository, LibraryCubit library)
    : super(const SearchIdle()) {
    final state = library.state;
    if (state is LibraryLoaded) _applyLibrary(state);
    _librarySub = library.stream.listen((state) {
      if (state is LibraryLoaded) _applyLibrary(state);
    });
  }

  void _applyLibrary(LibraryLoaded state) {
    _setLibrary(
      LibraryScanResult(
        tunes: state.tunes,
        artists: state.artists,
        albums: state.albums,
        genres: state.genres,
      ),
    );
  }

  Future<void> _setLibrary(LibraryScanResult library) async {
    _library = library;
    await _loadRecentItems();
    if (isClosed) return;
    emit(SearchIdle(recentItems: List.of(_recentItems)));
  }

  Future<void> _loadRecentItems() async {
    final data = await _repository.loadRecentItems();
    final library = _library;
    if (library == null) return;

    _recentItems.clear();
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

  RecentAlbumItem? _resolveAlbum(
    RecentItemData data,
    LibraryScanResult library,
  ) {
    final album = data.albumId != null
        ? library.albums.where((a) => a.id == data.albumId).firstOrNull
        : null;
    if (album != null) return RecentAlbumItem(album);
    return null;
  }

  RecentArtistItem? _resolveArtist(
    RecentItemData data,
    LibraryScanResult library,
  ) {
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
      emit(
        SearchLoaded(
          query: current.query,
          result: current.result,
          filterMode: mode,
        ),
      );
    }
  }

  void addRecentItem(RecentItem item) {
    _recentItems.removeWhere((existing) => existing.title == item.title);
    _recentItems.insert(0, item);
    if (_recentItems.length > 10) {
      _recentItems.removeLast();
    }
    _repository.saveRecentItems(_recentItems);
    if (state is SearchIdle) {
      emit(SearchIdle(recentItems: List.of(_recentItems)));
    }
  }

  void clearRecentItems() {
    _recentItems.clear();
    _repository.clearRecentItems();
    emit(SearchIdle(recentItems: const []));
  }

  List<TuneSearchEntry> _buildTuneIndex() =>
      _library!.tunes.map(TuneSearchEntry.new).toList();

  List<MapEntry<Artist, String>> _buildArtistIndex() => _library!.artists
      .map((a) => MapEntry(a, a.artist.toLowerCase()))
      .toList();

  List<MapEntry<AlbumModel, String>> _buildAlbumIndex() =>
      _library!.albums.map((a) => MapEntry(a, a.album.toLowerCase())).toList();

  int? _score(String hay, String q) {
    if (hay.isEmpty) return null;
    if (hay == q) return 100;
    if (hay.startsWith(q)) return 80;
    if (hay.contains(' $q')) return 60;
    if (hay.contains(q)) return 40;
    return null;
  }

  void _runSearch(String rawQ) {
    if (_library == null) return;

    tuneIndex ??= _buildTuneIndex();
    artistIndex ??= _buildArtistIndex();
    albumIndex ??= _buildAlbumIndex();

    final q = rawQ.toLowerCase().trim();
    if (q.isEmpty) {
      emit(
        SearchLoaded(
          query: q,
          result: SearchResult(tunes: [], artists: [], albums: []),
        ),
      );
      return;
    }

    final scoredTunes = <MapEntry<Tune, int>>[];
    for (final e in tuneIndex!) {
      final titleScore = _score(e.titleLc, q);
      final artistScore = _score(e.artistLc, q);
      final albumScore = _score(e.albumLc, q);
      final genreScore = _score(e.genreLc, q);

      int? best;
      if (titleScore != null) best = titleScore + 20; // title weighted highest
      if (artistScore != null && (best == null || artistScore > best)) {
        best = artistScore;
      }
      if (albumScore != null && (best == null || albumScore > best)) {
        best = albumScore;
      }
      if (genreScore != null) {
        final weighted = genreScore - 10; // genre weighted lowest
        if (best == null || weighted > best) best = weighted;
      }

      if (best != null) scoredTunes.add(MapEntry(e.tune, best));
    }
    scoredTunes.sort((a, b) => b.value.compareTo(a.value));
    final tunes = scoredTunes.map((e) => e.key).toList();

    final artists = artistIndex!
        .where((e) => e.value.contains(q))
        .map((e) => e.key)
        .toList();

    final albums = albumIndex!
        .where((e) => e.value.contains(q))
        .map((e) => e.key)
        .toList();

    emit(
      SearchLoaded(
        query: q,
        result: SearchResult(tunes: tunes, artists: artists, albums: albums),
      ),
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    _librarySub.cancel();
    return super.close();
  }
}
