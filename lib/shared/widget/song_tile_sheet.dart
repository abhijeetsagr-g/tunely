import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/core/utlis/settings_arguments.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/album_art.dart';

void showSongTileSheet(BuildContext context, Tune tune) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<PlaybackBloc>(),
      child: _SongTileSheet(tune: tune),
    ),
  );
}

class _SongTileSheet extends StatelessWidget {
  const _SongTileSheet({required this.tune});
  final Tune tune;

  void _playSong(BuildContext context) {
    context.read<PlaybackBloc>().add(PlayQueueEvent([tune], startIndex: 0));
    Navigator.pop(context);
  }

  void _playNext(BuildContext context) {
    context.read<PlaybackBloc>().add(PlayAfterThisEvent(tune));
    Navigator.pop(context);
  }

  void _addToQueue(BuildContext context) {
    context.read<PlaybackBloc>().add(AddQueueItemsEvent([tune]));
    Navigator.pop(context);
  }

  void _addToPlaylist(BuildContext context) {
    Navigator.pop(context);
    // TODO: Show available playlists
  }

  void _goToAlbum(BuildContext context) {
    if (tune.albumId == null) return;
    final state = context.read<LibraryCubit>().state;
    if (state is! LibraryLoaded) return;
    final album = state.albums.firstWhereOrNull((e) => e.id == tune.albumId);
    if (album == null) return;
    Navigator.pop(context);
    Navigator.pushNamed(
      context,
      AppRoute.album,
      arguments: AlbumSettingsArguments(album),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.onSurface.withAlpha(40),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // Song header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AlbumArt(size: Size(52, 52)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tune.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tune.artist,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, thickness: 0.5, color: colors.outlineVariant),

          // Actions
          const SizedBox(height: 8),

          _SheetAction(
            icon: Icons.play_arrow_rounded,
            iconColor: colors.primary,
            iconBgColor: colors.primaryContainer,
            title: 'Play song',
            subtitle: 'Start playing now',
            onTap: () => _playSong(context),
          ),
          _SheetAction(
            icon: Icons.skip_next_rounded,
            title: 'Play next',
            subtitle: 'Insert after current song',
            onTap: () => _playNext(context),
          ),
          _SheetAction(
            icon: Icons.queue_music_rounded,
            title: 'Add to queue',
            subtitle: 'Play after the queue ends',
            onTap: () => _addToQueue(context),
          ),

          _SheetAction(
            icon: Icons.album,
            title: 'Album',
            subtitle: 'Show album',
            onTap: () => _goToAlbum(context),
          ),

          // Divider(
          //   height: 16,
          //   indent: 20,
          //   endIndent: 20,
          //   thickness: 0.5,
          //   color: colors.outlineVariant,
          // ),

          // _SheetAction(
          //   icon: Icons.playlist_add_rounded,
          //   title: 'Add to playlist',
          //   subtitle: 'Choose from your playlists',
          //   onTap: () => _addToPlaylist(context),
          // ),
        ],
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.iconBgColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? iconBgColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBgColor ?? colors.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 18,
                color: iconColor ?? colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
