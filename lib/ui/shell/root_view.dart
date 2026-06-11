import 'package:flutter/material.dart';

class RootView extends StatefulWidget {
  const RootView({super.key});

  @override
  State<RootView> createState() => _RootViewState();
}

class _RootViewState extends State<RootView>
    with SingleTickerProviderStateMixin {
  final _pageController = PageController();
  int _currentPage = 1;
  bool _fabExpanded = false;

  late final AnimationController _fabAnim;

  @override
  void initState() {
    super.initState();
    _fabAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabAnim.dispose();
    super.dispose();
  }

  void _switchPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    setState(() => _currentPage = page);
    _collapseFab();
  }

  void _expandFab() {
    setState(() => _fabExpanded = true);
    _fabAnim.forward();
  }

  void _collapseFab() {
    _fabAnim.reverse();
    setState(() => _fabExpanded = false);
  }

  void _onSwipe(DragEndDetails details) {
    final v = details.primaryVelocity ?? 0;
    if (v < -0.5 && _currentPage < 2) _switchPage(_currentPage + 1);
    if (v > 0.5 && _currentPage > 0) _switchPage(_currentPage - 1);
  }

  @override
  Widget build(BuildContext context) {
    const miniH = 72.0;
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (i) => setState(() => _currentPage = i),
            children: [
              _Page(label: 'Home', icon: Icons.home, color: Colors.blueGrey),
              _Page(
                label: 'Library',
                icon: Icons.library_music,
                color: Colors.indigo,
              ),
              _Page(label: 'Search', icon: Icons.search, color: Colors.teal),
            ],
          ),

          // mini player bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: miniH,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(top: BorderSide(color: theme.dividerColor)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: theme.colorScheme.primaryContainer,
                    ),
                    child: const Icon(Icons.music_note),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'No song playing',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.play_arrow_rounded),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),

          // morphing FAB
          Positioned(
            right: 16,
            bottom: miniH + 16,
            child: _fabExpanded ? _buildExpanded() : _buildCollapsed(),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsed() {
    return GestureDetector(
      onHorizontalDragEnd: _onSwipe,
      child: FloatingActionButton(
        onPressed: _expandFab,
        child: const Icon(Icons.explore),
      ),
    );
  }

  Widget _buildExpanded() {
    final pages = [
      (Icons.home, 'Home', 0),
      (Icons.library_music, 'Library', 1),
      (Icons.search, 'Search', 2),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...pages.map((p) {
          final (icon, label, index) = p;
          final active = _currentPage == index;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (active)
                  Text(
                    label,
                    style: const TextStyle(fontSize: 10, color: Colors.white70),
                  ),
                FloatingActionButton.small(
                  heroTag: 'fab_$index',
                  backgroundColor: active
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  onPressed: () => _switchPage(index),
                  child: Icon(icon, color: active ? Colors.white : null),
                ),
              ],
            ),
          );
        }),
        FloatingActionButton.small(
          heroTag: 'fab_close',
          onPressed: _collapseFab,
          child: const Icon(Icons.close),
        ),
      ],
    );
  }
}

class _Page extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _Page({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.withAlpha(25),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: color.withAlpha(100)),
            const SizedBox(height: 16),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
