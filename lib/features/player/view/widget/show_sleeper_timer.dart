import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/player/bloc/playback_bloc.dart';

void showSleepTimerSheet(BuildContext context) {
  final presets = [5, 15, 30, 45, 60];

  showModalBottomSheet(
    context: context,
    builder: (ctx) => BlocBuilder<PlaybackBloc, PlaybackState>(
      buildWhen: (prev, curr) =>
          prev.sleepTimer != curr.sleepTimer || curr.sleepTimer != null,
      builder: (context, state) {
        if (state.sleepTimer != null) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Countdown
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text:
                            "${state.sleepTimer!.inMinutes.toString().padLeft(2, '0')}:",
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(
                              // color: Theme.of(context).primaryColor,
                              fontFeatures: [
                                const FontFeature.tabularFigures(),
                              ],
                            ),
                      ),
                      TextSpan(
                        text: (state.sleepTimer!.inSeconds % 60)
                            .toString()
                            .padLeft(2, '0'),
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(
                              // color: Theme.of(context).primaryColor,
                              fontFeatures: [
                                const FontFeature.tabularFigures(),
                              ],
                            ),
                      ),
                    ],
                  ),
                ),
                // Cancel
                TextButton.icon(
                  onPressed: () {
                    context.read<PlaybackBloc>().add(CancelSleepTimer());
                  },
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text("Cancel"),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Sleep Timer",
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: presets.map((min) {
                  final isActive = state.sleepTimer == Duration(minutes: min);
                  return ChoiceChip(
                    label: Text("$min min"),
                    selected: isActive,
                    onSelected: (_) {
                      context.read<PlaybackBloc>().add(
                        SetSleepTimer(Duration(minutes: min)),
                      );
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    ),
  );
}
