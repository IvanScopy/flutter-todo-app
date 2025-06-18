import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for iOS
    if (Platform.isIOS || Platform.isMacOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }

    // Request permissions for Android 13+
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
    }
  }

  Future<void> scheduleTaskReminder({
    required int taskId,
    required String taskTitle,
    required DateTime scheduledTime,
    String? description,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'task_reminders',
      'Task Reminders',
      channelDescription: 'Notifications for task due dates and reminders',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Task Reminder',
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
      macOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      taskId,
      'Task Reminder: $taskTitle',
      description ?? 'Don\'t forget to complete this task!',
      tz.TZDateTime.from(scheduledTime, tz.local),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'task_$taskId',
    );
  }

  Future<void> scheduleTaskDueReminder({
    required int taskId,
    required String taskTitle,
    required DateTime dueDate,
    String? description,
  }) async {
    // Schedule notification 1 hour before due date
    final reminderTime = dueDate.subtract(const Duration(hours: 1));
    
    if (reminderTime.isAfter(DateTime.now())) {
      await scheduleTaskReminder(
        taskId: taskId * 1000, // Unique ID for due date reminder
        taskTitle: taskTitle,
        scheduledTime: reminderTime,
        description: description ?? 'This task is due in 1 hour!',
      );
    }

    // Schedule notification at due date
    if (dueDate.isAfter(DateTime.now())) {
      await scheduleTaskReminder(
        taskId: taskId * 1000 + 1, // Unique ID for due date notification
        taskTitle: taskTitle,
        scheduledTime: dueDate,
        description: description ?? 'This task is due now!',
      );
    }
  }

  Future<void> cancelTaskNotifications(int taskId) async {
    // Cancel both reminder and due date notifications
    await _flutterLocalNotificationsPlugin.cancel(taskId * 1000);
    await _flutterLocalNotificationsPlugin.cancel(taskId * 1000 + 1);
  }

  Future<void> showTaskCompletedNotification({
    required String taskTitle,
  }) async {    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'task_completed',
      'Task Completed',
      channelDescription: 'Notifications for completed tasks',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ticker: 'Task Completed',
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
      macOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      999999, // High ID for instant notifications
      'Task Completed! 🎉',
      'Great job completing "$taskTitle"!',
      platformChannelSpecifics,
      payload: 'completed',
    );
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  void _onNotificationTapped(NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      print('Notification tapped with payload: $payload');
      // Handle navigation based on payload
      // This could be connected to a navigation service
    }
  }
}
