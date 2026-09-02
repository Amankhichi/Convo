import 'package:convo/features/presence/data/datasources/presence_remote_datasource.dart';
import 'package:convo/features/presence/domain/entities/presence_entity.dart';
import 'package:convo/features/presence/domain/repositories/presence_repository.dart';

class PresenceRepositoryImpl implements PresenceRepository {
  final PresenceRemoteDataSource _remoteDataSource;

  PresenceRepositoryImpl(this._remoteDataSource);

  @override
  Future<PresenceEntity> sendHeartbeat() async {
    final data = await _remoteDataSource.sendHeartbeat();
    return PresenceEntity(
      status: data['status']?.toString() ?? 'ONLINE',
      lastSeen: data['lastSeen']?.toString() ?? '',
    );
  }
}
