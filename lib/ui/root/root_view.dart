import 'package:flutter/material.dart';
import 'package:tunely/core/common/mini_player_state.dart';
import 'package:tunely/ui/home/home_view.dart';
import 'package:tunely/ui/mini_player/mini_player.dart';

class RootView extends StatefulWidget {
  const RootView({super.key});

  @override
  State<RootView> createState() => _RootViewState();
}

class _RootViewState extends State<RootView> {
  OverlayEntry? _entry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _insert());
  }

  void _insert() {
    _entry = OverlayEntry(
      builder: (_) => ValueListenableBuilder<bool>(
        valueListenable: miniPlayerVisible,
        builder: (_, visible, _) => ValueListenableBuilder<double>(
          valueListenable: miniPlayerBottom,
          builder: (_, bottom, _) => AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            bottom: visible ? bottom : -100,
            left: 12,
            right: 12,
            child: const MiniPlayer(),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_entry!);
  }

  @override
  void dispose() {
    _entry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeView(),

      // Home VIew
      // Library View
      // Search VIew
    );
  }
}
