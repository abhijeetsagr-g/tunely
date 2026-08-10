import 'package:shared_preferences/shared_preferences.dart';
import 'package:tunely/core/config/app_color.dart';

class CustomizationRepository {
  final _keyThemeMode = 'theme_mode';
  final _keyAccentColor = 'accent_color';

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

  int get accentColor =>
      _prefs.getInt(_keyAccentColor) ?? AppColor.blue.toARGB32();
  Future<void> setAccentColor(int value) async =>
      await _prefs.setInt(_keyAccentColor, value);
}
