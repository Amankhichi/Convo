import 'package:convo/core/payload/chat_payload.dart';
import 'package:convo/features/chat/datasource/chat_datasource.dart';

class ChatUsecase{
  final ChatDatasource datasource;
  ChatUsecase ({required this.datasource});
  Future<bool> call(ChatPayload mssg){
    return datasource.sendMssg(mssg);
  }
}