import 'package:shared_preferences/shared_preferences.dart';

class CustomizationRepository {
  final _keyThemeMode = 'theme_mode';

  final SharedPreferences _prefs;
  CustomizationRepository(this._prefs);

  // Factory constructor for async init
  static Future<CustomizationRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return CustomizationRepository(prefs);
  }

  String get themeMode => _prefs.getString(_keyThemeMode) ?? 'system';
  Future<void> setThemeMode(String mode) async =>
      await _prefs.setString(_keyThemeMode, mode);
}
