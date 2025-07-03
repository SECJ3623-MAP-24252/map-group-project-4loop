import 'package:apptracker/main.dart';
import 'package:apptracker/models/user.dart';
import 'package:apptracker/services/firebase/firebase_auth_service.dart';
import 'package:apptracker/views/chat/chat_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/notification_viewmodel.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Prevent internal re-initialization
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init() async {
    // Requesting permission for iOS/web
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Setup for local notifications (for foreground messages)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _localNotifications.initialize(initializationSettings);

    // Listen for incoming messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('A new onMessageOpenedApp event was published!');
      _handleNotificationTap(message.data);
    });
  }

  Future<void> _handleNotificationTap(Map<String, dynamic> data) async {
    final senderId = data['senderId'];
    if (senderId == null) return;

    // We need a way to get user data from an ID.
    // Let's assume FirebaseAuthService has a method `getUser`.
    // This is a bit of a hack, ideally you'd use a service locator.
    final authService = FirebaseAuthService();
    final user = await authService.getUser(senderId);

    if (user != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(peerUser: user),
        ),
      );
    }
  }

  Future<String?> getFcmToken() async {
    try {
      final token = await _fcm.getToken();
      log('FCM Token: $token');
      return token;
    } catch (e) {
      log('Failed to get FCM token: $e');
      return null;
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    log('Got a message whilst in the foreground!');
    log('Message data: ${message.data}');

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    // Add to NotificationViewModel for in-app bell
    final context = navigatorKey.currentContext;
    if (context != null && notification != null) {
      final notificationVM =
          Provider.of<NotificationViewModel>(context, listen: false);
      notificationVM.addNotification(
        NotificationItem(
          title: notification.title ?? 'Notification',
          body: notification.body ?? '',
          timestamp: DateTime.now(),
        ),
      );
    }

    if (notification != null && android != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel', // id
            'High Importance Notifications', // title
            channelDescription:
                'This channel is used for important notifications.', // description
            icon: android.smallIcon,
          ),
        ),
      );
    }
  }
}
