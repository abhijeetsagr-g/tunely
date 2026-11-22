import 'package:flutter/material.dart';

/// Fades a sliver in when it is first inserted into the tree.
class FadeInSliver extends StatefulWidget {
  const FadeInSliver({
    super.key,
    required this.sliver,
    this.duration = const Duration(milliseconds: 220),
  });

  final Widget sliver;
  final Duration duration;

  @override
  State<FadeInSliver> createState() => _FadeInSliverState();
}

class _FadeInSliverState extends State<FadeInSliver>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return widget.sliver;
    }

    return SliverFadeTransition(opacity: _opacity, sliver: widget.sliver);
  }
}
