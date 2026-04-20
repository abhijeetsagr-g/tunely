import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/playlist/cubit/playlist_cubit.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlaylistTestView extends StatefulWidget {
  const PlaylistTestView({super.key});

  @override
  State<PlaylistTestView> createState() => _PlaylistTestViewState();
}

class _PlaylistTestViewState extends State<PlaylistTestView> {
  @override
  void initState() {
    super.initState();
    context.read<PlaylistCubit>().fetchPlaylists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlists Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<PlaylistCubit, PlaylistState>(
        builder: (context, state) {
          if (state is PlaylistLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PlaylistError) {
            return Center(child: Text(state.message));
          }

          if (state is PlaylistLoaded) {
            if (state.playlists.isEmpty) {
              return const Center(
                child: Text(
                  'No playlists',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              itemCount: state.playlists.length,
              itemBuilder: (context, i) {
                final playlist = state.playlists[i];
                return ListTile(
                  leading: const Icon(Icons.queue_music),
                  title: Text(playlist.playlist),
                  subtitle: Text('${playlist.numOfSongs} songs'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Rename
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _showRenameDialog(context, playlist),
                      ),
                      // Delete
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        onPressed: () => context
                            .read<PlaylistCubit>()
                            .removePlaylist(playlist.id),
                      ),
                    ],
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<PlaylistCubit>(),
                        child: _PlaylistDetailView(playlist: playlist),
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Playlist name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                context.read<PlaylistCubit>().createPlaylist(name);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, PlaylistModel playlist) {
    final controller = TextEditingController(text: playlist.playlist);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename Playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'New name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                context.read<PlaylistCubit>().renamePlaylist(playlist.id, name);
                Navigator.pop(context);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }
}

// Detail view — shows songs inside a playlist
class _PlaylistDetailView extends StatefulWidget {
  final PlaylistModel playlist;
  const _PlaylistDetailView({required this.playlist});

  @override
  State<_PlaylistDetailView> createState() => _PlaylistDetailViewState();
}

class _PlaylistDetailViewState extends State<_PlaylistDetailView> {
  @override
  void initState() {
    super.initState();
    context.read<PlaylistCubit>().fetchTunes(widget.playlist.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.playlist.playlist)),
      body: BlocBuilder<PlaylistCubit, PlaylistState>(
        builder: (context, state) {
          if (state is! PlaylistLoaded) return const SizedBox();

          if (state.loadingTunes) {
            return const Center(child: CircularProgressIndicator());
          }

          final tunes = state.tunesCache[widget.playlist.id];

          if (tunes == null || tunes.isEmpty) {
            return const Center(
              child: Text('No songs', style: TextStyle(color: Colors.grey)),
            );
          }

          return ListView.builder(
            itemCount: tunes.length,
            itemBuilder: (context, i) {
              final tune = tunes[i];
              return ListTile(
                leading: const Icon(Icons.music_note),
                title: Text(
                  tune.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  tune.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                  onPressed: () => context
                      .read<PlaylistCubit>()
                      .removeFromPlaylist(widget.playlist.id, tune),
                ),
                onTap: () => context.read<PlaybackBloc>().add(
                  PlayQueueEvent(tunes, startIndex: i),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
