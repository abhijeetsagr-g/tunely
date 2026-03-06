import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/common/song_tile.dart';
import 'package:tunely/logic/provider/playback/playback_bloc.dart';
import 'package:tunely/ui/home/widget/album_shelf.dart';
import 'package:tunely/ui/home/widget/drop_down_sort.dart';
import 'package:tunely/ui/home/widget/header.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<PlaybackBloc, PlaybackState>(
          buildWhen: (prev, curr) => prev.tunes != curr.tunes,
          builder: (context, state) {
            if (state.tunes.isEmpty) {
              return const Center(child: Text("No songs found"));
            }
            return CustomScrollView(
              slivers: [
                // Header
                const SliverToBoxAdapter(child: Header()),

                // Albums Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Albums".toUpperCase(),
                          style: TextStyle(fontWeight: .bold, fontSize: 20),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text("See All"),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 10)),

                // Album Shelf
                const SliverToBoxAdapter(
                  child: SizedBox(height: 230, child: AlbumShelf()),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 30)),

                // Songs Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "All Songs".toUpperCase(),
                          style: TextStyle(fontWeight: .bold, fontSize: 20),
                        ),

                        // DropDown Sort Menu
                        DropDownSort(),
                      ],
                    ),
                  ),
                ),

                // Songs List
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final tune = state.tunes[index];
                    return SongTile(
                      tune: tune,
                      index: index,
                      tunes: state.tunes,
                    );
                  }, childCount: state.tunes.length),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
