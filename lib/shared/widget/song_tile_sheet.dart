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

  void _playNext(BuildContext context) {
    context.read<PlaybackBloc>().add(PlayAfterThisEvent(tune));
    Navigator.pop(context);
  }

  void _addToQueue(BuildContext context) {
    context.read<PlaybackBloc>().add(AddQueueItemsEvent([tune]));
    Navigator.pop(context);
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 40,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.onSurfaceVariant.withAlpha(70),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          // Song header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 108,
                  height: 108,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow.withAlpha(60),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: AlbumArt(
                    artUri: tune.artUri,
                    size: const Size(108, 108),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tune.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tune.artist,
                        style: theme.textTheme.bodyMedium?.copyWith(
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              height: 1,
              thickness: 1,
              color: colors.outlineVariant.withAlpha(90),
            ),
          ),

          // Actions
          const SizedBox(height: 10),

          _SheetAction(
            icon: Icons.skip_next_rounded,
            title: 'Play next',
            subtitle: 'Insert after current song',
            iconColor: colors.primary,
            iconBgColor: colors.primaryContainer.withAlpha(140),
            onTap: () => _playNext(context),
          ),
          _SheetAction(
            icon: Icons.queue_music_rounded,
            title: 'Add to queue',
            subtitle: 'Play after the queue ends',
            iconColor: colors.tertiary,
            iconBgColor: colors.tertiaryContainer.withAlpha(140),
            onTap: () => _addToQueue(context),
          ),
          _SheetAction(
            icon: Icons.album_rounded,
            title: 'Album',
            subtitle: 'Show album',
            iconColor: colors.secondary,
            iconBgColor: colors.secondaryContainer.withAlpha(140),
            onTap: () => _goToAlbum(context),
          ),

          const SizedBox(height: 6),
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
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: (iconColor ?? colors.primary).withAlpha(30),
          highlightColor: (iconColor ?? colors.primary).withAlpha(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconBgColor ?? colors.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: iconColor ?? colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: colors.onSurfaceVariant.withAlpha(120),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
