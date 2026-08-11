import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/core/utils/settings_arguments.dart';
import 'package:tunely/features/library/widget/playlist_tile.dart';
import 'package:tunely/features/playlist/cubit/playlist_cubit.dart';
import 'package:tunely/features/playlist/model/playlist.dart';
import 'package:tunely/shared/model/tune.dart';

class PlaylistsTab extends StatefulWidget {
  const PlaylistsTab({super.key, required this.tunes});
  final List<Tune> tunes;

  @override
  State<PlaylistsTab> createState() => _PlaylistsTabState();
}

class _PlaylistsTabState extends State<PlaylistsTab> {
  @override
  void initState() {
    super.initState();
    context.read<PlaylistCubit>().loadPlaylists();
  }

  void _openPlaylist(Playlist playlist) {
    Navigator.pushNamed(
      context,
      AppRoute.playlist,
      arguments: PlaylistSettingsArguments(playlist: playlist),
    );
  }

  void _createPlaylist() {
    Navigator.pushNamed(
      context,
      AppRoute.createPlaylist,
      arguments: CreatePlaylistSettingsArguments(tunes: widget.tunes),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistCubit, PlaylistState>(
      builder: (context, state) {
        return switch (state) {
          PlaylistsLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          PlaylistsError(:final message) => Center(
            child: Text('Error: $message'),
          ),
          PlaylistsLoaded(:final playlists) => RefreshIndicator(
            onRefresh: () => context.read<PlaylistCubit>().loadPlaylists(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: playlists.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _CreatePlaylistContainer(onTap: _createPlaylist);
                }
                final playlist = playlists[index - 1];
                return PlaylistTile(
                  playlist: playlist,
                  onTap: () => _openPlaylist(playlist),
                );
              },
            ),
          ),
        };
      },
    );
  }
}

class _CreatePlaylistContainer extends StatelessWidget {
  const _CreatePlaylistContainer({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
        ),
        child: Icon(Icons.add_rounded, color: theme.colorScheme.primary),
      ),
      title: Text(
        'Create Playlist',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
