import 'package:flutter/material.dart';
import 'package:tunely/ui/root/widget/mini_player.dart';

final isPlayerOpen = ValueNotifier<bool>(false);
final miniPlayerBottom = ValueNotifier<double>(kBottomNavigationBarHeight + 28);

class MiniPlayerOverlay extends StatelessWidget {
  const MiniPlayerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isPlayerOpen,
      builder: (context, open, _) {
        if (open) return const SizedBox.shrink();
        return ValueListenableBuilder<double>(
          valueListenable: miniPlayerBottom,
          builder: (context, bottom, _) => Positioned(
            bottom: bottom,
            left: 8,
            right: 8,
            child: MiniPlayer(),
          ),
        );
      },
    );
  }
}
