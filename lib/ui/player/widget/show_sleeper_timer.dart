import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/utlis/show_snackbar.dart';
import 'package:tunely/logic/provider/playback/playback_bloc.dart';

void showSleepTimerSheet(BuildContext context) {
  final presets = [5, 15, 30, 45, 60];

  showModalBottomSheet(
    context: context,
    builder: (ctx) => BlocBuilder<PlaybackBloc, PlaybackState>(
      buildWhen: (prev, curr) => prev.sleepTimer != curr.sleepTimer,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Sleep Timer",
                style: Theme.of(context).textTheme.titleLarge,
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

                      showSnackbar(context, "Sleep timer set for $min minutes");
                    },
                  );
                }).toList(),
              ),
              if (state.sleepTimer != null) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () =>
                      context.read<PlaybackBloc>().add(CancelSleepTimer()),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text("Cancel Timer"),
                ),
              ],
            ],
          ),
        );
      },
    ),
  );
}
