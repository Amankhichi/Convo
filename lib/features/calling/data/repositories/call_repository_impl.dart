import 'dart:convert';
import 'package:convo/core/storage/local_storage.dart';
import 'package:convo/features/calling/data/models/call_log_model.dart';
import 'package:convo/features/calling/domain/entities/call_log_entity.dart';
import 'package:convo/features/calling/domain/repositories/call_repository.dart';

class CallRepositoryImpl implements CallRepository {
  final LocalStorage _localStorage;
  static const String _storageKey = 'cached_call_logs';

  CallRepositoryImpl(this._localStorage);

  @override
  List<CallLogEntity> getCallLogs() {
    final jsonString = _localStorage.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        return decoded
            .map((item) => CallLogModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<void> addCallLog(CallLogEntity log) async {
    final currentLogs = getCallLogs();
    final model = CallLogModel(
      id: log.id.isNotEmpty
          ? log.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      targetUserId: log.targetUserId,
      targetUserName: log.targetUserName,
      targetUserImage: log.targetUserImage,
      callType: log.callType,
      direction: log.direction,
      timestamp: log.timestamp.isNotEmpty
          ? log.timestamp
          : DateTime.now().toIso8601String(),
      duration: log.duration,
    );

    final updated = [model, ...currentLogs];
    final jsonList = updated.map((item) {
      if (item is CallLogModel) {
        return item.toJson();
      }
      return CallLogModel(
        id: item.id,
        targetUserId: item.targetUserId,
        targetUserName: item.targetUserName,
        targetUserImage: item.targetUserImage,
        callType: item.callType,
        direction: item.direction,
        timestamp: item.timestamp,
        duration: item.duration,
      ).toJson();
    }).toList();
    await _localStorage.setString(_storageKey, jsonEncode(jsonList));
  }
}
