import 'package:flutter/material.dart';

class SettingsAppBar extends StatelessWidget {
  final Color accent;

  const SettingsAppBar({super.key, required this.accent});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.keyboard_arrow_down, size: 20),
      ),
      title: Text('Settings', style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
