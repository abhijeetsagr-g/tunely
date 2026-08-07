import 'package:flutter/material.dart';

/// Full-screen animated gradient driven by a dominant [color].
///
/// Fades from the previous color to the new one whenever [color] changes.
/// Meant to be placed inside a [Stack].
class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({super.key, required this.color});

  final Color? color;

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _animation;

  Color _currentColor = Colors.transparent;
  Color _previousColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic,
    );

    // Seed with surface color so there's no transparent flash on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final surface = Theme.of(context).colorScheme.surface;
      _previousColor = surface;
      _currentColor = widget.color ?? surface;
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(AnimatedGradientBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color == widget.color) return;
    final color = widget.color;
    if (color == null) return;

    _previousColor =
        Color.lerp(_previousColor, _currentColor, _animation.value) ??
        _currentColor;
    _currentColor = color;
    _animController.forward(from: 0);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final blended =
            Color.lerp(_previousColor, _currentColor, _animation.value) ??
            _currentColor;

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final surface = Theme.of(context).colorScheme.surface;

        return SizedBox.expand(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.22, 0.50, 0.78, 1.0],
                colors: [
                  blended.withAlpha(isDark ? 120 : 80),
                  blended.withAlpha(isDark ? 70 : 45),
                  blended.withAlpha(isDark ? 33 : 20),
                  surface.withAlpha(isDark ? 40 : 6),
                  surface,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
