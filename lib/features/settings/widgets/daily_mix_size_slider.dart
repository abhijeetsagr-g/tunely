import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/settings/cubit/management_cubit.dart';

class DailyMixSizeSlider extends StatelessWidget {
  const DailyMixSizeSlider({super.key});

  static const List<int> _sizes = [10, 20, 30, 50];

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ManagementCubit>();
    final size = cubit.state.dailyMixSize;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Daily mix size', style: theme.textTheme.titleSmall),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$size songs',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Number of songs in the initial daily mix.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<int>(
            segments: _sizes
                .map((s) => ButtonSegment<int>(value: s, label: Text('$s')))
                .toList(),
            selected: {size},
            showSelectedIcon: false,
            onSelectionChanged: (selection) {
              cubit.updateDailyMixSize(selection.first);
            },
            style: SegmentedButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}
