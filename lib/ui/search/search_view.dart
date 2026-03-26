import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/common/mini_player_state.dart';
import 'package:tunely/logic/provider/search/search_cubit.dart';
import 'package:tunely/logic/provider/search/search_state.dart';
import 'package:tunely/ui/common/artist_chip.dart';

import 'package:tunely/ui/common/song_tile.dart';
import 'package:tunely/ui/common/album_box.dart';

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
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        return CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              titleSpacing: 0,
              toolbarHeight: 72,
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: (q) => context.read<SearchCubit>().search(q),
                  decoration: InputDecoration(
                    hintText: 'Songs, albums, artists...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: ListenableBuilder(
                      listenable: _controller,
                      builder: (_, __) => _controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _controller.clear();
                                context.read<SearchCubit>().clear();
                              },
                            )
                          : const SizedBox.shrink(),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Idle
            if (state.result == null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search,
                        size: 64,
                        color: colorScheme.onSurface.withOpacity(0.2),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Search your library',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            // No results
            else if (state.result!.songs.isEmpty &&
                state.result!.albums.isEmpty &&
                state.result!.artists.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.music_off,
                        size: 64,
                        color: colorScheme.onSurface.withOpacity(0.2),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No results for "${_controller.text}"',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            // Results
            else ...[
              if (state.result!.songs.isNotEmpty) ...[
                _SectionHeader(
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
                _SectionHeader(
                  label: 'Albums',
                  count: state.result!.albums.length,
                  expanded: _albumsExpanded,
                  onToggle: () =>
                      setState(() => _albumsExpanded = !_albumsExpanded),
                ),
                if (_albumsExpanded)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    sliver: SliverGrid.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.78,
                          ),
                      itemCount: state.result!.albums.length,
                      itemBuilder: (context, i) =>
                          AlbumBox(album: state.result!.albums[i]),
                    ),
                  ),
              ],

              if (state.result!.artists.isNotEmpty) ...[
                _SectionHeader(
                  label: 'Artists',
                  count: state.result!.artists.length,
                  expanded: _artistsExpanded,
                  onToggle: () =>
                      setState(() => _artistsExpanded = !_artistsExpanded),
                ),
                if (_artistsExpanded)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 12,
                        children: state.result!.artists
                            .map(
                              (a) => ArtistChip(artistName: a.artist, id: a.id),
                            )
                            .toList(),
                      ),
                    ),
                  ),
              ],

              ValueListenableBuilder<bool>(
                valueListenable: miniPlayerVisible,
                builder: (_, visible, __) => SliverToBoxAdapter(
                  child: SizedBox(height: visible ? 100 : 24),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.count,
    required this.expanded,
    required this.onToggle,
  });

  final String label;
  final int count;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverToBoxAdapter(
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 12, 8),
          child: Row(
            children: [
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$count',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.45),
                ),
              ),
              const Spacer(),
              AnimatedRotation(
                turns: expanded ? 0 : -0.25,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.keyboard_arrow_down),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
