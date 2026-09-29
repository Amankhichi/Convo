import 'package:convo/features/calling/domain/entities/active_call_entity.dart';
import 'package:convo/features/calling/domain/entities/call_log_entity.dart';
import 'package:convo/features/calling/domain/entities/ice_server.dart';

abstract class CallRepository {
  List<CallLogEntity> getCallLogs();
  Future<void> addCallLog(CallLogEntity log);
  Future<List<IceServerEntity>> getIceServers();
  Future<List<CallLogEntity>> fetchCallHistory();
  Future<ActiveCallResponseEntity?> getActiveCalls();
}

