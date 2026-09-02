import 'package:convo/app/config/api_config.dart';
import 'package:convo/core/network/api_client.dart';

abstract class PresenceRemoteDataSource {
  Future<Map<String, dynamic>> sendHeartbeat();
}

class PresenceRemoteDataSourceImpl implements PresenceRemoteDataSource {
  final ApiClient _apiClient;

  PresenceRemoteDataSourceImpl(this._apiClient);

  @override
  Future<Map<String, dynamic>> sendHeartbeat() async {
    final res = await _apiClient.post(ApiConfig.heartbeat, body: null);
    if (res is Map<String, dynamic>) {
      if (res["success"] == false) {
        throw Exception(res["message"] ?? "Failed to send heartbeat");
      }
      final data = res["data"];
      if (data is Map<String, dynamic>) {
        return data;
      }
    }
    throw Exception("Invalid heartbeat response payload");
  }
}
