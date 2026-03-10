import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/logic/provider/query/query_state.dart';
import 'package:tunely/logic/service/audio_query_service.dart';

class QueryCubit extends Cubit<QueryState> {
  final _service = AudioQueryService();

  QueryCubit()
    : super(
        QueryState(
          albums: [],
          artists: [],
          genres: [],
          playlists: [],
          filteredSongs: [],
          isLoading: false,
        ),
      );

  // Validation
  bool _isValid(SongModel song) {
    if (song.data.isEmpty) return false;
    if (!File(song.data).existsSync()) return false;
    if (song.duration == null || song.duration! < 1000) return false;
    return true;
  }

  Future<void> initialLoad() async {
    emit(state.copyWith(isLoading: true));
    try {
      final albums = await _service.getAlbums();
      final artists = await _service.getArtists();
      final genres = await _service.getGenres();
      final playlists = await _service.getPlaylists();
      emit(
        state.copyWith(
          albums: albums,
          artists: artists,
          genres: genres,
          playlists: playlists,
          isLoading: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<List<SongModel>> getAllSongs() async {
    final songs = await _service.getSong();
    return songs.where(_isValid).toList();
  }

  Future<void> getFilteredSongs(AudiosFromType type, int targetId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final songs = await _service.getFilteredSongs(type, targetId);
      emit(
        state.copyWith(
          filteredSongs: songs.where(_isValid).toList(),
          isLoading: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  AlbumModel? getAlbumById(int id) =>
      state.albums.firstWhere((a) => a.id == id);

  ArtistModel? getArtistById(int id) =>
      state.artists.firstWhere((a) => a.id == id);

  GenreModel? getGenreById(int id) =>
      state.genres.firstWhere((g) => g.id == id);

  PlaylistModel? getPlaylistById(int id) =>
      state.playlists.firstWhere((p) => p.id == id);

  List<AlbumModel> searchAlbums(String query) => state.albums
      .where((a) => a.album.toLowerCase().contains(query.toLowerCase()))
      .toList();

  List<ArtistModel> searchArtists(String query) => state.artists
      .where((a) => a.artist.toLowerCase().contains(query.toLowerCase()))
      .toList();
}
