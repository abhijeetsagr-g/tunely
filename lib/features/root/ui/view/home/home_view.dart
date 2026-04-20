import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/utlis/random_texts.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/features/root/ui/view/home/widget/continue_listening_card.dart';
import 'package:tunely/features/root/ui/view/home/widget/recent_list.dart';
import 'package:tunely/features/root/ui/view/home/widget/recommeded_albums.dart';
import 'package:tunely/features/root/ui/view/home/widget/recommended_songs.dart';
import 'package:tunely/features/root/ui/view/home/widget/top_song_card.dart';
import 'package:tunely/shared/widget/artist_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          centerTitle: true,
          title: Text.rich(
            TextSpan(
              text: "Tunely\n",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: randomMessages(),
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: Colors.grey),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),

        RecommendedAlbums(),
        SliverToBoxAdapter(child: ContinueListeningCard()),
        SliverToBoxAdapter(child: RecentList()),
        SliverToBoxAdapter(child: TopSongsCard()),
        RecommendedSongs(),
      ],
    );
  }
}
