import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/data/model/tune.dart';
import 'package:tunely/data/repository/tune_repository.dart';
import 'package:tunely/service/audio_query_service.dart';
import 'library_state.dart';

class LibraryCubit extends Cubit<LibraryState> {
  final _service = AudioQueryService();
  final TuneRepository _repo;

  LibraryCubit(this._repo)
    : super(
        LibraryState(
          isLoading: false,
          errorMessage: '',
          filteredTunes: [],
          sortedTunes: [],
          sortType: TuneSortType.recentlyAdded,
          recommendedTunes: [],
        ),
      );

  bool _isValid(SongModel song) {
    if (song.data.isEmpty) return false;
    if (!File(song.data).existsSync()) return false;
    if (song.duration == null || song.duration! < 1000) return false;
    return true;
  }

  Future<void> initialLoad() async {
    emit(state.copyWith(isLoading: true));
    try {
      final songs = await _service.getSong();
      final valid = songs.where(_isValid).toList();
      final albums = await _service.getAlbums();
      final artists = await _service.getArtists();
      final genres = await _service.getGenres();
      final playlists = await _service.getPlaylists();

      _repo.loadAllSongs(valid);
      _repo.loadLibrary(
        albums: albums,
        artists: artists,
        genres: genres,
        playlists: playlists,
      );
      final recommend = _repo.loadRecommend(5);

      emit(
        state.copyWith(
          isLoading: false,
          recommendedTunes: recommend,
          sortedTunes: _repo.sortTunes(.title),
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> getFilteredSongs(AudiosFromType type, int targetId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final songs = await _service.getFilteredSongs(type, targetId);
      final filteredSongs = songs.where(_isValid).toList();
      final tunes = filteredSongs.map((e) => Tune.fromSongModel(e)).toList();

      emit(state.copyWith(filteredTunes: tunes, isLoading: false));
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  void refreshRecommended([int count = 5]) {
    emit(state.copyWith(recommendedTunes: _repo.loadRecommend(count)));
  }

  void sortBy(TuneSortType type) {
    emit(state.copyWith(sortedTunes: _repo.sortTunes(type), sortType: type));
  }

  List<Tune> tunesByAlbum(int albumId) =>
      _repo.tunes.where((t) => t.albumId == albumId).toList()
        ..sort((a, b) => (a.trackIndex ?? 0).compareTo(b.trackIndex ?? 0));

  List<Tune> tunesByArtist(int artistId) =>
      _repo.tunes.where((t) => t.artistId == artistId).toList()
        ..sort((a, b) => (a.trackIndex ?? 0).compareTo(b.trackIndex ?? 0));

  List<AlbumModel> get albums => _repo.albums;
  List<ArtistModel> get artists => _repo.artists;
  List<PlaylistModel> get playlists => _repo.playlists;
  List<GenreModel> get genres => _repo.genres;

  AlbumModel? albumById(int id) => _repo.albumById(id);
  PlaylistModel? playlistById(int id) => _repo.playlistById(id);
  GenreModel? genreById(int id) => _repo.genreById(id);
  ArtistModel? artistById(int id) => _repo.artistById(id);
}
