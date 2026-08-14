import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesWrapper {
  final SharedPreferences _prefs;

  SharedPreferencesWrapper(this._prefs);

  Future<bool> setString(String key, String value) => _prefs.setString(key, value);
  String? getString(String key) => _prefs.getString(key);

  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);
  bool? getBool(String key) => _prefs.getBool(key);

  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);
  int? getInt(String key) => _prefs.getInt(key);

  Future<bool> remove(String key) => _prefs.remove(key);
  Future<bool> clear() => _prefs.clear();
}

class SecureStorageWrapper {
  final FlutterSecureStorage _secureStorage;

  SecureStorageWrapper({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  Future<void> write(String key, String value) => _secureStorage.write(key: key, value: value);
  Future<String?> read(String key) => _secureStorage.read(key: key);
  Future<void> delete(String key) => _secureStorage.delete(key: key);
  Future<void> deleteAll() => _secureStorage.deleteAll();
}

class HiveStorageWrapper {
  HiveStorageWrapper();

  static Future<void> init() async {
    await Hive.initFlutter();
  }

  Future<Box<T>> openBox<T>(String name) => Hive.openBox<T>(name);
  Box<T> getBox<T>(String name) => Hive.box<T>(name);
}
