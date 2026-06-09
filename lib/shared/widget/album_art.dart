import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';

class AlbumArt extends StatefulWidget {
  const AlbumArt({super.key, this.id, this.type, required this.size});

  final int? id;
  final ArtworkType? type;
  final Size size;

  @override
  State<AlbumArt> createState() => _AlbumArtState();
}

class _AlbumArtState extends State<AlbumArt> {
  Uint8List? _bytes;
  final _audioQuery = OnAudioQuery();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(AlbumArt old) {
    super.didUpdateWidget(old);
    if (old.id != widget.id) _load();
  }

  Future<void> _load() async {
    final id = widget.id;
    final type = widget.type;
    if (id == null || type == null) {
      if (mounted) setState(() => _bytes = null);
      return;
    }
    try {
      final bytes = await _audioQuery.queryArtwork(id, type, size: 320);
      if (mounted) setState(() => _bytes = bytes);
    } catch (_) {
      if (mounted) setState(() => _bytes = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: widget.size.width,
        height: widget.size.height,
        child: _bytes != null
            ? Image.memory(_bytes!, fit: BoxFit.cover, gaplessPlayback: true)
            : _Placeholder(size: widget.size),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.size});
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.music_note, color: Colors.white54),
    );
  }
}
