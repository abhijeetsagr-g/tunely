import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import 'package:tunely/features/credits/model/credit_entry.dart';
import 'package:tunely/features/credits/widget/credit_entry_tile.dart';

class RollingCreditsList extends StatefulWidget {
  const RollingCreditsList({
    super.key,
    required this.entries,
    this.pixelsPerSecond = 55,
    this.highlightFraction = 0.38,
    this.rowHeight = 72,
  });

  final List<CreditEntry> entries;

  /// Roll speed. Bump it up for a faster crawl.
  final double pixelsPerSecond;

  /// Where the highlight line sits vertically (0 = top, 1 = bottom).
  final double highlightFraction;

  /// Vertical space each credit line gets. Smaller = tighter roll.
  final double rowHeight;

  @override
  State<RollingCreditsList> createState() => _RollingCreditsListState();
}

class _RollingCreditsListState extends State<RollingCreditsList>
    with SingleTickerProviderStateMixin {
  static const Duration _userScrollCooldown = Duration(seconds: 3);

  final ScrollController _scrollController = ScrollController();

  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  bool _playing = true;
  bool _finished = false;
  int _activeIndex = 0;
  DateTime? _lastUserScroll;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_syncActiveIndex);
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _userScrollingRecently {
    final last = _lastUserScroll;
    if (last == null) return false;
    return DateTime.now().difference(last) < _userScrollCooldown;
  }

  void _onTick(Duration elapsed) {
    final dt =
        (elapsed - _lastElapsed).inMicroseconds /
        Duration.microsecondsPerSecond;
    _lastElapsed = elapsed;

    if (!_playing || _finished || dt <= 0) return;
    if (!_scrollController.hasClients || _userScrollingRecently) return;

    final position = _scrollController.position;
    final next = position.pixels + widget.pixelsPerSecond * dt;

    if (next >= position.maxScrollExtent) {
      _scrollController.jumpTo(position.maxScrollExtent);
      setState(() {
        _finished = true;
        _playing = false;
      });
      return;
    }

    _scrollController.jumpTo(next);
  }

  void _syncActiveIndex() {
    if (!mounted || !_scrollController.hasClients) return;

    final index = (_scrollController.offset / widget.rowHeight).round().clamp(
      0,
      widget.entries.length - 1,
    );

    if (index != _activeIndex) {
      setState(() => _activeIndex = index);
    }
  }

  void _togglePlayback() {
    if (_finished) {
      _restart();
      return;
    }
    setState(() => _playing = !_playing);
  }

  void _restart() {
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    setState(() {
      _finished = false;
      _playing = true;
      _activeIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final viewportHeight = constraints.maxHeight;

            return NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is UserScrollNotification &&
                    notification.direction != ScrollDirection.idle) {
                  _lastUserScroll = DateTime.now();
                }
                return false;
              },
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.16, 0.70, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.white,
                    Colors.white,
                    Colors.transparent,
                  ],
                ).createShader(bounds),
                blendMode: BlendMode.dstIn,
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const ClampingScrollPhysics(),
                  itemExtent: widget.rowHeight,
                  // The top padding puts the first row on the highlight line at
                  // offset 0; the bottom padding lets the last row scroll off.
                  padding: EdgeInsets.only(
                    top: viewportHeight * widget.highlightFraction,
                    bottom: viewportHeight,
                  ),
                  itemCount: widget.entries.length,
                  itemBuilder: (context, index) => CreditEntryTile(
                    entry: widget.entries[index],
                    isActive: index == _activeIndex,
                    isPast: index < _activeIndex,
                  ),
                ),
              ),
            );
          },
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _finished
                ? FilledButton.tonalIcon(
                    key: const ValueKey('replay'),
                    onPressed: _restart,
                    icon: const Icon(Icons.replay, size: 18),
                    label: const Text('Replay'),
                  )
                : IconButton.filledTonal(
                    key: const ValueKey('play-pause'),
                    onPressed: _togglePlayback,
                    icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
                  ),
          ),
        ),
      ],
    );
  }
}
