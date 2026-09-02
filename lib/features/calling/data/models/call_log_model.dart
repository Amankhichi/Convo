import 'package:convo/features/calling/domain/entities/call_log_entity.dart';

class CallLogModel extends CallLogEntity {
  const CallLogModel({
    required super.id,
    required super.targetUserId,
    required super.targetUserName,
    required super.targetUserImage,
    super.callType = 'VOICE',
    super.direction = 'OUTGOING',
    required super.timestamp,
    super.duration = '',
  });

  factory CallLogModel.fromJson(Map<String, dynamic> json) {
    return CallLogModel(
      id: json['id']?.toString() ?? '',
      targetUserId: json['targetUserId'] is int
          ? json['targetUserId']
          : int.tryParse(json['targetUserId']?.toString() ?? '0') ?? 0,
      targetUserName: json['targetUserName']?.toString() ?? '',
      targetUserImage: json['targetUserImage']?.toString() ?? '',
      callType: json['callType']?.toString() ?? 'VOICE',
      direction: json['direction']?.toString() ?? 'OUTGOING',
      timestamp: json['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
      duration: json['duration']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'targetUserId': targetUserId,
      'targetUserName': targetUserName,
      'targetUserImage': targetUserImage,
      'callType': callType,
      'direction': direction,
      'timestamp': timestamp,
      'duration': duration,
    };
  }
}
