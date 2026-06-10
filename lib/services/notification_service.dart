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

  // Đặt lịch nhắc nhở cho task
  Future<void> scheduleReminder(Task task) async {
    if (!task.hasReminder || task.reminderTime == null || task.id == null) {
      return;
    }

    // Nếu thời gian nhắc đã qua thì không đặt
    if (task.reminderTime!.isBefore(DateTime.now())) {
      return;
    }

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

    await _plugin.zonedSchedule(
      task.id!,
      'Nhắc nhở: ${task.title}',
      task.description.isEmpty
          ? 'Công việc cần làm: ${task.title}'
          : task.description,
      tz.TZDateTime.from(task.reminderTime!, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: task.id.toString(),
    );
  }

  // Hủy 1 nhắc nhở
  Future<void> cancelReminder(int taskId) async {
    await _plugin.cancel(taskId);
  }

  // Hủy tất cả nhắc nhở
  Future<void> cancelAllReminders() async {
    await _plugin.cancelAll();
  }
}