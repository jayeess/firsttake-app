import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  FirebaseConfig._();

  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: String.fromEnvironment('FIREBASE_API_KEY', defaultValue: 'demo-api-key'),
        appId: String.fromEnvironment('FIREBASE_APP_ID', defaultValue: 'demo-app-id'),
        messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID', defaultValue: '0'),
        projectId: String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: 'firsttake-demo'),
        storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET', defaultValue: 'firsttake-demo.appspot.com'),
      ),
    );
  }
}
