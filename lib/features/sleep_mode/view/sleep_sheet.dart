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

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SleepModeCubit>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Sleep Timer",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          /// Quick options
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _timeButton(context, "5 min", 5 * 60),
              _timeButton(context, "10 min", 10 * 60),
              _timeButton(context, "15 min", 15 * 60),
              _timeButton(context, "30 min", 30 * 60),
              _timeButton(context, "60 min", 60 * 60),
            ],
          ),

          const SizedBox(height: 20),

          /// Current state
          BlocBuilder<SleepModeCubit, SleepModeState>(
            builder: (context, state) {
              if (state is SleepModeOn) {
                final minutes = state.remainingSeconds ~/ 60;
                final seconds = state.remainingSeconds % 60;

                return Column(
                  children: [
                    Text(
                      "Ends in ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        cubit.cancel();
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel Timer"),
                    ),
                  ],
                );
              }
              return const Text("No timer active");
            },
          ),
        ],
      ),
    );
  }

  Widget _timeButton(BuildContext context, String label, int seconds) {
    return ElevatedButton(
      onPressed: () {
        context.read<SleepModeCubit>().start(seconds);
        Navigator.pop(context);
      },
      child: Text(label),
    );
  }
}
