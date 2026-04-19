import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/session/model/queue_session_model.dart';
import 'package:tunely/features/session/repository/session_repository.dart';

class SessionCubit extends Cubit<QueueSessionModel?> {
  final SessionRepository _repo;
  SessionCubit(this._repo) : super(null);

  Future<void> load() async {
    final session = await _repo.load();
    emit(session);
  }

  Future<void> save(QueueSessionModel session) async {
    try {
      await _repo.save(session);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      emit(session);
    }
  }

  Future<void> clear() async {
    await _repo.clear();
    emit(null);
  }
}
