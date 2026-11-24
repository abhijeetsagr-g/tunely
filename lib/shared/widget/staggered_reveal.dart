import 'package:flutter/material.dart';
import 'package:tunely/core/config/app_theme.dart';

/// Fades and slides [child] in once, optionally staggered by [index].
///
/// The reveal runs exactly once per [State] — i.e. when the row is first
/// inserted into the tree. Parent rebuilds (playback progress, selection
/// changes, bloc updates) do not restart it. Give rows stable keys when they
/// can reorder so their state (and completed reveal) follows them.
class StaggeredReveal extends StatefulWidget {
  const StaggeredReveal({
    super.key,
    required this.child,
    this.index = 0,
    this.delayStep = AppTheme.revealDelayStep,
    this.duration = AppTheme.revealDuration,
    this.maxStaggerIndex = 12,
    this.offset = 10,
  });

  final Widget child;

  /// Position of the row; drives the entrance delay.
  final int index;

  /// Delay added per row, capped by [maxStaggerIndex].
  final Duration delayStep;

  /// Fade/slide duration for a single row.
  final Duration duration;

  /// Rows past this index are rendered as-is (no reveal), so long lists never
  /// wait seconds for their tail to appear while scrolling.
  final int maxStaggerIndex;

  /// Vertical travel in logical pixels.
  final double offset;

  @override
  State<StaggeredReveal> createState() => _StaggeredRevealState();
}

class _StaggeredRevealState extends State<StaggeredReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _reveal;
  bool _started = false;

  /// Rows past [StaggeredReveal.maxStaggerIndex] appear instantly — they are
  /// normally below the fold, and delaying them would make scrolling feel
  /// sluggish.
  bool get _skip => widget.index > widget.maxStaggerIndex;

  @override
  void initState() {
    super.initState();

    final step = widget.index.clamp(0, widget.maxStaggerIndex).toInt();
    final delay = widget.delayStep * step;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration + delay,
    );

    final totalMicros = _controller.duration!.inMicroseconds;
    final start = totalMicros == 0 ? 0.0 : delay.inMicroseconds / totalMicros;
    _reveal = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, 1, curve: AppTheme.enter),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    if (_skip || MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_skip) return widget.child;

    return AnimatedBuilder(
      animation: _reveal,
      child: widget.child,
      builder: (context, child) {
        final value = _reveal.value;
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, widget.offset * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }
}
