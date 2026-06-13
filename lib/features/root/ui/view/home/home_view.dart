import 'package:flutter/material.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/core/utlis/random_texts.dart';
import 'package:tunely/features/root/ui/view/home/widget/daily_mix.dart';
import 'package:tunely/features/root/ui/view/home/widget/top_song_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with AutomaticKeepAliveClientMixin {
  late final String _message;

  @override
  void initState() {
    super.initState();
    _message = randomMessages();
  }

  @override
  bool get wantKeepAlive => true;

  Widget _appBar() {
    return SliverAppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              text: _message,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: Colors.grey),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.pushNamed(context, AppRoute.settings),
          icon: const Icon(Icons.settings),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CustomScrollView(
      key: const PageStorageKey('home_view'),
      slivers: [
        _appBar(),

        // TODO: Recently Played Column, With A title, a grid of song tiles and album art, create a new widget
        // TODO: DailyMix, already exist, elevate it wiith a card
        // TODO: Top Songs Carosal that slides to show more songs, (TOTAL of 5 songs to be gone through, then one big carousal to ask OPEN ALL TOP SONGS! Write the number )
        // TODO: Top Albums Card, Use AlbumCard Widget
      ],
    );
  }
}
