import 'package:convo/features/presence/domain/entities/presence_entity.dart';

abstract class PresenceRepository {
  Future<PresenceEntity> sendHeartbeat();
}
