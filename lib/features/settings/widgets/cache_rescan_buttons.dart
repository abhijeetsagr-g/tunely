import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/utlis/show_snackbar.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/lyrics/cubit/lyrics_cubit.dart';
import 'package:tunely/shared/widget/action_button.dart';

class CacheRescanButtons extends StatelessWidget {
  const CacheRescanButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: ActionButton(
                icon: Icons.cached_rounded,
                label: 'Rescan',
                onTap: () {
                  context.read<LibraryCubit>().rescan();
                  popUpNotifer(context, "Tunes Updated");
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ActionButton(
                icon: Icons.delete_outline_rounded,
                label: 'Clear cache',
                onTap: () {
                  context.read<LyricsCubit>().clearCache();
                  popUpNotifer(context, "Cache has been cleared");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
