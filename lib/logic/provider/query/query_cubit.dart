import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/data/model/tune.dart';
import 'package:tunely/logic/provider/query/query_state.dart';
import 'package:tunely/logic/repository/tune_repository.dart';
import 'package:tunely/logic/service/audio_query_service.dart';

class QueryCubit extends Cubit<QueryState> {
  final _service = AudioQueryService();
  final TuneRepository _repo;

  QueryCubit(this._repo)
    : super(QueryState(filteredSongs: [], isLoading: false, errorMessage: ''));

  // Validation
  bool _isValid(SongModel song) {
    if (song.data.isEmpty) return false;
    if (!File(song.data).existsSync()) return false;
    if (song.duration == null || song.duration! < 1000) return false;
    return true;
  }

  Future<List<SongModel>> _getAllSongs() async {
    final songs = await _service.getSong();
    return songs.where(_isValid).toList();
  }

  // Runs on Splash Screen
  Future<void> initialLoad() async {
    emit(state.copyWith(isLoading: true));
    try {
      final albums = await _service.getAlbums();
      final artists = await _service.getArtists();
      final genres = await _service.getGenres();
      final playlists = await _service.getPlaylists();
      final songs = await _getAllSongs();

      _repo.loadAllSongs(songs);
      _repo.loadLibrary(
        albums: albums,
        artists: artists,
        genres: genres,
        playlists: playlists,
      );

      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
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

  void search(String query) {
    if (query.trim().isEmpty) {
      emit(state.copyWith(searchResult: null));
      return;
    }
    emit(
      state.copyWith(
        searchResult: SearchResult(
          songs: _repo.searchTune(query),
          albums: _repo.searchAlbums(query),
          artists: _repo.searchArtists(query),
        ),
      ),
    );
  }

  List<Tune> tunesByAlbum(int albumId) =>
      _repo.tunes.where((t) => t.albumId == albumId).toList();

  List<AlbumModel> get albums => _repo.albums;
  List<ArtistModel> get artists => _repo.artists;
  List<PlaylistModel> get playlists => _repo.playlists;
  List<GenreModel> get genres => _repo.genres;

  AlbumModel? albumById(int id) => _repo.albumById(id);
  PlaylistModel? playlistById(int id) => _repo.playlistById(id);
  GenreModel? genreById(int id) => _repo.genreById(id);
  ArtistModel? artistById(int id) => _repo.artistById(id);
}
