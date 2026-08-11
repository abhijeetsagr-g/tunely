import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:tunely/features/playlist/model/playlist.dart';
import 'package:tunely/shared/model/artist.dart';
import 'package:tunely/shared/model/tune.dart';

class AlbumSettingsArguments {
  final AlbumModel album;

  const AlbumSettingsArguments(this.album);
}

class ArtistSettingsArguments {
  final Artist artist;
  const ArtistSettingsArguments(this.artist);
}

class PlaylistSettingsArguments {
  final Playlist playlist;
  const PlaylistSettingsArguments({required this.playlist});
}

class CreatePlaylistSettingsArguments {
  final List<Tune> tunes;
  const CreatePlaylistSettingsArguments({this.tunes = const []});
}
