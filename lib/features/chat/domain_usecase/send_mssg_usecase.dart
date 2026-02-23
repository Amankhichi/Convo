import 'package:convo/core/payload/chat_payload.dart';
import 'package:convo/features/chat/datasource/chat_datasource.dart';

class SendMssgUsecase{
  final ChatDatasource datasource;
  SendMssgUsecase ({required this.datasource});
  Future<bool> call(ChatPayload mssg){
    return datasource.sendMssg(mssg);
  }
}