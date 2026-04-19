import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/features/playlist/cubit/playlist_cubit.dart';
import 'package:tunely/features/stats/cubit/stats_cubit.dart';
import 'package:tunely/shared/model/tune.dart';

class PlayerView extends StatelessWidget {
  const PlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Now Playing'), centerTitle: true),
      body: BlocBuilder<PlaybackBloc, PlaybackState>(
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  _AlbumArt(state: state),
                  const SizedBox(height: 32),
                  _TrackInfo(state: state),
                  const SizedBox(height: 32),
                  _SeekBar(state: state),
                  const SizedBox(height: 8),
                  _Controls(state: state),
                  const SizedBox(height: 16),

                  _QueueList(state: state),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Album art ──────────────────────────────────────────────────────────────────

class _AlbumArt extends StatelessWidget {
  const _AlbumArt({required this.state});
  final PlaybackState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      // Swap for actual album art widget when available, e.g:
      // child: ClipRRect(
      //   borderRadius: BorderRadius.circular(16),
      //   child: QueryArtworkWidget(id: state.currentItem!.id, type: ArtworkType.AUDIO),
      // ),
      child: Icon(
        Icons.music_note_rounded,
        size: 80,
        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
      ),
    );
  }
}

// ── Track info ─────────────────────────────────────────────────────────────────

class _TrackInfo extends StatelessWidget {
  const _TrackInfo({required this.state});
  final PlaybackState state;

  @override
  Widget build(BuildContext context) {
    final tune = state.currentItem;
    return Column(
      children: [
        Text(
          tune?.title ?? 'No track loaded',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          tune?.artist ?? '—',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ── Seek bar ───────────────────────────────────────────────────────────────────

class _SeekBar extends StatelessWidget {
  const _SeekBar({required this.state});
  final PlaybackState state;

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final duration = state.duration ?? Duration.zero;
    final progress = duration.inMilliseconds > 0
        ? (state.position.inMilliseconds / duration.inMilliseconds).clamp(
            0.0,
            1.0,
          )
        : 0.0;

    return Column(
      children: [
        Slider(
          value: progress,
          onChanged: (v) => context.read<PlaybackBloc>().add(
            SeekEvent(
              Duration(milliseconds: (v * duration.inMilliseconds).round()),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_fmt(state.position), style: const TextStyle(fontSize: 12)),
              Text(_fmt(duration), style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Transport controls ─────────────────────────────────────────────────────────

class _Controls extends StatelessWidget {
  const _Controls({required this.state});
  final PlaybackState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PlaybackBloc>();
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            Icons.shuffle_rounded,
            color: state.shuffleEnabled
                ? colorScheme.primary
                : colorScheme.onSurface.withOpacity(0.5),
          ),
          onPressed: () => bloc.add(SetShuffleEvent(!state.shuffleEnabled)),
        ),

        IconButton(
          iconSize: 36,
          icon: const Icon(Icons.skip_previous_rounded),
          onPressed: () => bloc.add(SkipToPreviousEvent()),
        ),
        const SizedBox(width: 8),
        _PlayPauseButton(state: state),
        const SizedBox(width: 8),

        IconButton(
          iconSize: 36,
          icon: const Icon(Icons.skip_next_rounded),
          onPressed: () => bloc.add(SkipToNextEvent()),
        ),

        IconButton(
          icon: const Icon(Icons.playlist_add),
          onPressed: state.currentItem == null
              ? null
              : () => showAddToPlaylistSheet(context, state.currentItem!),
        ),
        IconButton(
          icon: Icon(
            context.read<StatsCubit>().isLiked(state.currentItem!.path)
                ? Icons.favorite
                : Icons.favorite_border,
            color: context.read<StatsCubit>().isLiked(state.currentItem!.path)
                ? Colors.red
                : null,
          ),
          onPressed: () =>
              context.read<StatsCubit>().toggleLike(state.currentItem!.path),
        ),
      ],
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({required this.state});
  final PlaybackState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PlaybackBloc>();
    final isLoading =
        state.status == PlaybackStatus.loading ||
        state.status == PlaybackStatus.buffering;

    return GestureDetector(
      onTap: isLoading
          ? null
          : () => bloc.add(state.isPlaying ? PauseEvent() : PlayEvent()),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: isLoading
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
            : Icon(
                state.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                size: 36,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
      ),
    );
  }
}

// ── Speed row ──────────────────────────────────────────────────────────────────

class _SpeedRow extends StatelessWidget {
  const _SpeedRow({required this.state});
  final PlaybackState state;

  @override
  Widget build(BuildContext context) {
    const speeds = [0.75, 1.0, 1.25, 1.5, 2.0];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: speeds.map((speed) {
        final active = (state.speed - speed).abs() < 0.01;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: ChoiceChip(
            label: Text('$speed×', style: const TextStyle(fontSize: 12)),
            selected: active,
            visualDensity: VisualDensity.compact,
            onSelected: (_) =>
                context.read<PlaybackBloc>().add(SetSpeedEvent(speed)),
          ),
        );
      }).toList(),
    );
  }
}

// ── Queue list ─────────────────────────────────────────────────────────────────

class _QueueList extends StatelessWidget {
  const _QueueList({required this.state});
  final PlaybackState state;

  @override
  Widget build(BuildContext context) {
    if (state.queue.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Up next',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 160,
          child: ListView.builder(
            itemCount: state.queue.length,
            itemBuilder: (context, i) {
              final tune = state.queue[i];
              final isCurrent = i == state.currentIndex;
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: isCurrent
                    ? Icon(
                        Icons.equalizer_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      )
                    : Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                title: Text(
                  tune.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                    color: isCurrent
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  tune.artist,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () =>
                    context.read<PlaybackBloc>().add(SkipToQueueItemEvent(i)),
              );
            },
          ),
        ),
      ],
    );
  }
}

void showAddToPlaylistSheet(BuildContext context, Tune tune) {
  showModalBottomSheet(
    context: context,
    builder: (_) => BlocProvider.value(
      value: context.read<PlaylistCubit>(),
      child: _AddToPlaylistSheet(tune: tune),
    ),
  );
}

class _AddToPlaylistSheet extends StatelessWidget {
  final Tune tune;
  const _AddToPlaylistSheet({required this.tune});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistCubit, PlaylistState>(
      builder: (context, state) {
        if (state is! PlaylistLoaded) {
          return const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add to playlist',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  // Create new playlist inline
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New'),
                    onPressed: () => _showCreateDialog(context, tune),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            if (state.playlists.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No playlists yet',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                itemCount: state.playlists.length,
                itemBuilder: (context, i) {
                  final playlist = state.playlists[i];
                  return ListTile(
                    leading: const Icon(Icons.queue_music),
                    title: Text(playlist.playlist ?? 'Unknown'),
                    subtitle: Text('${playlist.numOfSongs} songs'),
                    onTap: () {
                      context.read<PlaylistCubit>().addToPlaylist(
                        playlist.id,
                        tune,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added to ${playlist.playlist}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  );
                },
              ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  void _showCreateDialog(BuildContext context, Tune tune) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<PlaylistCubit>(),
        child: AlertDialog(
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
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  await context.read<PlaylistCubit>().createPlaylist(name);
                  // Fetch fresh playlists then add song to new one
                  await context.read<PlaylistCubit>().fetchPlaylists();
                  final s = context.read<PlaylistCubit>().state;
                  if (s is PlaylistLoaded && s.playlists.isNotEmpty) {
                    final newPlaylist = s.playlists.last;
                    context.read<PlaylistCubit>().addToPlaylist(
                      newPlaylist.id,
                      tune,
                    );
                  }
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Create & Add'),
            ),
          ],
        ),
      ),
    );
  }
}
