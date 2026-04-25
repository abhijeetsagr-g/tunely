import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/core/utlis/settings_arguments.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/shared/model/artist.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/album_card.dart';
import 'package:tunely/shared/widget/artist_card.dart';
import 'package:tunely/shared/widget/song_tile.dart';

part 'library_tabs.dart';

class LibraryView extends StatelessWidget {
  const LibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            title: Text(
              "Library",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            actions: [
              IconButton(
                onPressed: () {
                  // TODO: Navigate to Settings
                },
                icon: const Icon(Icons.settings),
              ),
            ],
            bottom: const TabBar(
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
          ),
          BlocBuilder<LibraryCubit, LibraryState>(
            builder: (context, state) {
              return switch (state) {
                LibraryLoading() => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                LibraryPermissionDenied() => const SliverFillRemaining(
                  child: Center(child: Text("Storage permission denied.")),
                ),
                LibraryError(:final message) => SliverFillRemaining(
                  child: Center(child: Text("Error: $message")),
                ),
                LibraryLoaded(
                  :final tunes,
                  :final albums,
                  :final artists,
                  :final genres,
                ) =>
                  SliverFillRemaining(
                    child: TabBarView(
                      children: [
                        _SongsTab(tunes: tunes),
                        _AlbumsTab(albums: albums),
                        _ArtistsTab(artists: artists),
                        _GenresTab(genres: genres),
                      ],
                    ),
                  ),
                _ => const SliverToBoxAdapter(child: SizedBox.shrink()),
              };
            },
          ),
        ],
      ),
    );
  }
}
