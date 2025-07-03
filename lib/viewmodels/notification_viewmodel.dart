import 'package:flutter/material.dart';

class NotificationItem {
  final String title;
  final String body;
  final DateTime timestamp;
  NotificationItem(
      {required this.title, required this.body, required this.timestamp});
}

class NotificationViewModel extends ChangeNotifier {
  final List<NotificationItem> _notifications = [];
  bool _hasUnread = false;
  bool _hasUnreadChat = false;
  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  bool get hasUnread => _hasUnread || _hasUnreadChat;
  bool get hasUnreadChat => _hasUnreadChat;

  void addNotification(NotificationItem notification) {
    _notifications.insert(0, notification);
    _hasUnread = true;
    notifyListeners();
  }

  void addChatNotification() {
    _hasUnreadChat = true;
    notifyListeners();
  }

  void markAllRead() {
    _hasUnread = false;
    _hasUnreadChat = false;
    notifyListeners();
  }

  void markChatRead() {
    _hasUnreadChat = false;
    notifyListeners();
  }

  // TODO: Integrate with FCM to receive push notifications
}
