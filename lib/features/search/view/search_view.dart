import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/search/cubit/search_cubit.dart';
import 'package:tunely/features/search/model/search_result.dart';
import 'package:tunely/features/search/view/widget/empty_hint.dart';
import 'package:tunely/features/search/view/widget/my_search_bar.dart';
import 'package:tunely/features/search/view/widget/search_section_header.dart';
import 'package:tunely/shared/widget/album_card.dart';
import 'package:tunely/shared/widget/artist_card.dart';
import 'package:tunely/shared/widget/song_tile.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _controller = TextEditingController();

  bool _songsExpanded = true;
  bool _albumsExpanded = true;
  bool _artistsExpanded = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          final isLoaded = state is SearchLoaded;
          final result = isLoaded ? state.result : null;

          final isEmpty =
              isLoaded &&
              result!.tunes.isEmpty &&
              result.albums.isEmpty &&
              result.artists.isEmpty;

          return CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              _buildAppBar(theme),

              if (!isLoaded)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text("Find Your Tune")),
                )
              else if (isEmpty)
                _buildEmptyState(
                  icon: Icons.music_off_rounded,
                  message: 'No results',
                  sub: 'Nothing matched "${_controller.text}"',
                )
              else ...[
                ..._buildSongs(result!),
                ..._buildAlbums(result),
                ..._buildArtists(result),
              ],
            ],
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────

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

  // ─────────────────────────────────────────────

  List<Widget> _buildSongs(SearchResult result) {
    if (result.tunes.isEmpty) return [];

    return [
      SearchSectionHeader(
        label: 'Songs',
        count: result.tunes.length,
        expanded: _songsExpanded,
        onToggle: () => setState(() => _songsExpanded = !_songsExpanded),
      ),
      if (_songsExpanded)
        SliverList.builder(
          itemCount: result.tunes.length,
          itemBuilder: (context, i) => SongTile(index: i, tunes: result.tunes),
        ),
    ];
  }

  List<Widget> _buildAlbums(SearchResult result) {
    if (result.albums.isEmpty) return [];

    return [
      SearchSectionHeader(
        label: 'Albums',
        count: result.albums.length,
        expanded: _albumsExpanded,
        onToggle: () => setState(() => _albumsExpanded = !_albumsExpanded),
      ),
      if (_albumsExpanded)
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
            itemBuilder: (context, i) => AlbumCard(album: result.albums[i]),
          ),
        ),
    ];
  }

  List<Widget> _buildArtists(SearchResult result) {
    if (result.artists.isEmpty) return [];

    return [
      SearchSectionHeader(
        label: 'Artists',
        count: result.artists.length,
        expanded: _artistsExpanded,
        onToggle: () => setState(() => _artistsExpanded = !_artistsExpanded),
      ),
      if (_artistsExpanded)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: result.artists
                  .map((a) => ArtistCard(artist: a))
                  .toList(),
            ),
          ),
        ),
    ];
  }
}
