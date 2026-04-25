import 'package:flutter/material.dart';
import 'package:tunely/features/library/ui/view/library_view.dart';
import 'package:tunely/features/playback/view/mini_player/mini_player.dart';
import 'package:tunely/features/playback/view/mini_player/mini_player_state.dart';
import 'package:tunely/features/root/ui/view/home/home_view.dart';
import 'package:tunely/features/root/ui/view/widget/bottom_nav.dart';
import 'package:tunely/features/search/view/search_view.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  OverlayEntry? _entry;

  late final PageController _pageController;
  int _currentIndex = 1;
  final List<Widget> _views = const [LibraryView(), HomeView(), SearchView()];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateRootBottom();
      _insert();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _entry?.dispose();
    super.dispose();
  }

  void _insert() {
    _entry = OverlayEntry(
      builder: (context) {
        final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

        return ValueListenableBuilder<bool>(
          valueListenable: miniPlayerVisible,
          builder: (_, visible, _) {
            return ValueListenableBuilder<double>(
              valueListenable: miniPlayerBottom,
              builder: (_, bottom, _) {
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,

                  bottom: (visible && !keyboardOpen) ? bottom : -120,

                  left: 12,
                  right: 12,
                  child: const MiniPlayer(),
                );
              },
            );
          },
        );
      },
    );

    Overlay.of(context).insert(_entry!);
  }

  void _updateRootBottom() {
    final mq = MediaQuery.of(context);
    const navBarHeight = 80.0;
    final bottomInset = mq.padding.bottom;
    miniPlayerBottom.value = navBarHeight + bottomInset + 8;
  }

  void _onNavTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        children: _views,
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onNavTap: _onNavTap,
      ),
    );
  }
}
