import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/playlist/cubit/playlist_cubit.dart';
import 'package:tunely/features/playlist/cubit/playlist_detail_cubit.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/song_picker.dart';

void showAddSongsSheet(BuildContext context, PlaylistModel playlist) {
  final detailCubit = context.read<PlaylistDetailCubit>();
  final library = context.read<LibraryCubit>().state;
  final tunes = library is LibraryLoaded ? library.tunes : <Tune>[];

  final searchController = TextEditingController();
  var selectedSongIds = <int>{};

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => StatefulBuilder(
      builder: (context, setSheetState) {
        final query = searchController.text.toLowerCase();
        final filtered = query.isEmpty
            ? tunes
            : tunes
                .where((t) =>
                    t.title.toLowerCase().contains(query) ||
                    t.artist.toLowerCase().contains(query))
                .toList();

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Container(
            height: MediaQuery.sizeOf(context).height * 0.85,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(20),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Add Songs to "${playlist.playlist}"',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: searchController,
                      onChanged: (_) => setSheetState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search songs...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: SongPicker(
                        tunes: filtered,
                        onSelectionChanged: (ids) {
                          selectedSongIds = ids;
                          setSheetState(() {});
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: selectedSongIds.isEmpty
                            ? null
                            : () {
                                detailCubit.addSongs(
                                  selectedSongIds.toList(),
                                );
                                Navigator.pop(context);
                              },
                        icon: const Icon(Icons.add_rounded),
                        label: Text(
                          'Add ${selectedSongIds.length} song${selectedSongIds.length == 1 ? '' : 's'}',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

class PlaylistOptionsSheet extends StatelessWidget {
  const PlaylistOptionsSheet({
    super.key,
    required this.playlist,
    required this.cubit,
    this.onEditTap,
  });

  final PlaylistModel playlist;
  final PlaylistCubit cubit;
  final VoidCallback? onEditTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Text(
              playlist.playlist,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 4),
          ListTile(
            leading: const Icon(Icons.edit_rounded),
            title: const Text('Edit playlist'),
            onTap: () {
              Navigator.pop(context);
              onEditTap?.call();
            },
          ),
          const Divider(indent: 20, endIndent: 20),
          ListTile(
            leading: const Icon(Icons.drive_file_rename_outline_rounded),
            title: const Text('Rename playlist'),
            onTap: () => _showRenameDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded),
            title: Text(
              'Delete playlist',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () => _showDeleteDialog(context),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context) {
    final controller = TextEditingController(text: playlist.playlist);

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              cubit.renamePlaylist(playlist.id, name);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete playlist'),
        content: Text('Delete "${playlist.playlist}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              cubit.deletePlaylist(playlist.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
