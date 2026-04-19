import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/lyrics/cubit/lyrics_cubit.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/shared/model/tune.dart';

class LyricsTestView extends StatefulWidget {
  final Tune tune;
  const LyricsTestView({super.key, required this.tune});

  @override
  State<LyricsTestView> createState() => _LyricsTestViewState();
}

class _LyricsTestViewState extends State<LyricsTestView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<LyricsCubit>().fetch(widget.tune);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tune.title, overflow: TextOverflow.ellipsis),
        actions: [
          // Reload from LRCLIB
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<LyricsCubit>().reload(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _LyricsBody(scrollController: _scrollController)),
          _OffsetControls(),
        ],
      ),
    );
  }
}

class _LyricsBody extends StatelessWidget {
  final ScrollController scrollController;
  const _LyricsBody({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LyricsCubit, LyricsState>(
      builder: (context, lyricsState) {
        if (lyricsState is LyricsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (lyricsState is LyricsNotFound) {
          return const Center(
            child: Text(
              'No lyrics found',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        if (lyricsState is LyricsLoaded) {
          if (lyricsState.result.instrumental) {
            return const Center(child: Text('🎸 Instrumental'));
          }

          // Synced lyrics
          if (lyricsState.result.synced.isNotEmpty) {
            return BlocBuilder<PlaybackBloc, PlaybackState>(
              buildWhen: (prev, curr) => prev.position != curr.position,
              builder: (context, playbackState) {
                final position = playbackState.position.inMilliseconds;
                final lines = lyricsState.result.synced;
                final offset = lyricsState.effectiveOffset;

                // Find current line index
                int currentIndex = 0;
                for (int i = 0; i < lines.length; i++) {
                  if (lines[i].timestamp + offset <= position) {
                    currentIndex = i;
                  } else {
                    break;
                  }
                }

                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  itemCount: lines.length,
                  itemBuilder: (context, i) {
                    final isActive = i == currentIndex;
                    return GestureDetector(
                      onTap: () {
                        final seekTo = lines[i].timestamp + offset;
                        context.read<PlaybackBloc>().add(
                          SeekEvent(Duration(milliseconds: seekTo)),
                        );
                      },
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: isActive ? 18 : 15,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isActive
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                          height: 1.8,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 4,
                          ),
                          child: Text(lines[i].text),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }

          // Plain lyrics fallback
          if (lyricsState.result.plain != null) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Text(
                lyricsState.result.plain!,
                style: const TextStyle(height: 1.8),
              ),
            );
          }

          return const Center(
            child: Text(
              'No lyrics available',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}

class _OffsetControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LyricsCubit, LyricsState>(
      builder: (context, state) {
        if (state is! LyricsLoaded) return const SizedBox();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
          ),
          child: Row(
            children: [
              // Decrease offset
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  final current = state.temporaryOffset;
                  context.read<LyricsCubit>().setOffset(current - 500);
                },
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Offset: ${state.effectiveOffset > 0 ? '+' : ''}${state.effectiveOffset}ms',
                      style: const TextStyle(fontSize: 13),
                    ),
                    Text(
                      'Saved: ${state.result.offsetMs}ms  |  Temp: ${state.temporaryOffset}ms',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              // Increase offset
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  final current = state.temporaryOffset;
                  context.read<LyricsCubit>().setOffset(current + 500);
                },
              ),
              // Save offset permanently
              TextButton(
                onPressed: () => context.read<LyricsCubit>().saveOffset(
                  state.temporaryOffset,
                ),
                child: const Text('Save'),
              ),
              // Reset temporary offset
              TextButton(
                onPressed: () => context.read<LyricsCubit>().setOffset(0),
                child: const Text('Reset'),
              ),
            ],
          ),
        );
      },
    );
  }
}
