import 'package:convo/features/home/domain/entities/chat_summary_entity.dart';

abstract class HomeRepository {
  Future<List<ChatSummaryEntity>> fetchChats();
  List<ChatSummaryEntity> getCachedChats();
}
