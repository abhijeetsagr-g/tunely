import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/core/utils/settings_arguments.dart';
import 'package:tunely/features/playlist/cubit/playlist_cubit.dart';
import 'package:tunely/features/playlist/model/playlist.dart';
import 'package:tunely/features/playlist/model/playlist_detail.dart';
import 'package:tunely/shared/widget/album_carousel.dart';
import 'package:tunely/shared/widget/song_action_row.dart';
import 'package:tunely/shared/widget/tune_sliver_list.dart';

class DetailedPlaylistView extends StatefulWidget {
  const DetailedPlaylistView({super.key, required this.playlist});

  final Playlist playlist;

  @override
  State<DetailedPlaylistView> createState() => _DetailedPlaylistViewState();
}

class _DetailedPlaylistViewState extends State<DetailedPlaylistView> {
  @override
  void initState() {
    super.initState();
    context.read<PlaylistCubit>().loadPlaylistDetail(widget.playlist);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PlaylistCubit, PlaylistState>(
        builder: (context, state) {
          return switch (state) {
            PlaylistsLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            PlaylistsError(:final message) => Center(child: Text(message)),
            PlaylistsLoaded(:final detail) => _buildDetail(detail),
          };
        },
      ),
    );
  }

  Widget _buildDetail(PlaylistDetail detail) {
    if (detail.playlist?.key != widget.playlist.key) {
      return const SizedBox.shrink();
    }
    if (detail.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (detail.error != null) {
      return Center(child: Text(detail.error!));
    }

    final tunes = detail.tunes;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 420,
          pinned: true,
          stretch: true,
          leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_left),
            onPressed: () => Navigator.of(context).pop(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: AlbumCarousel(
              tunes: tunes,
              title: detail.playlist?.name ?? widget.playlist.name,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoute.editPlaylist,
                arguments: PlaylistSettingsArguments(playlist: widget.playlist),
              ),
              icon: const Icon(Icons.playlist_add),
            ),
          ],
        ),
        SongActionRowSliver(tunes: tunes),
        TuneSliverList(tunes: tunes),
        const SliverToBoxAdapter(child: SizedBox(height: 96)),
      ],
    );
  }
}
