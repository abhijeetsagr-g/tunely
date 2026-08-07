import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/core/utlis/sort.dart';
import 'package:tunely/core/utlis/total_dur.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/library/ui/widget/all_songs/all_songs_tab.dart';
import 'package:tunely/features/library/ui/widget/albums/albums_tab.dart';
import 'package:tunely/features/library/ui/widget/artists/artists_tab.dart';
import 'package:tunely/features/library/ui/widget/playlists/playlists_tab.dart';
import 'package:tunely/features/library/ui/widget/section_card.dart';
import 'package:tunely/features/playback/view/mini_player/mini_player_state.dart';
import 'package:tunely/shared/model/artist.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/action_button.dart';

class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView>
    with AutomaticKeepAliveClientMixin {
  int _selectedIndex = 0;
  TuneSortType _tuneSortType = TuneSortType.name;
  bool _tuneSortAscending = true;
  AlbumSort _albumSortType = AlbumSort.songCount;
  bool _albumSortAscending = true;
  bool _albumHideSingles = true;
  ArtistSort _artistSortType = ArtistSort.name;
  bool _artistSortAscending = true;
  bool _artistHideSingles = true;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Library',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoute.settings);
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<LibraryCubit, LibraryState>(
          builder: (context, state) {
            return switch (state) {
              LibraryLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              LibraryPermissionDenied() => const Center(
                child: Text("Storage permission denied."),
              ),
              LibraryError(:final message) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          "Error: $message",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      ActionButton(
                        icon: Icons.cached_rounded,
                        label: 'Rescan',
                        onTap: () {
                          context.read<LibraryCubit>().rescan();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              LibraryLoaded(:final tunes, :final albums, :final artists) =>
                _buildContent(tunes, albums, artists),
              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    List<Tune> tunes,
    List<AlbumModel> albums,
    List<Artist> artists,
  ) {
    return Column(
      children: [
        Expanded(
          child: switch (_selectedIndex) {
            0 => AllSongsTab(
              tunes: tunes,
              sortType: _tuneSortType,
              ascending: _tuneSortAscending,
              onSortChanged: (type) => setState(() => _tuneSortType = type),
              onDirectionChanged: (ascending) =>
                  setState(() => _tuneSortAscending = ascending),
            ),
            1 => AlbumsTab(
              albums: albums,
              durations: totalDurationBy(tunes, (tune) => tune.albumId),
              sortType: _albumSortType,
              ascending: _albumSortAscending,
              onSortChanged: (type) => setState(() => _albumSortType = type),
              onDirectionChanged: (ascending) =>
                  setState(() => _albumSortAscending = ascending),
              hideSingles: _albumHideSingles,
              onHideSinglesChanged: (hide) =>
                  setState(() => _albumHideSingles = hide),
            ),
            2 => ArtistsTab(
              artists: artists,
              sortType: _artistSortType,
              ascending: _artistSortAscending,
              onSortChanged: (type) => setState(() => _artistSortType = type),
              onDirectionChanged: (ascending) =>
                  setState(() => _artistSortAscending = ascending),
              hideSingles: _artistHideSingles,
              onHideSinglesChanged: (hide) =>
                  setState(() => _artistHideSingles = hide),
            ),
            _ => const PlaylistsTab(),
          },
        ),
        ValueListenableBuilder<double>(
          valueListenable: miniPlayerHeight,
          builder: (context, height, _) {
            return Padding(
              padding: EdgeInsets.only(
                top: 8,
                left: 16,
                right: 16,
                bottom: height + 12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SectionCard(
                      text: 'All Songs',
                      icon: Icons.music_note_rounded,
                      selected: _selectedIndex == 0,
                      onSelect: () => setState(() => _selectedIndex = 0),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SectionCard(
                      text: 'Albums',
                      icon: Icons.album_rounded,
                      selected: _selectedIndex == 1,
                      onSelect: () => setState(() => _selectedIndex = 1),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SectionCard(
                      text: 'Artists',
                      icon: Icons.person_rounded,
                      selected: _selectedIndex == 2,
                      onSelect: () => setState(() => _selectedIndex = 2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SectionCard(
                      text: 'Playlists',
                      icon: Icons.queue_music_rounded,
                      selected: _selectedIndex == 3,
                      onSelect: () => setState(() => _selectedIndex = 3),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
