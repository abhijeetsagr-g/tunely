import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/features/playlist/cubit/playlist_cubit.dart';
import 'package:tunely/features/playlist/view/widget/playlist_card.dart';

class PlaylistsTab extends StatelessWidget {
  final List<PlaylistModel> playlists;

  const PlaylistsTab({super.key, required this.playlists});

  void _showCreateSheet(BuildContext context) {
    final cubit = context.read<PlaylistCubit>();
    final nameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(20),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'New Playlist',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'My playlist',
                      labelText: 'Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;
                        cubit.createPlaylist(name: name);
                        Navigator.pop(context);
                      },
                      child: const Text('Create'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (playlists.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.queue_music, size: 64, color: Colors.grey.shade700),
            const SizedBox(height: 12),
            Text(
              'No playlists yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showCreateSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Playlist'),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: _CreatePlaylistCard(onTap: () => _showCreateSheet(context)),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return PlaylistCard(playlist: playlists[index]);
          }, childCount: playlists.length),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }
}

class _CreatePlaylistCard extends StatelessWidget {
  final VoidCallback onTap;

  const _CreatePlaylistCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const width = 150.0;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: width,
            height: width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: cs.surface.withAlpha(180),
              border: Border.all(
                color: cs.onSurfaceVariant.withAlpha(60),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Icon(Icons.add_rounded, size: 52, color: cs.primary),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: width - 16,
            child: Text(
              'Create Playlist',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ],
      ),
    );
  }
}
