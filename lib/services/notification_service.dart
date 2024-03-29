import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:recap/models/reminder.dart';
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
        ?.requestNotificationsPermission();
  }

  NotificationDetails notificationDetailsMaker(
      bool isPersistent, String encodedImageBytes, Importance importance) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'Recap',
        'Notification Reminder',
        channelDescription: "Notification Reminder App",
        icon: 'ic_stat_circle_notifications',
        importance: importance,
        priority: Priority.max,
        styleInformation: (encodedImageBytes.isNotEmpty)
            ? BigPictureStyleInformation(
                FilePathAndroidBitmap(encodedImageBytes))
            : const BigTextStyleInformation(''),
        autoCancel: !isPersistent,
        ongoing: isPersistent,
        enableLights: true,
        visibility: NotificationVisibility.public,
        category: AndroidNotificationCategory.reminder,
      ),
    );
  }

  Future showNotification(Reminder reminder) async {
    try {
      await _localNotifications.show(
        reminder.id,
        reminder.title,
        reminder.content,
        notificationDetailsMaker(
            reminder.isPersistent, reminder.imageFilePath, reminder.importance),
      );
    } catch (_) {}
  }

  Future showScheduledNotification(Reminder reminder) async {
    try {
      await _localNotifications.zonedSchedule(
        reminder.id,
        reminder.title,
        reminder.content,
        tz.TZDateTime.from(reminder.scheduledDate!, tz.local),
        notificationDetailsMaker(
            reminder.isPersistent, reminder.imageFilePath, reminder.importance),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
      );
    } catch (_) {}
  }

  Future cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }
}
