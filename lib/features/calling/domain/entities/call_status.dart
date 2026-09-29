enum CallStatus {
  idle,
  initiating,
  ringing,
  incoming,
  connecting,
  active,
  ending,
  ended,
  rejected,
  cancelled,
  timedOut,
  failed,
}

enum CallType {
  voice,
  video,
}

enum CallDirection {
  incoming,
  outgoing,
}

extension CallTypeX on CallType {
  String toStr() {
    switch (this) {
      case CallType.video:
        return 'VIDEO';
      case CallType.voice:
        return 'VOICE';
    }
  }

  static CallType fromStr(String? val) {
    if (val?.toUpperCase() == 'VIDEO') {
      return CallType.video;
    }
    return CallType.voice;
  }
}

extension CallStatusX on CallStatus {
  bool get isTerminated {
    return this == CallStatus.ended ||
        this == CallStatus.rejected ||
        this == CallStatus.cancelled ||
        this == CallStatus.timedOut ||
        this == CallStatus.failed;
  }

  bool get isInCall {
    return this == CallStatus.initiating ||
        this == CallStatus.ringing ||
        this == CallStatus.incoming ||
        this == CallStatus.connecting ||
        this == CallStatus.active;
  }
}
