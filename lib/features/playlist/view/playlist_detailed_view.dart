// playlist_detail_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/features/playlist/cubit/playlist_cubit.dart';

class PlaylistDetailView extends StatefulWidget {
  final PlaylistModel playlist;
  const PlaylistDetailView({super.key, required this.playlist});

  @override
  State<PlaylistDetailView> createState() => _PlaylistDetailViewState();
}

class _PlaylistDetailViewState extends State<PlaylistDetailView> {
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
          if (state is! PlaylistLoaded) return const SizedBox.shrink();

          if (state.loadingTunes) {
            return const Center(child: CircularProgressIndicator());
          }

          final tunes = state.tunesCache[widget.playlist.id];

          if (tunes == null || tunes.isEmpty) {
            return const Center(child: Text("No songs in this playlist."));
          }

          return ListView.builder(
            itemCount: tunes.length,
            itemBuilder: (context, index) {
              final tune = tunes[index];
              return ListTile(
                leading: const Icon(Icons.music_note),
                title: Text(
                  tune.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(tune.artist, maxLines: 1),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => context
                      .read<PlaylistCubit>()
                      .removeFromPlaylist(widget.playlist.id, tune),
                ),
                onTap: () {
                  // TODO: play tune
                },
              );
            },
          );
        },
      ),
    );
  }
}
