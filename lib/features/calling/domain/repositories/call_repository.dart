import 'package:convo/features/calling/domain/entities/call_log_entity.dart';

abstract class CallRepository {
  List<CallLogEntity> getCallLogs();
  Future<void> addCallLog(CallLogEntity log);
}
