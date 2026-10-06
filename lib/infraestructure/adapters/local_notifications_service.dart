import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Thin wrapper around `flutter_local_notifications` for PRD.md H3.3's OS
/// push reminders (WORK_PLAN.md 2.3).
///
/// UNVERIFIED: this was written without being able to run `flutter pub get`
/// or a compiler in the sandbox that built it — there is no Flutter SDK
/// available there. The call shape (`zonedSchedule` with
/// `androidScheduleMode`) matches recent `flutter_local_notifications`
/// releases, but plugin APIs do shift between majors. Treat this file as
/// the one to fix first if the app fails to build after `flutter pub get`,
/// and budget real-device QA for it regardless (WORK_PLAN.md 2.3 — a
/// notification actually arriving with the app closed isn't something a
/// unit test can prove).
class LocalNotificationsService {
  static final LocalNotificationsService _instance =
      LocalNotificationsService._internal();
  factory LocalNotificationsService() => _instance;
  LocalNotificationsService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  /// Schedules (or replaces, if [id] was already scheduled) a reminder.
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    await init();
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(dateTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'scheduled_expenses',
          'Gastos programados',
          channelDescription: 'Recordatorios de gastos periódicos',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelReminder(int id) async {
    await _plugin.cancel(id);
  }
}
