import 'package:convo/core/model/user_model.dart';

class HomeChatModel {
  final int id;
  final DateTime createdAt;
  final UserModel sender;
  final UserModel receiver;
  final String message;
  final bool seen;
  final int? replyTo;
  final int unSeenCount;

  HomeChatModel({
    required this.id,
    required this.createdAt,
    required this.sender,
    required this.receiver,
    required this.message,
    required this.seen,
    required this.replyTo,
    required this.unSeenCount,
  });

  factory HomeChatModel.fromJson(Map<String, dynamic> json) {
    return HomeChatModel(
      id: json['id'] ?? 0,

      createdAt: DateTime.tryParse(
            json['createdAt'] ??
            json['created_at'] ??
            '',
          ) ??
          DateTime.now(),

      /// ✅ HANDLE BOTH CASES (VERY IMPORTANT)
      sender: json['sender'] != null
          ? UserModel.fromJson(json['sender'])
          : json['sender_id'] != null
              ? UserModel.fromJson(json['sender_id'])
              : UserModel.empty(),

      receiver: json['receiver'] != null
          ? UserModel.fromJson(json['receiver'])
          : json['receiver_id'] != null
              ? UserModel.fromJson(json['receiver_id'])
              : UserModel.empty(),

      /// ✅ HANDLE TYPO FROM API
      message: json['mssg'] ?? json['massage'] ?? json['message'] ?? '',

      seen: json['seen'] ?? false,

      /// ✅ HANDLE BOTH reply formats
      replyTo: json['reply_to'] != null
          ? int.tryParse(json['reply_to'].toString())
          : json['replyTo'] != null
              ? int.tryParse(json['replyTo'].toString())
              : null,

      unSeenCount: 0,
    );
  }

  HomeChatModel copyWith({
    int? id,
    DateTime? createdAt,
    UserModel? sender,
    UserModel? receiver,
    String? message,
    int? replyTo,
    int? unSeenCount,
    bool? seen,
  }) {
    return HomeChatModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      message: message ?? this.message,
      replyTo: replyTo ?? this.replyTo,
      seen: seen ?? this.seen,
      unSeenCount: unSeenCount ?? this.unSeenCount,
    );
  }
}