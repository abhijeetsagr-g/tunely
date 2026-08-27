import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/lyrics/cubit/lyrics_batch_cubit.dart';
import 'package:tunely/features/lyrics/cubit/lyrics_batch_state.dart';
import 'package:tunely/shared/model/tune.dart';

void showBatchDownloadDialog(BuildContext context, List<Tune> tunes) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => BlocProvider.value(
      value: context.read<LyricsBatchCubit>(),
      child: _BatchDownloadDialog(tunes: tunes),
    ),
  );
}

class _BatchDownloadDialog extends StatefulWidget {
  final List<Tune> tunes;

  const _BatchDownloadDialog({required this.tunes});

  @override
  State<_BatchDownloadDialog> createState() => _BatchDownloadDialogState();
}

class _BatchDownloadDialogState extends State<_BatchDownloadDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LyricsBatchCubit>().start(widget.tunes);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<LyricsBatchCubit, LyricsBatchState>(
      builder: (context, state) {
        final isRunning = state is LyricsBatchProgress;
        final isDone = state is LyricsBatchDone;

        int completed = 0;
        int total = 0;
        int skipped = 0;
        int notFound = 0;
        String currentSong = '';

        if (state is LyricsBatchProgress) {
          completed = state.completed;
          total = state.total;
          skipped = state.skipped;
          notFound = state.notFound;
          currentSong = state.currentTune.title;
        }

        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              isDone ? 'Download Complete' : 'Downloading Lyrics',
              style: theme.textTheme.titleMedium,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isRunning) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: total > 0 ? completed / total : 0,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$completed / $total songs',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (skipped > 0 || notFound > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (skipped > 0) '$skipped skipped',
                        if (notFound > 0) '$notFound not found',
                      ].join(' · '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    currentSong,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
                if (isDone) ...[
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${state.found} lyrics found',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  if (state.notFound > 0 || state.skipped > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (state.notFound > 0) '${state.notFound} not found',
                        if (state.skipped > 0) '${state.skipped} skipped',
                      ].join(' · '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ],
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              if (isRunning) ...[
                TextButton(
                  onPressed: () => context.read<LyricsBatchCubit>().skipCurrent(),
                  child: const Text('Skip'),
                ),
                FilledButton(
                  onPressed: () {
                    context.read<LyricsBatchCubit>().cancel();
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                  ),
                  child: const Text('Cancel'),
                ),
              ],
              if (isDone)
                FilledButton(
                  onPressed: () {
                    context.read<LyricsBatchCubit>().reset();
                    Navigator.pop(context);
                  },
                  child: const Text('Done'),
                ),
            ],
          ),
        );
      },
    );
  }
}
