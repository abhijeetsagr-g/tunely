import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/core/utlis/sort_tunes.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/library/ui/view/albums/albums_tab.dart';
import 'package:tunely/features/library/ui/view/artists/artists_tab.dart';
import 'package:tunely/features/library/ui/view/genres/genres_tab.dart';
import 'package:tunely/features/library/ui/view/playlists/playlists_tab.dart';
import 'package:tunely/features/library/ui/view/songs/song_sort_bar.dart';
import 'package:tunely/features/library/ui/view/songs/songs_tab.dart';
import 'package:tunely/shared/model/artist.dart';
import 'package:tunely/shared/model/tune.dart';

class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  SortType _sortType = SortType.name;
  SortOrder _sortOrder = SortOrder.ascending;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (context, state) {
        return switch (state) {
          LibraryLoading() => const Center(child: CircularProgressIndicator()),
          LibraryPermissionDenied() => const Center(
            child: Text("Storage permission denied."),
          ),
          LibraryError(:final message) => Center(
            child: Text("Error: $message"),
          ),
          LibraryLoaded(
            :final tunes,
            :final albums,
            :final artists,
            :final genres,
          ) =>
            _buildContent(tunes, albums, artists, genres),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }

  Widget _buildContent(
    List<Tune> tunes,
    List<AlbumModel> albums,
    List<Artist> artists,
    List<GenreModel> genres,
  ) {
    return DefaultTabController(
      length: 5,
      child: Builder(
        builder: (context) {
          return ListenableBuilder(
            listenable: DefaultTabController.of(context),
            builder: (context, _) {
              final tabIndex = DefaultTabController.of(context).index;
              final sortTypes = switch (tabIndex) {
                0 => SortType.values,
                1 => [SortType.name, SortType.songCount, SortType.duration],
                2 => [SortType.name, SortType.songCount, SortType.duration],
                _ => [SortType.name],
              };

              return NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverOverlapAbsorber(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                      context,
                    ),
                    sliver: SliverAppBar(
                      backgroundColor: Theme.of(
                        context,
                      ).scaffoldBackgroundColor,
                      floating: true,
                      pinned: true,
                      title: Text(
                        "Library",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      actions: [
                        IconButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoute.settings);
                          },
                          icon: const Icon(Icons.settings),
                        ),
                      ],
                      bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(110),
                        child: Column(
                          children: [
                            const TabBar(
                              isScrollable: true,
                              tabAlignment: TabAlignment.start,
                              tabs: [
                                Tab(text: "Songs"),
                                Tab(text: "Albums"),
                                Tab(text: "Artists"),
                                Tab(text: "Genres"),
                                Tab(text: "Playlists"),
                              ],
                            ),
                            SongSortBar(
                              types: sortTypes,
                              sortType: _sortType,
                              sortOrder: _sortOrder,
                              onSortTypeChanged: (type) =>
                                  setState(() => _sortType = type),
                              onSortOrderToggled: () => setState(() {
                                _sortOrder = _sortOrder == SortOrder.ascending
                                    ? SortOrder.descending
                                    : SortOrder.ascending;
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                body: TabBarView(
                  children: [
                    SongsTab(
                      tunes: tunes,
                      sortType: _sortType,
                      sortOrder: _sortOrder,
                    ),
                    AlbumsTab(
                      albums: albums,
                      sortType: _sortType,
                      sortOrder: _sortOrder,
                    ),
                    ArtistsTab(
                      artists: artists,
                      sortType: _sortType,
                      sortOrder: _sortOrder,
                    ),
                    GenresTab(genres: genres),
                    const PlaylistsTab(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
