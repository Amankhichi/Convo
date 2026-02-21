import 'package:convo/core/payload/chat_payload.dart';
import 'package:convo/features/home/datasource/user_datasource.dart';

class ChatUsecase{
  final UserDatasource datasource;
  ChatUsecase ({required this.datasource});
  Future<bool> call(ChatPayload mssg){
    return datasource.sendMssg(mssg);
  }
}