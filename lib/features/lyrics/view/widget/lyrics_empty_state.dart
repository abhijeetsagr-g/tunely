import 'package:flutter/material.dart';

class LyricsLoadingState extends StatelessWidget {
  const LyricsLoadingState({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class LyricsNotFoundState extends StatelessWidget {
  const LyricsNotFoundState({super.key});
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.music_off_rounded, size: 40, color: Colors.white38),
        SizedBox(height: 12),
        Text(
          'No lyrics found',
          style: TextStyle(color: Colors.white54, fontSize: 15),
        ),
      ],
    ),
  );
}

class LyricsInstrumentalState extends StatelessWidget {
  const LyricsInstrumentalState({super.key});
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.piano_rounded, size: 40, color: Colors.white38),
        SizedBox(height: 12),
        Text(
          'Instrumental',
          style: TextStyle(color: Colors.white54, fontSize: 15),
        ),
      ],
    ),
  );
}

class LyricsPlainView extends StatelessWidget {
  const LyricsPlainView({super.key, required this.plain});
  final String plain;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
    child: Text(
      plain,
      style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.8),
    ),
  );
}
