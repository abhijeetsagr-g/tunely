import 'package:audio_service/audio_service.dart';
import 'package:on_audio_query/on_audio_query.dart';

MediaItem songToMedia(SongModel song) => MediaItem(
  id: song.data,
  title: song.title,
  artist: song.artist ?? "Unknown",
  album: song.album,
  duration: Duration(milliseconds: song.duration ?? 0),
  artUri: Uri.parse("content://media/external/audio/albumart/${song.albumId}"),
);
