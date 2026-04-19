import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:palette_generator/palette_generator.dart';

class AlbumArt extends StatefulWidget {
  const AlbumArt({
    super.key,
    required this.id,
    required this.size,
    required this.type,
  });
  final int id;
  final Size size;
  final ArtworkType type;

  @override
  State<AlbumArt> createState() => _AlbumArtState();
}

class _AlbumArtState extends State<AlbumArt> {
  Color? _shadowColor;

  @override
  void initState() {
    super.initState();
    _extractColor();
  }

  Future<void> _extractColor() async {
    final artwork = await OnAudioQuery().queryArtwork(
      widget.id,
      ArtworkType.AUDIO,
      size: 50,
    );
    if (artwork == null || !mounted) return;
    final palette = await PaletteGenerator.fromImageProvider(
      MemoryImage(artwork),
    );
    if (!mounted) return;
    setState(() {
      _shadowColor = palette.dominantColor?.color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: widget.size.width,
      height: widget.size.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? []
            : _shadowColor != null
            ? [
                BoxShadow(
                  color: _shadowColor!.withAlpha(60),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: QueryArtworkWidget(
        id: widget.id,
        type: widget.type,
        artworkFit: BoxFit.cover,
        keepOldArtwork: true,
        artworkBorder: BorderRadius.circular(16),
        nullArtworkWidget: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.music_note, color: Colors.white54),
        ),
      ),
    );
  }
}
