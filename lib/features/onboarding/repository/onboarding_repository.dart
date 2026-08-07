import 'package:shared_preferences/shared_preferences.dart';

class OnboardingRepository {
  static const _keyCompleted = 'onboarding_complete';

  final SharedPreferences _prefs;
  OnboardingRepository(this._prefs);

  // Factory constructor for async init
  static Future<OnboardingRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return OnboardingRepository(prefs);
  }

  bool get isCompleted => _prefs.getBool(_keyCompleted) ?? false;

  Future<void> setCompleted() async =>
      await _prefs.setBool(_keyCompleted, true);
}
