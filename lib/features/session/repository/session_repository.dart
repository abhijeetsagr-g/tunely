import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tunely/features/session/model/queue_session_model.dart';

class SessionRepository {
  static const _key = 'playback_session';

  Future<void> save(QueueSessionModel session) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(session.toJson());
    await prefs.setString(_key, json);
  }

  Future<QueueSessionModel?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);

    if (json == null) return null;

    return QueueSessionModel.fromJson(jsonDecode(json));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
