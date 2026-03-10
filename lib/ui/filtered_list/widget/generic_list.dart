import 'package:flutter/material.dart';
import 'package:tunely/core/config/app_route.dart';
import 'package:tunely/core/extensions/title_case.dart';

class Item {
  final String name;
  final IconData icon;
  final int count;
  final int id;
  const Item(this.name, this.icon, this.count, this.id);
}

class GenericList extends StatelessWidget {
  const GenericList({super.key, required this.items, required this.type});
  final List<Item> items;
  final FilterType type;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const Center(child: Text("Nothing found"));
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withAlpha(1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(item.icon, color: Theme.of(context).primaryColor),
          ),
          title: Text(
            item.name.toTitleCase(),
            style: Theme.of(context).textTheme.bodyLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            "${item.count} tracks",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          onTap: () {},
        );
      },
    );
  }
}
