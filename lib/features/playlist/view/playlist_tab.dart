import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/playlist/cubit/playlist_cubit.dart';
import 'package:tunely/features/playlist/view/widget/playlist_card.dart';

class PlaylistTab extends StatelessWidget {
  const PlaylistTab({super.key});

  void _showCreateDialog(BuildContext context) {
    final cubit = context.read<PlaylistCubit>();
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New playlist'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'My playlist',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Optional',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              final desc = descController.text.trim();
              cubit.createPlaylist(
                name: name,
                desc: desc.isEmpty ? null : desc,
              );
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BlocBuilder<PlaylistCubit, PlaylistState>(
          builder: (context, state) {
            if (state is LoadedPlaylist) {
              if (state.playlists.isEmpty) {
                return const Center(child: Text('No playlists yet'));
              }
              return ListView.builder(
                itemCount: state.playlists.length,
                itemBuilder: (context, index) =>
                    PlaylistCard(playlist: state.playlists[index]),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
        Positioned(
          bottom: 24,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'playlist_fab',
            onPressed: () => _showCreateDialog(context),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
