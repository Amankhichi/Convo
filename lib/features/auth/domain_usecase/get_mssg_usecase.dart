import 'package:convo/core/model/chat_model.dart';
import 'package:convo/features/auth/datasource/chat_datasource.dart';

class GetMssgUseCase {
  final ChatDatasource datasource;

  GetMssgUseCase({required this.datasource});

  Future<List<ChatModel>> call({required String senderId,required String receiverId,}) {
    return datasource.getMessages(senderId: senderId,receiverId: receiverId,);
  }
}