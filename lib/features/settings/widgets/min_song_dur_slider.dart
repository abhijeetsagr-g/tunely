import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/music_management/cubit/music_manager_cubit.dart';

class MinSongDurSlider extends StatelessWidget {
  const MinSongDurSlider({super.key});

  // Slider position 0-30 maps to 0-30s in 1s steps,
  // position 30-60 maps to 30-60s in 5s steps.
  static double _msToPos(int ms) {
    final sec = ms ~/ 1000;
    if (sec <= 30) return sec.toDouble();
    return 30 + (sec - 30) / 5;
  }

  static int _posToMs(double pos) {
    if (pos <= 30) return pos.round() * 1000;
    final sec = 30 + ((pos - 30) * 5).round();
    return sec * 1000;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ManagementCubit>();
    final durationMs = cubit.state.minDurationMs;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isOff = durationMs == 0;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Minimum song duration',
                  style: theme.textTheme.titleSmall,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isOff
                        ? scheme.surfaceContainerHighest
                        : scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatDuration(durationMs),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isOff
                          ? scheme.onSurfaceVariant
                          : scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Songs shorter than this will be hidden from your library.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Slider(
              value: _msToPos(durationMs),
              min: 0,
              max: 60,
              divisions: 36, // 30 steps of 1s + 6 steps of 5s
              label: _formatDuration(durationMs),
              onChanged: (v) => cubit.updateMinDuration(_posToMs(v)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Off',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '30s',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '1m',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int ms) {
    if (ms == 0) return 'Off';
    final sec = ms ~/ 1000;
    if (sec < 60) return '${sec}s';
    return '${sec ~/ 60}m ${sec % 60}s';
  }
}
