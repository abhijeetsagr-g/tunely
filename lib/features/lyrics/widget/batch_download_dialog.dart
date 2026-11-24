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
    final scheme = theme.colorScheme;

    return BlocBuilder<LyricsBatchCubit, LyricsBatchState>(
      builder: (context, state) {
        final s = state;
        final isDone = s is LyricsBatchDone;

        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                isDone ? Icons.check_circle_rounded : Icons.lyrics_rounded,
                key: ValueKey(isDone),
                size: 40,
                color: scheme.primary,
              ),
            ),
            title: Text(
              isDone ? 'All done' : 'Fetching lyrics',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 280),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: s is LyricsBatchDone
                      ? _DoneBody(
                          key: const ValueKey('done'),
                          found: s.found,
                          notFound: s.notFound,
                          skipped: s.skipped,
                        )
                      : _ProgressBody(
                          key: const ValueKey('progress'),
                          completed: s is LyricsBatchProgress ? s.completed : 0,
                          total: s is LyricsBatchProgress ? s.total : 0,
                          skipped: s is LyricsBatchProgress ? s.skipped : 0,
                          notFound: s is LyricsBatchProgress ? s.notFound : 0,
                          currentSong: s is LyricsBatchProgress
                              ? s.currentTune.title
                              : null,
                        ),
                ),
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actionsOverflowButtonSpacing: 8,
            actions: isDone
                ? [
                    FilledButton(
                      onPressed: () {
                        context.read<LyricsBatchCubit>().reset();
                        Navigator.pop(context);
                      },
                      child: const Text('Done'),
                    ),
                  ]
                : [
                    TextButton(
                      onPressed: () {
                        context.read<LyricsBatchCubit>().cancel();
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: scheme.error,
                      ),
                      child: const Text('Cancel'),
                    ),
                    if (s is LyricsBatchProgress)
                      FilledButton.tonalIcon(
                        onPressed: () =>
                            context.read<LyricsBatchCubit>().skipCurrent(),
                        icon: const Icon(Icons.skip_next_rounded, size: 20),
                        label: const Text('Skip'),
                      ),
                  ],
          ),
        );
      },
    );
  }
}

class _ProgressBody extends StatelessWidget {
  final int completed;
  final int total;
  final int skipped;
  final int notFound;
  final String? currentSong;

  const _ProgressBody({
    super.key,
    required this.completed,
    required this.total,
    required this.skipped,
    required this.notFound,
    required this.currentSong,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final fraction = total > 0 ? completed / total : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(end: fraction ?? 0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          builder: (_, value, __) => ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              // Indeterminate until we know the total
              value: fraction == null ? null : value,
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              total > 0 ? '$completed of $total songs' : 'Preparing…',
              style: muted,
            ),
            if (fraction != null)
              Text('${(fraction * 100).round()}%', style: muted),
          ],
        ),
        if (currentSong != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.music_note_rounded, size: 18, color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    currentSong!,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (skipped > 0 || notFound > 0) ...[
          const SizedBox(height: 12),
          _StatChips(skipped: skipped, notFound: notFound),
        ],
      ],
    );
  }
}

class _DoneBody extends StatelessWidget {
  final int found;
  final int notFound;
  final int skipped;

  const _DoneBody({
    super.key,
    required this.found,
    required this.notFound,
    required this.skipped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$found',
          style: theme.textTheme.displaySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          found == 1 ? 'lyric found' : 'lyrics found',
          style: theme.textTheme.bodyLarge,
        ),
        if (notFound > 0 || skipped > 0) ...[
          const SizedBox(height: 16),
          _StatChips(skipped: skipped, notFound: notFound),
        ],
      ],
    );
  }
}

class _StatChips extends StatelessWidget {
  final int skipped;
  final int notFound;

  const _StatChips({required this.skipped, required this.notFound});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        if (notFound > 0)
          _Pill(icon: Icons.search_off_rounded, label: '$notFound not found'),
        if (skipped > 0)
          _Pill(icon: Icons.skip_next_rounded, label: '$skipped skipped'),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Pill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
