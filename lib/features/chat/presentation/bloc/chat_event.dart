part of 'chat_bloc.dart';

abstract class ChatEvent {
  const factory ChatEvent.init() = _Init;
  const factory ChatEvent.sendMssg({
    required String mssg,
    required String receiverId,
    int? replyTo,
  }) = _SendMssg;
  const factory ChatEvent.getMssg({required String receiverId}) = _GetMssg;
  const factory ChatEvent.deletMssg({required int mssId}) = _DeletMssg;
  const factory ChatEvent.editMssg({
    required int mssgId,
    required String newMssg,
  }) = _EditMssg;
  const factory ChatEvent.seen({required int sender}) = _Seen;
}

class _Init implements ChatEvent {
  const _Init();
}

class _SendMssg implements ChatEvent {
  final String mssg;
  final String receiverId;
  final int? replyTo;
  const _SendMssg({
    required this.mssg,
    required this.receiverId,
    this.replyTo,
  });
}

class _GetMssg implements ChatEvent {
  final String receiverId;
  const _GetMssg({required this.receiverId});
}

class _DeletMssg implements ChatEvent {
  final int mssId;
  const _DeletMssg({required this.mssId});
}

class _EditMssg implements ChatEvent {
  final int mssgId;
  final String newMssg;
  const _EditMssg({required this.mssgId, required this.newMssg});
}

class _Seen implements ChatEvent {
  final int sender;
  const _Seen({required this.sender});
}
