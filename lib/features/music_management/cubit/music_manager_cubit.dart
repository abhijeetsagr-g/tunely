import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/music_management/model/management_settings.dart';
import 'package:tunely/features/music_management/repository/management_repository.dart';

class ManagementCubit extends Cubit<ManagementSettings> {
  final ManagementRepository _repo;

  ManagementCubit(this._repo) : super(_repo.get());

  ManagementSettings getSettings() => _repo.get();

  Future<void> updateDelimiters(List<String> delimiters) =>
      _update(state.copyWith(artistDelimiters: delimiters));

  Future<void> updateMinDuration(int ms) =>
      _update(state.copyWith(minDurationMs: ms));

  Future<void> updateExcludedFolders(List<String> folders) =>
      _update(state.copyWith(excludedFolders: folders));

  Future<void> reset() => _update(ManagementSettings());

  Future<void> _update(ManagementSettings settings) async {
    await _repo.save(settings);
    emit(settings);
  }
}
