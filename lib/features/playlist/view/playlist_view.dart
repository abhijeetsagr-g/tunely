import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/features/music_management/cubit/music_manager_cubit.dart';
import 'package:tunely/features/playlist/cubit/playlist_detail_cubit.dart';
import 'package:tunely/features/playlist/service/playlist_service.dart';
import 'widget/playlist_states.dart';

class PlaylistView extends StatelessWidget {
  const PlaylistView({super.key, required this.playlist});

  final PlaylistModel playlist;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final service = context.read<PlaylistService>();
        return PlaylistDetailCubit(playlistId: playlist.id, service: service);
      },
      child: _PlaylistBody(playlist: playlist),
    );
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
    context.read<PlaylistDetailCubit>().loadSongs(settings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PlaylistDetailCubit, PlaylistDetailState>(
        builder: (context, state) {
          return switch (state) {
            PlaylistDetailInitial() => const SizedBox.shrink(),
            PlaylistDetailLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            PlaylistDetailError(:final error) => PlaylistErrorView(
              error: error,
            ),
            PlaylistDetailLoaded(
              :final tunes,
              :final sortType,
              :final sortOrder,
            ) =>
              PlaylistLoadedView(
                playlist: widget.playlist,
                tunes: tunes,
                sortType: sortType,
                sortOrder: sortOrder,
                onSortTypeChanged: context
                    .read<PlaylistDetailCubit>()
                    .setSortType,
                onSortOrderToggled: context
                    .read<PlaylistDetailCubit>()
                    .toggleSortOrder,
                onRemove: context.read<PlaylistDetailCubit>().removeSong,
              ),
          };
        },
      ),
    );
  }
}
