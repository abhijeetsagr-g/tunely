import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/data/model/tune.dart';
import 'package:tunely/features/player/bloc/playback_bloc.dart';

class SongTileOptions extends StatefulWidget {
  const SongTileOptions({
    super.key,
    required this.isCurrent,
    required this.tune,
  });

  final bool isCurrent;
  final Tune tune;

  @override
  State<SongTileOptions> createState() => _SongTileOptionsState();
}

class _SongTileOptionsState extends State<SongTileOptions> {
  bool _expanded = false;

  void _collapse() => setState(() => _expanded = false);

  @override
  Widget build(BuildContext context) {
    if (widget.isCurrent) return const SizedBox.shrink();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          axis: Axis.horizontal,
          child: child,
        ),
      ),
      child: _expanded
          ? Row(
              key: const ValueKey('expanded'),
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.queue_play_next_sharp),
                  iconSize: 20,
                  color: Theme.of(context).colorScheme.primary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Play after this',
                  onPressed: () {
                    // TODO: SHOW CONTEXT
                    context.read<PlaybackBloc>().add(
                      PlayAfterThis(widget.tune),
                    );
                    _collapse();
                  },
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.queue),
                  iconSize: 20,
                  color: Theme.of(context).colorScheme.primary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Add to queue',
                  onPressed: () {
                    context.read<PlaybackBloc>().add(AddToQueue(widget.tune));
                    _collapse();
                  },
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                  color: Colors.grey,
                  onPressed: _collapse,
                ),
              ],
            )
          : IconButton(
              key: const ValueKey('collapsed'),
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
              onPressed: () => setState(() => _expanded = true),
            ),
    );
  }
}
