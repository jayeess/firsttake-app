import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  FirebaseConfig._();

  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyD6dYD3vD2BXyj5sYskUgWBASHBQAmQNhM',
        authDomain: 'first-take-app.firebaseapp.com',
        projectId: 'first-take-app',
        storageBucket: 'first-take-app.firebasestorage.app',
        messagingSenderId: '97111264176',
        appId: '1:97111264176:web:ba7e471d6da3b834e32475',
        measurementId: 'G-X7ZXNWLPM3',
      ),
    );
  }
}
