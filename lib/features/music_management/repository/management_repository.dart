import 'package:hive_ce/hive_ce.dart';
import 'package:tunely/features/music_management/model/management_settings.dart';

class ManagementRepository {
  final Box<ManagementSettings> _box;

  ManagementRepository(this._box);

  ManagementSettings get() => _box.get('settings') ?? ManagementSettings();

  Future<void> save(ManagementSettings settings) =>
      _box.put('settings', settings);

  Future<void> reset() => _box.put('settings', ManagementSettings());
}
