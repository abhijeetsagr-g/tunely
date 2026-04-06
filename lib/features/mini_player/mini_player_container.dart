import 'package:flutter/material.dart';
import 'package:tunely/features/mini_player/mini_player_state.dart';

class MiniPlayerContainer extends StatelessWidget {
  final Widget child;

  const MiniPlayerContainer({super.key, required this.child});

  bool _isKeyboardOpen(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: miniPlayerVisible,
      builder: (context, visible, _) {
        final keyboardOpen = _isKeyboardOpen(context);

        if (!visible || keyboardOpen) {
          return const SizedBox.shrink();
        }

        return ValueListenableBuilder<double>(
          valueListenable: miniPlayerBottom,
          builder: (context, bottom, _) {
            return Positioned(left: 0, right: 0, bottom: bottom, child: child);
          },
        );
      },
    );
  }
}
