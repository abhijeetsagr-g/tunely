import 'package:flutter/material.dart';
import 'package:tunely/ui/home/widget/artist_wrap.dart';
import 'package:tunely/ui/home/widget/history_section.dart';
import 'package:tunely/ui/home/widget/recommended_album.dart';
import 'package:tunely/ui/home/widget/recommended_list.dart';

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
                  text: "your safe place",
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: Colors.grey),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),

        RecommendedList(),
        RecommendedAlbums(),
        HistorySection(),

        ArtistWrap(),
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
      ],
    );
  }
}
