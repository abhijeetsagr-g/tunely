import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/search/cubit/search_cubit.dart';
import 'package:tunely/features/search/model/recent_item.dart';
import 'package:tunely/features/search/widget/search_app_bar.dart';
import 'package:tunely/features/search/widget/search_empty_state.dart';
import 'package:tunely/features/search/widget/search_filter_chips.dart';
import 'package:tunely/features/search/widget/search_recent_section.dart';
import 'package:tunely/features/search/widget/search_result_sections.dart';

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
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        return CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SearchAppBar(
              controller: _controller,
              onChanged: (q) => context.read<SearchCubit>().search(q),
              onClear: () {
                _controller.clear();
                context.read<SearchCubit>().clear();
              },
            ),
            ..._buildBody(context, state),
          ],
        );
      },
    );
  }

  List<Widget> _buildBody(BuildContext context, SearchState state) {
    final cubit = context.read<SearchCubit>();

    return switch (state) {
      SearchIdle(:final recentItems) =>
        recentItems.isEmpty
            ? const [
                SearchEmptyState(
                  icon: Icons.music_note,
                  message: 'Find Your Tune',
                  sub: 'What you looking for?',
                ),
              ]
            : [
                SearchRecentSection(
                  items: recentItems,
                  onTapItem: cubit.addRecentItem,
                  onClearAll: cubit.clearRecentItems,
                ),
              ],
      SearchLoaded(:final result)
          when result.tunes.isEmpty &&
              result.albums.isEmpty &&
              result.artists.isEmpty =>
        [
          SearchEmptyState(
            icon: Icons.music_off_rounded,
            message: 'No results',
            sub: 'Nothing matched "${_controller.text}"',
          ),
        ],
      SearchLoaded(:final result, :final filterMode) => [
        SearchFilterChips(active: filterMode, onSelect: cubit.setFilter),
        if (filterMode == FilterMode.all || filterMode == FilterMode.songs)
          if (result.tunes.isNotEmpty)
            SearchSongsSection(
              tunes: result.tunes,
              onTap: (t) => cubit.addRecentItem(RecentSongItem(t)),
            ),
        if (filterMode == FilterMode.all || filterMode == FilterMode.albums)
          if (result.albums.isNotEmpty)
            SearchAlbumsSection(
              albums: result.albums,
              onTap: (a) => cubit.addRecentItem(RecentAlbumItem(a)),
            ),
        if (filterMode == FilterMode.all || filterMode == FilterMode.artists)
          if (result.artists.isNotEmpty)
            SearchArtistsSection(
              artists: result.artists,
              onTap: (a) => cubit.addRecentItem(RecentArtistItem(a)),
            ),
      ],
    };
  }
}
