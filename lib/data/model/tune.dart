import 'package:audio_service/audio_service.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Tune {
  final int? songId;
  final int? albumId;
  final int? trackIndex;
  final String path;
  final String album;
  final String title;
  final String artist;
  final String genre;
  final Duration duration;
  final int dateAdded;
  late Uri artUri;

  Tune({
    this.songId,
    required this.trackIndex,
    required this.albumId,
    required this.path,
    required this.album,
    required this.title,
    required this.artist,
    required this.genre,
    required this.duration,
    required this.dateAdded,
  }) {
    artUri = Uri.parse("content://media/external/audio/albumart/$albumId");
  }

  factory Tune.fromSongModel(SongModel song) {
    return Tune(
      songId: song.id,
      path: song.data,
      title: song.title,
      dateAdded: song.dateAdded ?? 0,
      trackIndex: song.track,
      albumId: song.albumId,
      album: song.album ?? "Unknown Album",
      artist: song.artist ?? "Unknown Artist",
      genre: song.genre ?? "Unknown",
      duration: Duration(milliseconds: song.duration ?? 0),
    );
  }

  MediaItem toMediaItem() => MediaItem(
    id: path,
    title: title,
    artist: artist,
    album: album,
    duration: duration,
    artUri: artUri,
    genre: genre,
  );
}
