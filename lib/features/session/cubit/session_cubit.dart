import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/session/model/queue_session_model.dart';

import '../repository/session_repository.dart';

class SessionCubit extends Cubit<QueueSessionModel?> {
  final SessionRepository _repo;
  SessionCubit(this._repo) : super(null);

  Future<void> load() async {
    final session = await _repo.load();
    emit(session);
  }

  Future<void> save(QueueSessionModel session) async {
    await _repo.save(session);
    emit(session);
  }

  Future<void> clear() async {
    await _repo.clear();
    emit(null);
  }
}
