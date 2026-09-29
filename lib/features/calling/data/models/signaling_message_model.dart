import 'package:convo/features/calling/domain/entities/signaling_message.dart';

class SignalingMessageModel extends SignalingMessage {
  const SignalingMessageModel({
    required super.type,
    super.callId,
    super.from,
    super.to,
    super.sdp,
    super.candidate,
    super.reason,
    super.callType,
    super.callerName,
    super.callerAvatar,
  });

  factory SignalingMessageModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? candidateMap;
    final rawCandidate = json['candidate'] ?? json['iceCandidate'] ?? json['ice'];
    if (rawCandidate is Map<String, dynamic>) {
      candidateMap = rawCandidate;
    } else if (rawCandidate is Map) {
      candidateMap = Map<String, dynamic>.from(rawCandidate);
    }

    final typeStr = json['type']?.toString() ??
        json['event']?.toString() ??
        json['action']?.toString() ??
        'unknown';

    final callIdStr = json['callId']?.toString() ??
        json['id']?.toString() ??
        json['roomId']?.toString();

    final fromStr = json['from']?.toString() ??
        json['callerId']?.toString() ??
        json['senderId']?.toString() ??
        json['sender']?.toString();

    final toStr = json['to']?.toString() ??
        json['receiverId']?.toString() ??
        json['targetId']?.toString() ??
        json['receiver']?.toString();

    final callerNameStr = json['callerName']?.toString() ??
        json['fromName']?.toString() ??
        json['senderName']?.toString() ??
        json['caller_name']?.toString();

    final callerAvatarStr = json['callerAvatar']?.toString() ??
        json['fromAvatar']?.toString() ??
        json['senderAvatar']?.toString() ??
        json['caller_avatar']?.toString();

    return SignalingMessageModel(
      type: typeStr,
      callId: callIdStr,
      from: fromStr,
      to: toStr,
      sdp: json['sdp']?.toString(),
      candidate: candidateMap,
      reason: json['reason']?.toString(),
      callType: json['callType']?.toString() ?? json['call_type']?.toString() ?? 'VOICE',
      callerName: callerNameStr,
      callerAvatar: callerAvatarStr,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'type': type,
    };
    if (callId != null) {
      map['callId'] = callId;
      map['roomId'] = callId;
    }
    if (from != null) {
      map['from'] = from;
      map['callerId'] = from;
      map['sender'] = from;
    }
    if (to != null) {
      map['to'] = to;
      map['receiverId'] = to;
      map['receiver'] = to;
    }
    if (sdp != null) map['sdp'] = sdp;
    if (candidate != null) {
      map['candidate'] = candidate;
      map['iceCandidate'] = candidate;
    }
    if (reason != null) map['reason'] = reason;
    if (callType != null) map['callType'] = callType;
    if (callerName != null) map['callerName'] = callerName;
    if (callerAvatar != null) map['callerAvatar'] = callerAvatar;
    return map;
  }
}
