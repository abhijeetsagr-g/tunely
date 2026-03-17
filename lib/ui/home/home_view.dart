import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/common/song_tile.dart';
import 'package:tunely/core/config/app_route.dart';
import 'package:tunely/logic/provider/playback/playback_bloc.dart';
import 'package:tunely/ui/home/widget/album_shelf.dart';
import 'package:tunely/ui/home/widget/drop_down_sort.dart';
import 'package:tunely/ui/home/widget/header.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: Header()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Albums".toUpperCase(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton.icon(
                    icon: Icon(Icons.album),
                    label: const Text("See All"),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.filtered,
                        arguments: FilteredListArgs(.album),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 200, child: AlbumShelf()),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "All Songs".toUpperCase(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const DropDownSort(),
                ],
              ),
            ),
          ),

          BlocBuilder<PlaybackBloc, PlaybackState>(
            buildWhen: (prev, curr) => prev.sortedTunes != curr.sortedTunes,
            builder: (context, state) {
              if (state.sortedTunes.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(child: Text("No songs found")),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final tune = state.sortedTunes[index];
                  return SongTile(
                    tune: tune,
                    index: index,
                    tunes: state.sortedTunes,
                  );
                }, childCount: state.sortedTunes.length),
              );
            },
          ),
        ],
      ),
    );
  }
}
