import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/core/utils/settings_arguments.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/features/sleep_mode/widget/sleep_sheet.dart';

class PlayerAppBar extends StatelessWidget {
  const PlayerAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.keyboard_arrow_down),
        ),
        BlocBuilder<PlaybackBloc, PlaybackState>(
          buildWhen: (prev, curr) => prev.currentItem != curr.currentItem,
          builder: (context, state) {
            if (state.currentItem == null) return const SizedBox();
            return Expanded(
              child: InkWell(
                onTap: () {
                  final cubitState = context.read<LibraryCubit>().state;
                  if (cubitState is! LibraryLoaded) return;
                  final album = cubitState.albums.firstWhereOrNull(
                    (e) => e.id == state.currentItem?.albumId,
                  );
                  if (album == null) return;
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoute.album,
                    arguments: AlbumSettingsArguments(album),
                  );
                },
                child: Center(
                  child: Text(
                    state.currentItem?.album ?? "Album Name",
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          },
        ),

        IconButton(
          onPressed: () => showSleepSheet(context),
          icon: Icon(Icons.dark_mode_outlined),
        ),
      ],
    );
  }
}
