import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';

final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());

final userNotificationsProvider = FutureProvider.autoDispose
    .family<List<AppNotification>, String>((ref, userId) async {
  return ref.read(notificationServiceProvider).getUserNotifications(userId);
});

final unreadCountProvider =
    FutureProvider.autoDispose.family<int, String>((ref, userId) async {
  return ref.read(notificationServiceProvider).getUnreadCount(userId);
});
