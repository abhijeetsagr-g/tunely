import 'package:flutter/material.dart';
import 'package:tunely/core/utlis/random_texts.dart';
import 'package:tunely/features/root/ui/view/home/widget/continue_listening_card.dart';
import 'package:tunely/features/root/ui/view/home/widget/recent_list.dart';
import 'package:tunely/features/root/ui/view/home/widget/recommeded_albums.dart';
import 'package:tunely/features/root/ui/view/home/widget/recommended_songs.dart';
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

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return CustomScrollView(
      key: const PageStorageKey('home_view'),
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
            IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
          ],
        ),

        const RecommendedAlbums(),
        const SliverToBoxAdapter(child: ContinueListeningCard()),
        const SliverToBoxAdapter(child: RecentList()),
        const SliverToBoxAdapter(child: TopSongsCard()),
        const RecommendedSongs(),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }
}
