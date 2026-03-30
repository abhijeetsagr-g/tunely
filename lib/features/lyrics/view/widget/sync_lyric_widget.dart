import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:tunely/data/model/lyric_line.dart';
import 'package:tunely/features/player/bloc/playback_bloc.dart';

class SyncLyricWidget extends StatefulWidget {
  final List<LyricLine> lyrics;
  const SyncLyricWidget({super.key, required this.lyrics});

  @override
  State<SyncLyricWidget> createState() => _SyncLyricWidgetState();
}

class _SyncLyricWidgetState extends State<SyncLyricWidget> {
  final ItemScrollController _scrollController = ItemScrollController();
  int _activeIndex = 0;

  void _onPositionChanged(Duration position) {
    final newIndex = _findActiveIndex(position, widget.lyrics);
    if (newIndex == _activeIndex) return;

    setState(() => _activeIndex = newIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollController.scrollTo(
        index: _activeIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        alignment: 0.5,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlaybackBloc, PlaybackState>(
      listenWhen: (prev, curr) => prev.pos != curr.pos,
      listener: (context, state) => _onPositionChanged(state.pos),
      child: ScrollablePositionedList.builder(
        itemCount: widget.lyrics.length,
        itemScrollController: _scrollController,
        itemBuilder: (context, index) {
          final isActive = index == _activeIndex;
          return InkWell(
            onTap: () => context.read<PlaybackBloc>().add(
              Seek(Duration(milliseconds: widget.lyrics[index].timestamp)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
                child: Text(
                  widget.lyrics[index].text,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  int _findActiveIndex(Duration position, List<LyricLine> lyrics) {
    final ms = position.inMilliseconds;
    int low = 0;
    int high = lyrics.length - 1;
    while (low <= high) {
      final mid = (low + high) ~/ 2;
      if (lyrics[mid].timestamp <= ms) {
        if (mid == lyrics.length - 1 || lyrics[mid + 1].timestamp > ms) {
          return mid;
        }
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }
    return 0;
  }
}
