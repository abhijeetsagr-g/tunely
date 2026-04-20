import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/core/utlis/artist_praser.dart';
import 'package:tunely/features/music_management/model/management_settings.dart';
import 'package:tunely/shared/model/tune.dart';

class TuneParser {
  static List<Tune> parse(List<SongModel> songs, ManagementSettings settings) {
    return songs
        .where((song) => (song.duration ?? 0) >= settings.minDurationMs)
        .where(
          (song) => !settings.excludedFolders.any(
            (folder) => song.data.startsWith(folder),
          ),
        )
        .map((song) {
          final tune = Tune.fromSongModel(song);
          final artists = ArtistParser.parse(
            song.artist ?? 'Unknown Artist',
            settings.artistDelimiters,
          );
          return tune.copyWith(artists: artists);
        })
        .toList();
  }
}
