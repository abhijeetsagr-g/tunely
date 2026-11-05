import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/library/helper/sort.dart';
import 'package:tunely/features/library/repository/library_sort_repository.dart';

part 'library_sort_state.dart';

class LibrarySortCubit extends Cubit<LibrarySortState> {
  LibrarySortCubit(this._repository) : super(_initialState(_repository));

  final LibrarySortRepo _repository;

  static LibrarySortState _initialState(LibrarySortRepo repository) {
    final (albumSort, albumAsc) = repository.getAlbumSort();
    final (tuneSort, tuneAsc) = repository.getTuneSort();
    final (artistSort, artistAsc) = repository.getArtistSort();

    return LibrarySortState(
      albumSort: albumSort,
      albumSortAsc: albumAsc,
      tuneSortType: tuneSort,
      tuneSortAsc: tuneAsc,
      artistSort: artistSort,
      artistSortAsc: artistAsc,
      albumHideSingles: repository.getAlbumHideSingles(),
      artistHideSingles: repository.getArtistHideSingles(),
    );
  }

  Future<void> setTuneSort(TuneSortType type, bool ascending) async {
    emit(state.copyWith(tuneSortType: type, tuneSortAsc: ascending));
    await _repository.setTuneSort(type, ascending);
  }

  Future<void> setAlbumSort(AlbumSort type, bool ascending) async {
    emit(state.copyWith(albumSort: type, albumSortAsc: ascending));
    await _repository.setAlbumSort(type, ascending);
  }

  Future<void> setArtistSort(ArtistSort type, bool ascending) async {
    emit(state.copyWith(artistSort: type, artistSortAsc: ascending));
    await _repository.setArtistSort(type, ascending);
  }

  Future<void> setAlbumHideSingles(bool value) async {
    emit(state.copyWith(albumHideSingles: value));
    await _repository.setAlbumHideSingles(value);
  }

  Future<void> setArtistHideSingles(bool value) async {
    emit(state.copyWith(artistHideSingles: value));
    await _repository.setArtistHideSingles(value);
  }
}
