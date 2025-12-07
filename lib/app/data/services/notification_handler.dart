import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../providers/notification_provider.dart';
import '../models/notification_log_model.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Pesan diterima di background: ${message.notification?.title}');
  // Note: We can't easily access Hive/GetX here without initializing them in background isolate.
  // For simplicity, we might skip logging background messages here or setup Hive again.
}

class NotificationHandler {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotification =
      FlutterLocalNotificationsPlugin();

  // Lazily get NotificationProvider to avoid init issues if not ready
  final NotificationProvider _notificationProvider = Get.put(
    NotificationProvider(),
  );

  // Android Notification Channel
  final _androidChannel = const AndroidNotificationChannel(
    'channel_notification',
    'High Importance Notification',
    description: 'Used For Notification',
    importance: Importance.defaultImportance,
  );

  Future<void> initPushNotification() async {
    // Request permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('Izin yang diberikan pengguna: ${settings.authorizationStatus}');

    // Get FCM Token
    _firebaseMessaging.getToken().then((token) {
      print('FCM Token: $token');
    });

    // Handle Terminated State
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print("Pesan saat aplikasi terminated: ${message.notification?.title}");
        _logNotification(
          message.notification?.title,
          message.notification?.body,
          'push',
        );
      }
    });

    // Handle Background State
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle Foreground State
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;

      _localNotification.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: jsonEncode(message.toMap()),
      );
      print(
        'Pesan diterima saat aplikasi di foreground: ${message.notification?.title}',
      );
      _logNotification(notification.title, notification.body, 'push');
    });

    // Handle Message Opened
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Pesan dibuka dari notifikasi: ${message.notification?.title}');
    });
  }

  Future<void> initLocalNotification() async {
    tz.initializeTimeZones();
    try {
      // Handle compatibility with different flutter_timezone versions
      final dynamic localTimezone = await FlutterTimezone.getLocalTimezone();
      String timeZoneName;
      if (localTimezone is String) {
        timeZoneName = localTimezone;
      } else {
        // Assume TimezoneInfo object, try accessing 'id'
        // Note: If dynamic access fails, check toString parsing or docs
        try {
          timeZoneName = localTimezone.id;
        } catch (_) {
          // Fallback for TimezoneInfo(Asia/Jakarta, ...) string format if no .id
          final str = localTimezone.toString();
          if (str.startsWith('TimezoneInfo(')) {
            timeZoneName = str.split(',')[0].substring(13);
          } else {
            timeZoneName = 'UTC';
          }
        }
      }
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      print('Error setting local timezone: $e');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // iOS Settings
    const ios = DarwinInitializationSettings();

    // Android Settings
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: android, iOS: ios);

    await _localNotification.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        // Handle local notification tap
        print('Local Notification Tapped: ${details.payload}');
      },
    );
  }

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channel_notification',
      'High Importance Notification',
      channelDescription: 'Used For Notification',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const iOSPlatformChannelSpecifics = DarwinNotificationDetails();

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotification.show(
      DateTime.now().millisecond, // Unique ID for each notification
      title,
      body,
      platformChannelSpecifics,
      payload: 'plain notification',
    );
    _logNotification(title, body, 'local');
  }

  Future<void> showProgressNotification() async {
    const maxProgress = 5;
    for (var i = 0; i <= maxProgress; i++) {
      await Future.delayed(const Duration(seconds: 1), () async {
        final androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'progress_channel',
          'Progress Notification',
          channelDescription: 'Channel for progress notifications',
          channelShowBadge: false,
          importance: Importance.max,
          priority: Priority.high,
          onlyAlertOnce: true,
          showProgress: true,
          maxProgress: maxProgress,
          progress: i,
        );

        final platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
        );

        await _localNotification.show(
          1,
          'Progress Notification',
          'Download in progress...',
          platformChannelSpecifics,
        );
      });
    }
  }

  Future<void> showCustomSoundNotification() async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'custom_sound_channel',
      'Custom Sound Notification',
      channelDescription: 'Notifications with custom sound',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      sound: RawResourceAndroidNotificationSound('hehe'),
      playSound: true,
    );

    const iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      sound: 'hehe.mp3',
    );

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotification.show(
      DateTime.now().millisecond,
      'Custom Sound Notification',
      'This is a notification with a custom sound!',
      platformChannelSpecifics,
      payload: 'custom_sound',
    );
    _logNotification(
      'Custom Sound Notification',
      'This is a notification with a custom sound!',
      'local',
    );
  }

  void _logNotification(String? title, String? body, String type) {
    if (title == null) return;
    try {
      _notificationProvider.addLog(
        NotificationLogModel(
          title: title,
          body: body ?? '',
          timestamp: DateTime.now(),
          type: type,
        ),
      );
    } catch (e) {
      print('Failed to log notification: $e');
    }
  }
}
