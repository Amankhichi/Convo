import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseAuthService {
  FirebaseAuthService();
  Future<void> signInWithEmailAndPassword(String email, String password) async {}
  Future<void> signOut() async {}
}

class FirebaseMessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    await _messaging.requestPermission();
  }

  Future<String?> getToken() => _messaging.getToken();
}

class FirebaseCrashlyticsService {
  FirebaseCrashlyticsService();
  Future<void> log(String message) async {}
  Future<void> recordError(dynamic exception, StackTrace? stack) async {}
}

class FirebaseAnalyticsService {
  FirebaseAnalyticsService();
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {}
}

class FirebaseStorageService {
  FirebaseStorageService();
  Future<String> uploadFile(String path, dynamic fileBytes) async => "";
}

class FirebaseFirestoreService {
  FirebaseFirestoreService();
  Future<void> setData(String collection, String docId, Map<String, dynamic> data) async {}
  Future<Map<String, dynamic>?> getData(String collection, String docId) async => null;
}
