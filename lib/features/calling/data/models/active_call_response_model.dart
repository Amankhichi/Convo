import 'package:convo/features/calling/domain/entities/active_call_entity.dart';

class ActiveCallItemModel extends ActiveCallItemEntity {
  const ActiveCallItemModel({
    required super.callId,
    required super.callerUsername,
    super.callerId,
    required super.receiverUsername,
    super.receiverId,
    required super.status,
    super.callType,
  });

  factory ActiveCallItemModel.fromJson(Map<String, dynamic> json) {
    return ActiveCallItemModel(
      callId: json['callId']?.toString() ?? json['roomId']?.toString() ?? '',
      callerUsername: json['callerUsername']?.toString() ?? '',
      callerId: json['callerId'] is int
          ? json['callerId']
          : int.tryParse(json['callerId']?.toString() ?? '0') ?? 0,
      receiverUsername: json['receiverUsername']?.toString() ?? '',
      receiverId: json['receiverId'] is int
          ? json['receiverId']
          : int.tryParse(json['receiverId']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? 'INITIATED',
      callType: json['callType']?.toString() ?? 'VOICE',
    );
  }
}

class ActiveCallResponseModel extends ActiveCallResponseEntity {
  const ActiveCallResponseModel({
    required super.active,
    required super.calls,
  });

  factory ActiveCallResponseModel.fromJson(Map<String, dynamic> json) {
    final active = json['active'] == true || json['hasActiveCall'] == true;
    final rawList = json['calls'] ?? json['activeCalls'];
    final List<ActiveCallItemEntity> list = [];

    if (rawList is List) {
      for (final item in rawList) {
        if (item is Map<String, dynamic>) {
          list.add(ActiveCallItemModel.fromJson(item));
        }
      }
    }

    return ActiveCallResponseModel(
      active: active,
      calls: list,
    );
  }
}
