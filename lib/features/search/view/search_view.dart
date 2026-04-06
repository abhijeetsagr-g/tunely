import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/mini_player/mini_player_state.dart';
import 'package:tunely/features/search/cubit/search_cubit.dart';
import 'package:tunely/features/search/cubit/search_state.dart';
import 'package:tunely/features/search/view/widget/empty_hint.dart';
import 'package:tunely/features/search/view/widget/search_bar.dart';
import 'package:tunely/features/search/view/widget/search_section_header.dart';
import 'package:tunely/shared/widgets/artist_chip.dart';
import 'package:tunely/shared/widgets/song_tile.dart';
import 'package:tunely/shared/widgets/album_box.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  bool _songsExpanded = true;
  bool _albumsExpanded = true;
  bool _artistsExpanded = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        final hasQuery = state.result != null;
        final isEmpty =
            hasQuery &&
            state.result!.songs.isEmpty &&
            state.result!.albums.isEmpty &&
            state.result!.artists.isEmpty;

        return CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            // ── App bar with large title + search ────────────────────────
            SliverAppBar(
              floating: true,
              snap: true,
              expandedHeight: 120,
              toolbarHeight: 0,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Search',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        MySearchBar(
                          controller: _controller,
                          focusNode: _focusNode,
                          onChanged: (q) =>
                              context.read<SearchCubit>().search(q),
                          onClear: () {
                            _controller.clear();
                            context.read<SearchCubit>().clear();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Idle state ───────────────────────────────────────────────
            if (!hasQuery)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyHint(
                  icon: Icons.search_rounded,
                  message: 'Songs, albums, artists',
                  sub: 'Start typing to search your library',
                ),
              )
            // ── No results ───────────────────────────────────────────────
            else if (isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyHint(
                  icon: Icons.music_off_rounded,
                  message: 'No results',
                  sub: 'Nothing matched "${_controller.text}"',
                ),
              )
            // ── Results ──────────────────────────────────────────────────
            else ...[
              if (state.result!.songs.isNotEmpty) ...[
                SearchSectionHeader(
                  label: 'Songs',
                  count: state.result!.songs.length,
                  expanded: _songsExpanded,
                  onToggle: () =>
                      setState(() => _songsExpanded = !_songsExpanded),
                ),
                if (_songsExpanded)
                  SliverList.builder(
                    itemCount: state.result!.songs.length,
                    itemBuilder: (context, i) => SongTile(
                      tune: state.result!.songs[i],
                      index: i,
                      tunes: state.result!.songs,
                    ),
                  ),
              ],

              if (state.result!.albums.isNotEmpty) ...[
                SearchSectionHeader(
                  label: 'Albums',
                  count: state.result!.albums.length,
                  expanded: _albumsExpanded,
                  onToggle: () =>
                      setState(() => _albumsExpanded = !_albumsExpanded),
                ),
                if (_albumsExpanded)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    sliver: SliverGrid.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.78,
                          ),
                      itemCount: state.result!.albums.length,
                      itemBuilder: (context, i) =>
                          AlbumBox(album: state.result!.albums[i]),
                    ),
                  ),
              ],

              if (state.result!.artists.isNotEmpty) ...[
                SearchSectionHeader(
                  label: 'Artists',
                  count: state.result!.artists.length,
                  expanded: _artistsExpanded,
                  onToggle: () =>
                      setState(() => _artistsExpanded = !_artistsExpanded),
                ),
                if (_artistsExpanded)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    sliver: SliverToBoxAdapter(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: state.result!.artists
                            .map((a) => ArtistChip(artistName: a))
                            .toList(),
                      ),
                    ),
                  ),
              ],

              ValueListenableBuilder<bool>(
                valueListenable: miniPlayerVisible,
                builder: (_, visible, _) => SliverToBoxAdapter(
                  child: SizedBox(height: visible ? 100 : 32),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
