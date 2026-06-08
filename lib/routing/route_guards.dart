import 'package:firebase_auth/firebase_auth.dart';

class RouteGuards {
  static bool isAuthenticated() {
    return FirebaseAuth.instance.currentUser != null;
  }

  static String? redirectIfNotAuthenticated() {
    if (!isAuthenticated()) return '/login';
    return null;
  }
}
