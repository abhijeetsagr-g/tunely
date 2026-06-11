import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/search/cubit/search_cubit.dart';
import 'package:tunely/features/search/model/recent_item.dart';
import 'package:tunely/features/search/model/search_result.dart';
import 'package:tunely/features/search/view/widget/empty_hint.dart';
import 'package:tunely/features/search/view/widget/my_search_bar.dart';
import 'package:tunely/features/search/view/widget/search_section_header.dart';
import 'package:tunely/shared/widget/album_card.dart';
import 'package:tunely/shared/widget/album_tile.dart';
import 'package:tunely/shared/widget/artist_card.dart';
import 'package:tunely/shared/widget/song_tile.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        return CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            _buildAppBar(theme),

            if (state is SearchIdle)
              ..._buildRecentItems(state)
            else if (state is SearchLoaded && state.result.tunes.isEmpty && state.result.albums.isEmpty && state.result.artists.isEmpty)
              _buildEmptyState(
                icon: Icons.music_off_rounded,
                message: 'No results',
                sub: 'Nothing matched "${_controller.text}"',
              )
            else if (state is SearchLoaded) ...[
              _buildFilterChips(state),
              ..._buildSections(state.result, state.filterMode),
            ],
          ],
        );
      },
    );
  }

  Widget _buildAppBar(ThemeData theme) {
    return SliverAppBar(
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
                  onChanged: (q) => context.read<SearchCubit>().search(q),
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
    );
  }

  List<Widget> _buildRecentItems(SearchIdle state) {
    if (state.recentItems.isEmpty) {
      return [
        _buildEmptyState(
          icon: Icons.music_note,
          message: "Find Your Tune",
          sub: "What you looking for?",
        ),
      ];
    }

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 16, 8),
          child: Row(
            children: [
              Text(
                'Recent',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.read<SearchCubit>().clearRecentItems(),
                child: const Text('Clear all'),
              ),
            ],
          ),
        ),
      ),
      SliverList.builder(
        itemCount: state.recentItems.length,
        itemBuilder: (context, i) {
          final item = state.recentItems[i];
          return _buildRecentTile(item);
        },
      ),
    ];
  }

  Widget _buildRecentTile(RecentItem item) {
    final cubit = context.read<SearchCubit>();

    return switch (item) {
      RecentSongItem s => SongTile(
        tunes: [s.tune],
        index: 0,
        onTap: () => cubit.addRecentItem(s),
      ),
      RecentAlbumItem a => AlbumTile(
        album: a.album,
        onTap: () => cubit.addRecentItem(a),
      ),
      RecentArtistItem a => ArtistCard(
        artist: a.artist,
        onTap: () => cubit.addRecentItem(a),
      ),
    };
  }

  Widget _buildFilterChips(SearchLoaded state) {
    final cs = Theme.of(context).colorScheme;
    final chips = FilterMode.values;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: chips.map((mode) {
              final label = switch (mode) {
                FilterMode.all => 'All',
                FilterMode.songs => 'Songs',
                FilterMode.artists => 'Artists',
                FilterMode.albums => 'Albums',
              };
              final active = state.filterMode == mode;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(label),
                  selected: active,
                  onSelected: (_) {
                    final cubit = context.read<SearchCubit>();
                    if (active) {
                      cubit.setFilter(FilterMode.all);
                    } else {
                      cubit.setFilter(mode);
                    }
                  },
                  selectedColor: cs.primaryContainer,
                  checkmarkColor: cs.onPrimaryContainer,
                  labelStyle: TextStyle(
                    color: active ? cs.onPrimaryContainer : cs.onSurface,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 13,
                  ),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String sub,
  }) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: EmptyHint(icon: icon, message: message, sub: sub),
    );
  }

  List<Widget> _buildSections(SearchResult result, FilterMode filter) {

    return [
      if (filter == FilterMode.all || filter == FilterMode.songs)
        ..._buildSongs(result),
      if (filter == FilterMode.all || filter == FilterMode.albums)
        ..._buildAlbums(result),
      if (filter == FilterMode.all || filter == FilterMode.artists)
        ..._buildArtists(result),
    ];
  }

  List<Widget> _buildSongs(SearchResult result) {
    if (result.tunes.isEmpty) return [];

    final cubit = context.read<SearchCubit>();

    return [
      SearchSectionHeader(label: 'Songs', count: result.tunes.length),
      SliverList.builder(
        itemCount: result.tunes.length,
        itemBuilder: (context, i) => SongTile(
          index: i,
          tunes: result.tunes,
          onTap: () => cubit.addRecentItem(RecentSongItem(result.tunes[i])),
        ),
      ),
    ];
  }

  List<Widget> _buildAlbums(SearchResult result) {
    if (result.albums.isEmpty) return [];

    final cubit = context.read<SearchCubit>();

    return [
      SearchSectionHeader(label: 'Albums', count: result.albums.length),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        sliver: SliverGrid.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.78,
          ),
          itemCount: result.albums.length,
          itemBuilder: (context, i) => AlbumCard(
            album: result.albums[i],
            onTap: () => cubit.addRecentItem(RecentAlbumItem(result.albums[i])),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildArtists(SearchResult result) {
    if (result.artists.isEmpty) return [];

    final cubit = context.read<SearchCubit>();

    return [
      SearchSectionHeader(label: 'Artists', count: result.artists.length),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        sliver: SliverToBoxAdapter(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: result.artists
                .map((a) => ArtistCard(
                  artist: a,
                  onTap: () => cubit.addRecentItem(RecentArtistItem(a)),
                ))
                .toList(),
          ),
        ),
      ),
    ];
  }
}
