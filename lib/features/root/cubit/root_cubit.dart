import 'package:flutter_bloc/flutter_bloc.dart';

part 'root_state.dart';

class RootCubit extends Cubit<RootState> {
  RootCubit() : super(const RootState());

  void goTo(RootPage page) {
    emit(state.copyWith(currentPage: page));
  }

  void goToLibrary(LibraryFilter filter) {
    emit(state.copyWith(currentPage: RootPage.library, libraryFilter: filter));
  }

  void reorderPages(List<RootPage> pages) {
    assert(pages.length == RootPage.values.length, 'Must include all pages');
    emit(state.copyWith(pages: pages));
  }
}
