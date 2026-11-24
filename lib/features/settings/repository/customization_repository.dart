import 'package:shared_preferences/shared_preferences.dart';
import 'package:tunely/core/config/app_color.dart';

class CustomizationRepository {
  final _keyThemeMode = 'theme_mode';
  final _keyAccentColor = 'accent_color';
  final _keyFontFamily = 'font_family';
  final _keyFontSize = 'font_size';

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

  String get fontModel => _prefs.getString(_keyFontFamily) ?? 'system';
  Future<void> setFont(String font) async =>
      await _prefs.setString(_keyFontFamily, font);

  String get fontSizeModel => _prefs.getString(_keyFontSize) ?? 'medium';
  Future<void> setFontSize(String size) async =>
      await _prefs.setString(_keyFontSize, size);
}
