import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Reference to the notifications sub-collection for a given user.
  CollectionReference<Map<String, dynamic>> _notificationsRef(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications');
  }

  /// Creates a new notification document under `users/{userId}/notifications`.
  Future<void> createNotification(
    String userId,
    AppNotification notification,
  ) async {
    try {
      final docRef = _notificationsRef(userId).doc();
      final data = notification.toMap();
      data['id'] = docRef.id;
      await docRef.set(data);
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  /// Returns all notifications for the given [userId], ordered newest first.
  Future<List<AppNotification>> getUserNotifications(String userId) async {
    try {
      final snapshot = await _notificationsRef(userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AppNotification.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user notifications: $e');
    }
  }

  /// Marks a single notification as read.
  Future<void> markAsRead(String userId, String notificationId) async {
    try {
      await _notificationsRef(userId).doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Marks all unread notifications for [userId] as read.
  Future<void> markAllAsRead(String userId) async {
    try {
      final snapshot = await _notificationsRef(userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  /// Returns the count of unread notifications for [userId].
  Future<int> getUnreadCount(String userId) async {
    try {
      final snapshot = await _notificationsRef(userId)
          .where('isRead', isEqualTo: false)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get unread notification count: $e');
    }
  }
}
