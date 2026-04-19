part of 'root_cubit.dart';

enum RootPage { home, library, settings }

enum LibraryFilter { songs, artists, albums, genres }

class RootState {
  final List<RootPage> pages;
  final RootPage currentPage;
  final LibraryFilter libraryFilter;

  const RootState({
    this.pages = const [RootPage.home, RootPage.library, RootPage.settings],
    this.currentPage = RootPage.home,
    this.libraryFilter = LibraryFilter.songs,
  });

  int get currentIndex => pages.indexOf(currentPage);

  RootState copyWith({
    List<RootPage>? pages,
    RootPage? currentPage,
    LibraryFilter? libraryFilter,
  }) {
    return RootState(
      pages: pages ?? this.pages,
      currentPage: currentPage ?? this.currentPage,
      libraryFilter: libraryFilter ?? this.libraryFilter,
    );
  }
}
