import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:recap/models/remainder.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _localNotifications = FlutterLocalNotificationsPlugin();

  Future init() async {
    tz.initializeTimeZones();
    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings("ic_stat_circle_notifications"),
      ),
    );
    _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
  }

  NotificationDetails notificationDetailsMaker(
      bool isPersistent, Importance importance) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'Recap',
        'Notification Remainder',
        icon: 'ic_stat_circle_notifications',
        enableLights: true,
        channelDescription: "Notification Remainder for the user",
        visibility: NotificationVisibility.public,
        category: AndroidNotificationCategory.reminder,
        audioAttributesUsage: AudioAttributesUsage.notification,
        ongoing: isPersistent,
        autoCancel: !isPersistent,
        importance: importance,
        priority: Priority.max,
        styleInformation: const BigTextStyleInformation(''),
      ),
    );
  }

  Future showNotification(Remainder remainder) async {
    await _localNotifications.show(
      remainder.id,
      remainder.title,
      remainder.content,
      notificationDetailsMaker(
          remainder.isPersistent, Importance(remainder.importanceValue)),
    );
  }

  Future showScheduledNotification(Remainder remainder) async {
    await _localNotifications.zonedSchedule(
      remainder.id,
      remainder.title,
      remainder.content,
      tz.TZDateTime.from(remainder.scheduledDate!, tz.local),
      androidAllowWhileIdle: true,
      notificationDetailsMaker(
          remainder.isPersistent, Importance(remainder.importanceValue)),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
    );
  }

  Future cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }
}
