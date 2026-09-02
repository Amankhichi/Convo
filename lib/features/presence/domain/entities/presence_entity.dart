class PresenceEntity {
  final String status;
  final String lastSeen;

  const PresenceEntity({
    required this.status,
    required this.lastSeen,
  });

  bool get isOnline => status.toUpperCase() == 'ONLINE';
}
