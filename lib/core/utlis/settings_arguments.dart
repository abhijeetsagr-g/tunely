import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/shared/model/artist.dart';

class AlbumSettingsArguments {
  final AlbumModel album;

  const AlbumSettingsArguments(this.album);
}

class ArtistSettingsArguments {
  final Artist artist;
  const ArtistSettingsArguments(this.artist);
}
