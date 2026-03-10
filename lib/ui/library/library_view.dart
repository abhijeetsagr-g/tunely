import 'package:flutter/material.dart';
import 'package:tunely/core/config/app_route.dart';

class LibraryView extends StatelessWidget {
  const LibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _LibraryItem(type: .album, title: "Albums", icon: Icons.album),
      _LibraryItem(type: .playlist, title: "Playlist", icon: Icons.queue_music),
      _LibraryItem(title: "Genres", icon: Icons.category, type: .genres),
      _LibraryItem(title: "Artists", icon: Icons.person, type: .artists),
    ];

    return SafeArea(
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.filtered,
                arguments: FilteredListArgs(item.type),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withAlpha(8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item.icon,
                    size: 36,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LibraryItem {
  final String title;
  final IconData icon;
  final FilterType type;

  const _LibraryItem({
    required this.type,
    required this.title,
    required this.icon,
  });
}
