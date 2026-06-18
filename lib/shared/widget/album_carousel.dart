import 'dart:async';
import 'package:flutter/material.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/album_art.dart';

class AlbumCarousel extends StatefulWidget {
  const AlbumCarousel({super.key, required this.tunes, required this.title});

  final List<Tune> tunes;
  final String title;

  @override
  State<AlbumCarousel> createState() => _AlbumCarouselState();
}

class _AlbumCarouselState extends State<AlbumCarousel> {
  final _controller = PageController();
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    if (widget.tunes.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (_controller.hasClients) {
          final next = (_currentPage + 1) % widget.tunes.length;
          _controller.animateToPage(
            next,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
          _currentPage = next;
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tunes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.queue_music_rounded, size: 52),
            const SizedBox(height: 16),
            Text(widget.title),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.tunes.length,
              itemBuilder: (context, index) {
                final tune = widget.tunes[index];
                return AlbumArt(
                  id: tune.songId,
                  type: ArtworkType.AUDIO,
                  size: size,
                );
              },
            ),
            Positioned.fill(
              child: Container(
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                padding: const EdgeInsets.only(bottom: 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (widget.tunes.length > 1) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.tunes.length > 5 ? 5 : widget.tunes.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width:
                                _currentPage %
                                        (widget.tunes.length > 5
                                            ? 5
                                            : widget.tunes.length) ==
                                    i
                                ? 10
                                : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
