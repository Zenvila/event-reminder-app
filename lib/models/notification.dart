import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

class Notification {
  String notificationID;
  String eventID;
  String time;
  String date;
  bool isEnabled;

  Notification({
    required this.notificationID,
    required this.eventID,
    required this.time,
    required this.date,
    required this.isEnabled,
  });

  Future<void> scheduleNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  ) async {
    if (!isEnabled) return;

    try {
      String cleanedDate = date.replaceFirst('Today, ', '');
      DateTime eventDate = DateFormat('EEEE, MMMM d, yyyy').parse(cleanedDate);
      String startTime = time.split(' - ')[0];
      DateTime eventTime = DateFormat('h:mm a').parse(startTime);
      DateTime scheduledDateTime = DateTime(
        eventDate.year,
        eventDate.month,
        eventDate.day,
        eventTime.hour,
        eventTime.minute,
      );

      final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(
        scheduledDateTime,
        tz.local,
      );
      if (tzScheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
        print('Cannot schedule notification for past time: $tzScheduledDate');
        return;
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        int.parse(notificationID),
        'Event Reminder',
        'Your event $eventID is starting soon!',
        tzScheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'event_reminder_channel',
            'Event Reminders',
            channelDescription: 'Notifications for your scheduled events',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }
}
