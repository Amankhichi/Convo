import 'dart:convert';
import 'package:convo/core/storage/storage_service.dart';
import '../../model/user_model.dart';

abstract class AuthLocalDatasource {
  Future<void> cacheUserId(String id);
  Future<String?> getCachedUserId();
  Future<void> cacheUserPhone(String phone);
  Future<String?> getCachedUserPhone();
  Future<void> cacheToken(String token);
  Future<String?> getCachedToken();
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearCache();
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  final SharedPreferencesWrapper _sharedPrefs;
  final SecureStorageWrapper _secureStorage;

  AuthLocalDatasourceImpl(this._sharedPrefs, this._secureStorage);

  @override
  Future<void> cacheUserId(String id) async {
    await _sharedPrefs.setString("id", id);
  }

  @override
  Future<String?> getCachedUserId() async {
    return _sharedPrefs.getString("id");
  }

  @override
  Future<void> cacheUserPhone(String phone) async {
    await _sharedPrefs.setString("phone", phone);
  }

  @override
  Future<String?> getCachedUserPhone() async {
    return _sharedPrefs.getString("phone");
  }

  @override
  Future<void> cacheToken(String token) async {
    await _secureStorage.write("token", token);
  }

  @override
  Future<String?> getCachedToken() async {
    return _secureStorage.read("token");
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    await _sharedPrefs.setString("user_profile", jsonEncode(user.toJson()));
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final userStr = _sharedPrefs.getString("user_profile");
    if (userStr != null) {
      try {
        return UserModel.fromJson(jsonDecode(userStr));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> clearCache() async {
    await _sharedPrefs.remove("id");
    await _sharedPrefs.remove("phone");
    await _sharedPrefs.remove("user_profile");
    await _secureStorage.deleteAll();
  }
}
