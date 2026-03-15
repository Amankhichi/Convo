import 'package:convo/features/chat/datasource/chat_datasource.dart';

class SeenMssgUsecase {
  final ChatDatasource datasource;

  SeenMssgUsecase({required this.datasource});

  Future<void> call({
    required int senderId,
    required int receiverId,
  }) async {
    await datasource.seenMssg(
      senderId: senderId,
      receiverId: receiverId,
    );
  }
}