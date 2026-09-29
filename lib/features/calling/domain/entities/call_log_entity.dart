class CallLogEntity {
  final String id;
  final int targetUserId;
  final String targetUserName;
  final String targetUserImage;
  final String callType; // 'VOICE' or 'VIDEO'
  final String direction; // 'INCOMING', 'OUTGOING', 'MISSED', 'REJECTED'
  final String timestamp;
  final String duration;

  const CallLogEntity({
    required this.id,
    required this.targetUserId,
    required this.targetUserName,
    required this.targetUserImage,
    this.callType = 'VOICE',
    this.direction = 'OUTGOING',
    required this.timestamp,
    this.duration = '',
  });
}
