import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/features/playlist/cubit/playlist_cubit.dart';
import 'package:tunely/features/playlist/view/widget/playlist_dialogs.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/album_carousel.dart';

class PlaylistHeroSliver extends StatelessWidget {
  const PlaylistHeroSliver({
    super.key,
    required this.playlist,
    required this.tunes,
    this.onEditToggle,
  });

  final PlaylistModel playlist;
  final List<Tune> tunes;
  final VoidCallback? onEditToggle;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 420,
      pinned: true,
      stretch: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showOptionsSheet(context),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: AlbumCarousel(
          tunes: tunes,
          title: playlist.playlist,
        ),
      ),
    );
  }

  void _showOptionsSheet(BuildContext context) {
    final cubit = context.read<PlaylistCubit>();
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => PlaylistOptionsSheet(
        playlist: playlist,
        cubit: cubit,
        onEditTap: onEditToggle,
      ),
    );
  }
}
