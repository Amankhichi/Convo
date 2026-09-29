import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:convo/core/constants/storage_keys.dart';
import 'package:convo/core/storage/local_storage.dart';

class SecureStorage {
  final LocalStorage _localStorage;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  String? _inMemoryToken;
  int? _inMemoryUserId;

  SecureStorage(this._localStorage) {
    _initInMemoryCache();
  }

  void _initInMemoryCache() {
    _inMemoryToken = _localStorage.getString(StorageKeys.jwtToken);
    final strId = _localStorage.getString(StorageKeys.userId);
    if (strId != null) {
      _inMemoryUserId = int.tryParse(strId);
    }
  }

  Future<void> saveToken(String token) async {
    final clean = token.trim().replaceAll(RegExp(r'[\s\r\n\t]+'), '').replaceAll('#', '');
    final cleanToken = clean.contains('#') ? clean.split('#').first : clean;
    _inMemoryToken = cleanToken;

    await _localStorage.setString(StorageKeys.jwtToken, cleanToken);
    try {
      await _secureStorage.write(key: StorageKeys.jwtToken, value: cleanToken);
    } catch (_) {}
  }

  String? getToken() {
    if (_inMemoryToken != null && _inMemoryToken!.isNotEmpty) {
      return _inMemoryToken;
    }
    final raw = _localStorage.getString(StorageKeys.jwtToken);
    if (raw == null || raw.trim().isEmpty) return null;
    final clean = raw.trim().replaceAll(RegExp(r'[\s\r\n\t]+'), '').replaceAll('#', '');
    _inMemoryToken = clean.contains('#') ? clean.split('#').first : clean;
    return _inMemoryToken;
  }

  Future<String?> getTokenAsync() async {
    final cached = getToken();
    if (cached != null && cached.isNotEmpty) return cached;

    try {
      final secureVal = await _secureStorage.read(key: StorageKeys.jwtToken);
      if (secureVal != null && secureVal.trim().isNotEmpty) {
        final clean = secureVal.trim().replaceAll(RegExp(r'[\s\r\n\t]+'), '').replaceAll('#', '');
        _inMemoryToken = clean.contains('#') ? clean.split('#').first : clean;
        await _localStorage.setString(StorageKeys.jwtToken, _inMemoryToken!);
        return _inMemoryToken;
      }
    } catch (_) {}
    return null;
  }

  Future<void> saveUserId(int id) async {
    _inMemoryUserId = id;
    await _localStorage.setString(StorageKeys.userId, id.toString());
    try {
      await _secureStorage.write(key: StorageKeys.userId, value: id.toString());
    } catch (_) {}
  }

  int getUserId() {
    if (_inMemoryUserId != null && _inMemoryUserId! > 0) {
      return _inMemoryUserId!;
    }
    final str = _localStorage.getString(StorageKeys.userId);
    if (str != null) {
      final parsed = int.tryParse(str) ?? 0;
      _inMemoryUserId = parsed;
      return parsed;
    }
    return 0;
  }

  Future<void> clearToken() async {
    _inMemoryToken = null;
    _inMemoryUserId = null;
    await _localStorage.remove(StorageKeys.jwtToken);
    await _localStorage.remove(StorageKeys.userId);
    try {
      await _secureStorage.delete(key: StorageKeys.jwtToken);
      await _secureStorage.delete(key: StorageKeys.userId);
    } catch (_) {}
  }
}

