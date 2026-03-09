import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/logic/provider/playback/playback_bloc.dart';

class DropDownSort extends StatelessWidget {
  const DropDownSort({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TuneSortType>(
      initialValue: context.read<PlaybackBloc>().state.type,
      onSelected: (sort) => context.read<PlaybackBloc>().add(SortTunes(sort)),
      itemBuilder: (_) => const [
        PopupMenuItem(value: TuneSortType.title, child: Text("Title")),
        PopupMenuItem(value: TuneSortType.artist, child: Text("Artist")),
        PopupMenuItem(
          value: TuneSortType.recentlyAdded,
          child: Text("Sort By: Recently Added"),
        ),
        PopupMenuItem(value: TuneSortType.album, child: Text("Albums")),
      ],
      child: Text(switch (context.select<PlaybackBloc, TuneSortType>(
        (b) => b.state.type,
      )) {
        TuneSortType.title => "Title",
        TuneSortType.artist => "Artist",
        TuneSortType.recentlyAdded => "Recently Added",
        TuneSortType.album => "Album",
      }, style: const TextStyle(fontSize: 14)),
    );
  }
}
