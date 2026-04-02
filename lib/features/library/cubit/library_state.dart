import 'package:tunely/data/model/tune.dart';

class LibraryState {
  final bool isLoading;
  final String errorMessage;
  final List<Tune> filteredTunes;
  final List<Tune> sortedTunes;
  List<Tune> recommendedTunes;

  LibraryState({
    required this.isLoading,
    required this.errorMessage,
    required this.filteredTunes,
    required this.sortedTunes,
    required this.recommendedTunes,
  });

  LibraryState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Tune>? filteredTunes,
    List<Tune>? sortedTunes,
    List<Tune>? recommendedTunes,
  }) => LibraryState(
    isLoading: isLoading ?? this.isLoading,
    errorMessage: errorMessage ?? this.errorMessage,
    filteredTunes: filteredTunes ?? this.filteredTunes,
    sortedTunes: sortedTunes ?? this.sortedTunes,

    recommendedTunes: recommendedTunes ?? this.recommendedTunes,
  );
}
