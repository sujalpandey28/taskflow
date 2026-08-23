import 'package:flutter/foundation.dart';
import 'package:taskflow/data/models/notifications_model.dart';
import 'package:taskflow/data/repositories/task_flowrepository.dart';

enum NotificationStatus { initial, loading, loaded, error }

class NotificationProvider extends ChangeNotifier {
  final TaskFlowRepository repository;

  NotificationProvider({required this.repository});

  NotificationStatus _status = NotificationStatus.initial;

  NotificationStatus get status => _status;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  int get unreadCount =>
      _notifications.where((notification) => !notification.read).length;

  Future<void> loadNotifications(String userId) async {
    debugPrint('NOTIFICATION LOAD USER ID: $userId');

    _status = NotificationStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await repository.getNotifications(userId);

      debugPrint('NOTIFICATIONS RETURNED: ${_notifications.length}');

      for (final notification in _notifications) {
        debugPrint(
          'NOTIFICATION: ${notification.id} '
          'USER: ${notification.userId}',
        );
      }

      _status = NotificationStatus.loaded;
      notifyListeners();
    } catch (e) {
      debugPrint('NOTIFICATION ERROR: $e');

      _status = NotificationStatus.error;
      _errorMessage = 'Failed to load notifications.';
      notifyListeners();
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      _errorMessage = null;

      await repository.markNotificationAsRead(notificationId);

      final index = _notifications.indexWhere(
        (notification) => notification.id == notificationId,
      );

      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(read: true);
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to mark notification as read.';
      notifyListeners();

      return false;
    }
  }

  Future<bool> deleteNotification(String notificationId) async {
    try {
      _errorMessage = null;

      await repository.deleteNotification(notificationId);

      _notifications.removeWhere(
        (notification) => notification.id == notificationId,
      );

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete notification.';
      notifyListeners();

      return false;
    }
  }

  Future<void> markAllAsRead() async {
    final unreadNotifications = _notifications
        .where((notification) => !notification.read)
        .toList();

    for (final notification in unreadNotifications) {
      await repository.markNotificationAsRead(notification.id);
    }

    _notifications = _notifications
        .map((notification) => notification.copyWith(read: true))
        .toList();

    notifyListeners();
  }
}
