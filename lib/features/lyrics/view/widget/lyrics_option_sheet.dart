import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/data/model/tune.dart';
import 'package:tunely/features/lyrics/cubit/lyric_cubit.dart';
import 'package:tunely/features/lyrics/view/widget/lyrics_search_sheet.dart';

class LyricsOptionsSheet {
  static void show(BuildContext context, Tune? tune) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.replay),
              title: const Text("Reload lyrics"),
              onTap: () {
                Navigator.pop(context);
                if (tune != null) {
                  context.read<LyricCubit>().reloadLyrics(tune);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text("Search lyrics"),
              onTap: () {
                Navigator.pop(context);
                if (tune != null) {
                  LyricsSearchSheet.show(context, tune);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
