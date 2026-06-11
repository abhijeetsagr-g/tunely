import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/shared/model/artist.dart';
import 'package:tunely/shared/model/tune.dart';

sealed class RecentItem {
  String get title;
  String? get subtitle;
}

class RecentSongItem extends RecentItem {
  final Tune tune;

  RecentSongItem(this.tune);

  @override
  String get title => tune.title;

  @override
  String? get subtitle => tune.artist;
}

class RecentAlbumItem extends RecentItem {
  final AlbumModel album;

  RecentAlbumItem(this.album);

  @override
  String get title => album.album;

  @override
  String? get subtitle => album.artist;
}

class RecentArtistItem extends RecentItem {
  final Artist artist;

  RecentArtistItem(this.artist);

  @override
  String get title => artist.artist;

  @override
  String? get subtitle => '${artist.tunes.length} songs';
}
