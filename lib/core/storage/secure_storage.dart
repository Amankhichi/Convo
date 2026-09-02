import 'package:convo/core/constants/storage_keys.dart';
import 'package:convo/core/storage/local_storage.dart';

class SecureStorage {
  final LocalStorage _localStorage;

  SecureStorage(this._localStorage);

  Future<void> saveToken(String token) async {
    await _localStorage.setString(StorageKeys.jwtToken, token);
  }

  String? getToken() {
    return _localStorage.getString(StorageKeys.jwtToken);
  }

  Future<void> saveUserId(int id) async {
    await _localStorage.setString(StorageKeys.userId, id.toString());
  }

  int getUserId() {
    final str = _localStorage.getString(StorageKeys.userId);
    if (str != null) return int.tryParse(str) ?? 0;
    return 0;
  }

  Future<void> clearToken() async {
    await _localStorage.remove(StorageKeys.jwtToken);
  }
}
