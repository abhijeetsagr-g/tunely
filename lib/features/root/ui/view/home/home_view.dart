import 'package:flutter/material.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/core/utlis/random_texts.dart';
import 'package:tunely/features/root/ui/view/home/widget/continue_listening_card.dart';
import 'package:tunely/features/root/ui/view/home/widget/daily_mix.dart';
import 'package:tunely/features/root/ui/view/home/widget/recommeded_albums.dart';
import 'package:tunely/features/root/ui/view/home/widget/top_songs_section.dart';

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
        SliverToBoxAdapter(child: const ContinueListeningCard()),
        SliverToBoxAdapter(child: const TopSongsSection()),
        const DailyMixWidget(),
        const RecommendedAlbums(),
        SliverToBoxAdapter(child: const SizedBox(height: 100)),
      ],
    );
  }
}
