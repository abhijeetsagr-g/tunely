import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/features/music_management/cubit/music_manager_cubit.dart';
import 'package:tunely/features/playlist/bloc/playlist_bloc.dart';
import 'widget/playlist_states.dart';

class PlaylistView extends StatelessWidget {
  const PlaylistView({super.key, required this.playlist});

  final PlaylistModel playlist;

  @override
  Widget build(BuildContext context) {
    return _PlaylistBody(playlist: playlist);
  }
}

class _PlaylistBody extends StatefulWidget {
  const _PlaylistBody({required this.playlist});
  final PlaylistModel playlist;

  @override
  State<_PlaylistBody> createState() => _PlaylistBodyState();
}

class _PlaylistBodyState extends State<_PlaylistBody> {
  @override
  void initState() {
    super.initState();
    final settings = context.read<ManagementCubit>().state;
    context.read<PlaylistBloc>().add(
      LoadSongsEvent(playlistId: widget.playlist.id, settings: settings),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PlaylistBloc, PlaylistState>(
        builder: (context, state) {
          return switch (state) {
            PlaylistLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            PlaylistError(:final error) => PlaylistErrorView(error: error),
            LoadedPlaylist(:final detail) => _buildDetail(detail),
          };
        },
      ),
    );
  }

  Widget _buildDetail(PlaylistDetailState detail) {
    if (detail.playlistId != widget.playlist.id) {
      return const SizedBox.shrink();
    }
    if (detail.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (detail.error != null) {
      return PlaylistErrorView(error: detail.error!);
    }
    return PlaylistLoadedView(
      playlist: widget.playlist,
      tunes: detail.songs,
      onRemove: (songId) => context
          .read<PlaylistBloc>()
          .add(RemoveSongEvent(playlistId: widget.playlist.id, songId: songId)),
    );
  }
}
