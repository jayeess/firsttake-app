import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates a new Firebase Auth user and writes a corresponding user document
  /// to the `users` collection in Firestore.
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required UserType userType,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final now = DateTime.now();
      final userModel = UserModel(
        uid: credential.user!.uid,
        email: email,
        phone: '',
        userType: userType,
        emailVerified: false,
        phoneVerified: false,
        accountStatus: AccountStatus.ACTIVE,
        createdAt: now,
        updatedAt: now,
        lastLogin: now,
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userModel.toMap());

      return credential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  /// Signs in an existing user with email and password and updates
  /// the `lastLogin` timestamp on their Firestore document.
  Future<UserCredential> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .update({
        'lastLogin': Timestamp.fromDate(DateTime.now()),
      });

      return credential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to log in: $e');
    }
  }

  /// Sends a password-reset email to the given address.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  /// Sends an email-verification link to the currently signed-in user.
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }
      await user.sendEmailVerification();
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to send email verification: $e');
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Returns the currently signed-in [User], or `null` if none.
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// A stream that emits the current [User] (or `null`) whenever the
  /// authentication state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Fetches the [UserModel] document for the given [uid] from Firestore.
  /// Returns `null` if the document does not exist.
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return UserModel.fromMap(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }
}
