import 'package:flutter/material.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/features/home/widget/history_section.dart';
import 'package:tunely/features/home/widget/recommended_album.dart';
import 'package:tunely/features/home/widget/recommended_list.dart';

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
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoute.settings);
              },
              icon: Icon(Icons.settings),
            ),
          ],
        ),

        RecommendedList(),
        RecommendedAlbums(),
        HistorySection(),
        SliverToBoxAdapter(child: const SizedBox(height: 150)),
      ],
    );
  }
}
