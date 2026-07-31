import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/music_management/model/management_settings.dart';
import 'package:tunely/features/playlist/service/playlist_service.dart';
import 'package:tunely/shared/model/tune.dart';

part 'playlist_detail_state.dart';

class PlaylistDetailCubit extends Cubit<PlaylistDetailState> {
  final int playlistId;
  final PlaylistService _service;
  ManagementSettings? _settings;

  PlaylistDetailCubit({
    required this.playlistId,
    required PlaylistService service,
  }) : _service = service,
       super(PlaylistDetailInitial());

  Future<void> loadSongs(ManagementSettings settings) async {
    _settings = settings;
    emit(PlaylistDetailLoading());
    try {
      final tunes = await _service.getSongsFromPlaylist(playlistId, settings);
      emit(PlaylistDetailLoaded(tunes: tunes));
    } catch (e) {
      emit(PlaylistDetailError(error: e.toString()));
    }
  }

  Future<void> removeSong(int songId) async {
    if (state is! PlaylistDetailLoaded) return;
    final loaded = state as PlaylistDetailLoaded;
    final updated = List<Tune>.from(loaded.tunes)
      ..removeWhere((t) => t.songId == songId);
    emit(loaded.copyWith(tunes: updated));
    await _service.removeTune(playlistId, songId);
  }

  Future<void> addSongs(List<int> songIds) async {
    if (songIds.isEmpty) return;
    await _service.addTunes(playlistId, songIds);
    if (_settings != null) await loadSongs(_settings!);
  }

}
