import 'dart:convert';
import 'package:convo/app/config/calling_config.dart';
import 'package:convo/core/network/api_client.dart';
import 'package:convo/core/storage/local_storage.dart';
import 'package:convo/features/calling/data/models/active_call_response_model.dart';
import 'package:convo/features/calling/data/models/call_log_model.dart';
import 'package:convo/features/calling/data/models/ice_server_model.dart';
import 'package:convo/features/calling/domain/entities/active_call_entity.dart';
import 'package:convo/features/calling/domain/entities/call_log_entity.dart';
import 'package:convo/features/calling/domain/entities/ice_server.dart';
import 'package:convo/features/calling/domain/repositories/call_repository.dart';


class CallRepositoryImpl implements CallRepository {
  final LocalStorage _localStorage;
  final ApiClient _apiClient;
  static const String _storageKey = 'cached_call_logs';

  CallRepositoryImpl(this._localStorage, this._apiClient);

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

  @override
  Future<List<IceServerEntity>> getIceServers() async {
    final baseUrl = CallingConfig.effectiveApiBaseUrl;
    final url = '$baseUrl/api/calls/ice-servers';

    try {
      final response = await _apiClient.get(url);
      if (response != null && response is Map<String, dynamic>) {
        final serversData = response['iceServers'] ?? response['data'];
        if (serversData is List) {
          return serversData
              .map((e) => IceServerModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } else if (response is List) {
        return response
            .map((e) => IceServerModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Fallback if backend endpoint is unavailable or fails
    }

    // Standard public STUN fallback
    return const [
      IceServerModel(urls: ['stun:stun.l.google.com:19302']),
      IceServerModel(urls: ['stun:stun1.l.google.com:19302']),
    ];
  }

  @override
  Future<List<CallLogEntity>> fetchCallHistory() async {
    final baseUrl = CallingConfig.effectiveApiBaseUrl;
    final url = '$baseUrl/api/calls/history';

    try {
      final response = await _apiClient.get(url);
      if (response != null && response is Map<String, dynamic>) {
        final list = response['content'] ?? response['data'] ?? response['calls'];
        if (list is List) {
          final remoteLogs = list
              .map((e) => CallLogModel.fromJson(e as Map<String, dynamic>))
              .toList();

          // Sync into local cache
          for (final log in remoteLogs) {
            await addCallLog(log);
          }
          return remoteLogs;
        }
      } else if (response is List) {
        final remoteLogs = response
            .map((e) => CallLogModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return remoteLogs;
      }
    } catch (_) {
      // Return cached local logs on error
    }

    return getCallLogs();
  }

  @override
  Future<ActiveCallResponseEntity?> getActiveCalls() async {
    final baseUrl = CallingConfig.effectiveApiBaseUrl;
    final url = '$baseUrl/api/calls/active';

    try {
      final response = await _apiClient.get(url);
      if (response != null && response is Map<String, dynamic>) {
        return ActiveCallResponseModel.fromJson(response);
      }
    } catch (_) {}
    return null;
  }
}

