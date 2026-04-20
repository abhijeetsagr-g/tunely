import 'package:flutter/material.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/song_tile.dart';

class SongsView extends StatelessWidget {
  const SongsView({super.key, required this.tunes});
  final List<Tune> tunes;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tunes.length,
      itemBuilder: (context, index) => SongTile(tunes: tunes, index: index),
    );
  }
}
