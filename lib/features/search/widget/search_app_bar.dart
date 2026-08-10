import 'package:flutter/material.dart';
import 'package:tunely/features/search/widget/my_search_bar.dart';

class SearchAppBar extends StatelessWidget {
  const SearchAppBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      floating: true,
      snap: true,
      expandedHeight: 120,
      toolbarHeight: 0,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                MySearchBar(
                  controller: controller,
                  onChanged: onChanged,
                  onClear: onClear,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
