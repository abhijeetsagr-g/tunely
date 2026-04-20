import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:tunely/features/lyrics/model/lyrics_result.dart';
import 'package:tunely/features/lyrics/view/widget/lyrics_line_tile.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';

class SyncedLyricsList extends StatefulWidget {
  const SyncedLyricsList({super.key, required this.result});
  final LyricsResult result;

  @override
  State<SyncedLyricsList> createState() => _SyncedLyricsListState();
}

class _SyncedLyricsListState extends State<SyncedLyricsList> {
  final ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _positionsListener =
      ItemPositionsListener.create();

  int _activeIndex = 0;
  DateTime? _lastUserScroll;

  static const _cooldown = Duration(seconds: 4);

  int _findActiveIndex(Duration position) {
    final posMs = position.inMilliseconds - widget.result.offsetMs;
    int result = 0;
    for (int i = 0; i < widget.result.synced.length; i++) {
      if (widget.result.synced[i].timestamp <= posMs) {
        result = i;
      } else {
        break;
      }
    }
    return result;
  }

  void _onPositionChanged(Duration position) {
    final newIndex = _findActiveIndex(position);
    if (newIndex == _activeIndex) return;
    setState(() => _activeIndex = newIndex);

    final cooldownExpired =
        _lastUserScroll == null ||
        DateTime.now().difference(_lastUserScroll!) > _cooldown;
    if (!cooldownExpired) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.isAttached) return;
      _scrollController.scrollTo(
        index: _activeIndex,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        alignment: 0.35,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlaybackBloc, PlaybackState>(
      listenWhen: (prev, curr) =>
          prev.position != curr.position && curr.currentItem != null,
      listener: (_, state) => _onPositionChanged(state.position),
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n is UserScrollNotification) _lastUserScroll = DateTime.now();
          return false;
        },
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.08, 0.88, 1.0],
            colors: [
              Colors.transparent,
              Colors.white,
              Colors.white,
              Colors.transparent,
            ],
          ).createShader(bounds),
          blendMode: BlendMode.dstIn,
          child: ScrollablePositionedList.builder(
            itemScrollController: _scrollController,
            itemPositionsListener: _positionsListener,
            itemCount: widget.result.synced.length,
            padding: const EdgeInsets.symmetric(vertical: 80),
            itemBuilder: (context, index) => LyricsLineTile(
              onTap: () {
                final ms =
                    widget.result.synced[index].timestamp +
                    widget.result.offsetMs;

                context.read<PlaybackBloc>().add(
                  SeekEvent(Duration(milliseconds: ms)),
                );
              },
              line: widget.result.synced[index],
              isActive: index == _activeIndex,
              isPast: index < _activeIndex,
            ),
          ),
        ),
      ),
    );
  }
}
