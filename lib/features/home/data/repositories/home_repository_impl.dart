import 'package:convo/features/home/data/datasources/home_local_datasource.dart';
import 'package:convo/features/home/data/datasources/home_remote_datasource.dart';
import 'package:convo/features/home/domain/entities/chat_summary_entity.dart';
import 'package:convo/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remoteDataSource;
  final HomeLocalDataSource _localDataSource;

  HomeRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<List<ChatSummaryEntity>> fetchChats() async {
    try {
      final chats = await _remoteDataSource.fetchChats();
      await _localDataSource.saveChats(chats);
      return chats;
    } catch (e) {
      final cached = _localDataSource.getCachedChats();
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  @override
  List<ChatSummaryEntity> getCachedChats() {
    return _localDataSource.getCachedChats();
  }
}
