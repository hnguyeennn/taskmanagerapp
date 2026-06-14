import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/task.dart' hide Priority;

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._init();

  // Khởi tạo notification service
  Future<void> init() async {
    // Cấu hình timezone
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    // Cấu hình cho Android
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(settings);

    // Yêu cầu quyền thông báo cho Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Yêu cầu quyền đặt alarm chính xác cho Android 12+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  // Đặt lịch nhắc nhở cho task (reminder trước + thông báo đúng hạn)
  Future<void> scheduleReminder(Task task) async {
    if (task.id == null) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'task_reminder_channel',
      'Nhắc nhở công việc',
      channelDescription: 'Thông báo nhắc nhở các công việc cần làm',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    final now = DateTime.now();

    // Thông báo nhắc trước (nếu bật reminder và chưa qua)
    if (task.hasReminder && task.reminderTime != null &&
        task.reminderTime!.isAfter(now)) {
      await _plugin.zonedSchedule(
        task.id!,
        'Nhắc nhở: ${task.title}',
        task.description.isEmpty
            ? 'Công việc sắp đến hạn'
            : task.description,
        tz.TZDateTime.from(task.reminderTime!, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: task.id.toString(),
      );
    }

    // Thông báo đúng lúc đến hạn (dueDate), dùng id offset để tránh trùng
    if (task.dueDate.isAfter(now)) {
      await _plugin.zonedSchedule(
        task.id! + 100000,
        'Đến hạn: ${task.title}',
        task.description.isEmpty
            ? 'Công việc đã đến hạn cần hoàn thành!'
            : task.description,
        tz.TZDateTime.from(task.dueDate, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: task.id.toString(),
      );
    }
  }

  // Hủy 1 nhắc nhở (cả reminder lẫn due notification)
  Future<void> cancelReminder(int taskId) async {
    await _plugin.cancel(taskId);
    await _plugin.cancel(taskId + 100000);
  }

  // Hủy tất cả nhắc nhở
  Future<void> cancelAllReminders() async {
    await _plugin.cancelAll();
  }

  // Thông báo kết thúc phiên Pomodoro (có rung + âm thanh)
  Future<void> showPomodoroComplete({
    required String title,
    required String body,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'pomodoro_channel',
      'Pomodoro Timer',
      channelDescription: 'Thông báo khi kết thúc phiên Pomodoro',
      importance: Importance.max,
      priority: Priority.max,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 500]),
      playSound: true,
      fullScreenIntent: true,
      ticker: 'pomodoro',
    );

    await _plugin.show(
      99999,
      title,
      body,
      NotificationDetails(android: androidDetails),
    );
  }
}