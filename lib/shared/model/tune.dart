import 'package:audio_service/audio_service.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Tune {
  final int? songId;
  final int? albumId;
  final int? trackIndex;
  final int? artistId;
  final String path;
  final String album;
  final String title;

  final String artist;
  final List<String> artists;
  final String genre;
  final Duration duration;

  final int dateAdded;
  late Uri artUri;

  Tune({
    this.songId,
    this.artistId,
    this.artists = const [],
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

  Tune copyWith({List<String>? artists}) => Tune(
    songId: songId,
    artistId: artistId,
    trackIndex: trackIndex,
    albumId: albumId,
    path: path,
    album: album,
    title: title,
    artist: artist,
    genre: genre,
    duration: duration,
    dateAdded: dateAdded,
    artists: artists ?? this.artists,
  );

  factory Tune.fromSongModel(SongModel song) {
    return Tune(
      songId: song.id,
      artistId: song.artistId,
      path: song.data,
      title: song.title,
      dateAdded: song.dateAdded ?? 0,
      trackIndex: song.track,
      albumId: song.albumId,
      album: song.album ?? "Unknown Album",
      artist: (song.artist ?? "Unknown Artist"),
      genre: song.genre ?? "Unknown",
      duration: Duration(milliseconds: song.duration ?? 0),
    );
  }

  MediaItem toMediaItem() => MediaItem(
    id: path,
    title: title,
    artist: artists.isNotEmpty ? artists.join(' • ') : artist,
    album: album,
    duration: duration,
    artUri: artUri,
    genre: genre,
  );
}
