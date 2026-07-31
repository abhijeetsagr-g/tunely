import 'package:flutter/material.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/song_tile.dart';

class AllSongsTab extends StatelessWidget {
  const AllSongsTab({super.key, required this.tunes});

  final List<Tune> tunes;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView.builder(
        itemCount: tunes.length,
        itemBuilder: (context, index) => SongTile(tunes: tunes, index: index),
      ),
    );
  }
}
