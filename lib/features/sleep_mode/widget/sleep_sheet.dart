import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/sleep_mode/cubit/sleep_mode_cubit.dart';

void showSleepSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return const _SleepSheetContent();
    },
  );
}

class _SleepSheetContent extends StatelessWidget {
  const _SleepSheetContent();

  static const _presets = <(String, int)>[
    ("5 min", 5 * 60),
    ("10 min", 10 * 60),
    ("15 min", 15 * 60),
    ("30 min", 30 * 60),
    ("1 hr", 60 * 60),
    ("1 hr 30 min", 90 * 60),
    ("2 hr", 120 * 60),
  ];

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SleepModeCubit>();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Sleep Timer",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          BlocBuilder<SleepModeCubit, SleepModeState>(
            builder: (context, state) {
              if (state is SleepModeOn) {
                return _ActiveTimerView(state: state, cubit: cubit);
              }
              return _PresetPicker(cubit: cubit);
            },
          ),
        ],
      ),
    );
  }
}

class _PresetPicker extends StatelessWidget {
  const _PresetPicker({required this.cubit});
  final SleepModeCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        for (final (label, seconds) in _SleepSheetContent._presets)
          ChoiceChip(
            label: Text(label),
            selected: false,
            onSelected: (_) => cubit.start(seconds),
          ),
        // Nice-to-have: ends the timer when the current track finishes
        ActionChip(
          avatar: const Icon(Icons.music_note, size: 16),
          label: const Text("End of song"),
          onPressed: () => cubit.startEndOfTrack(),
        ),
      ],
    );
  }
}

class _ActiveTimerView extends StatelessWidget {
  const _ActiveTimerView({required this.state, required this.cubit});
  final SleepModeOn state;
  final SleepModeCubit cubit;

  @override
  Widget build(BuildContext context) {
    final minutes = state.remainingSeconds ~/ 60;
    final seconds = state.remainingSeconds % 60;
    final progress = state.totalSeconds == 0
        ? 0.0
        : state.remainingSeconds / state.totalSeconds;
    final endTime = TimeOfDay.fromDateTime(
      DateTime.now().add(Duration(seconds: state.remainingSeconds)),
    );

    return Column(
      children: [
        SizedBox(
          width: 96,
          height: 96,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 96,
                height: 96,
                child: CircularProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  strokeWidth: 6,
                  backgroundColor: Theme.of(
                    context,
                  ).dividerColor.withValues(alpha: 0.3),
                ),
              ),
              Text(
                "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Music stops at ${endTime.format(context)}",
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: cubit.cancel,
          icon: const Icon(Icons.close, size: 18),
          label: const Text("Cancel Timer"),
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
            side: BorderSide(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ],
    );
  }
}
