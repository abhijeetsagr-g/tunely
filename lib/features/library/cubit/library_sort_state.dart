part of 'library_sort_cubit.dart';

class LibrarySortState {
  final AlbumSort albumSort;
  final TuneSortType tuneSortType;
  final ArtistSort artistSort;

  final bool albumSortAsc;
  final bool tuneSortAsc;
  final bool artistSortAsc;

  final bool albumHideSingles;
  final bool artistHideSingles;

  const LibrarySortState({
    this.albumSort = AlbumSort.songCount,
    this.tuneSortType = TuneSortType.name,
    this.artistSort = ArtistSort.name,
    this.albumSortAsc = true,
    this.tuneSortAsc = true,
    this.artistSortAsc = true,
    this.albumHideSingles = true,
    this.artistHideSingles = true,
  });

  LibrarySortState copyWith({
    AlbumSort? albumSort,
    TuneSortType? tuneSortType,
    ArtistSort? artistSort,
    bool? albumSortAsc,
    bool? tuneSortAsc,
    bool? artistSortAsc,
    bool? albumHideSingles,
    bool? artistHideSingles,
  }) {
    return LibrarySortState(
      albumSort: albumSort ?? this.albumSort,
      tuneSortType: tuneSortType ?? this.tuneSortType,
      artistSort: artistSort ?? this.artistSort,
      albumSortAsc: albumSortAsc ?? this.albumSortAsc,
      tuneSortAsc: tuneSortAsc ?? this.tuneSortAsc,
      artistSortAsc: artistSortAsc ?? this.artistSortAsc,
      albumHideSingles: albumHideSingles ?? this.albumHideSingles,
      artistHideSingles: artistHideSingles ?? this.artistHideSingles,
    );
  }
}
