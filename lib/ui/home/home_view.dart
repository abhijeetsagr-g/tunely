import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/core/utlis/song_to_media.dart';
import 'package:tunely/logic/service/audio_query_service.dart';
import 'package:tunely/logic/service/playback_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.service});
  final PlaybackService service;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<SongModel> _songs = [];

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    final songs = await AudioQueryService.getSong();

    setState(() {
      _songs = songs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _songs.length,
        itemBuilder: (context, index) {
          final song = _songs[index];
          return InkWell(
            onTap: () => widget.service.playQueue(
              _songs.map((song) => songToMedia(song)).toList(),
              index,
            ),
            child: ListTile(
              title: Text(song.title),
              subtitle: Text(song.artist ?? "Unknown"),
            ),
          );
        },
      ),
    );
  }
}
