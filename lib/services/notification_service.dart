/*
// lib/src/external/notifications/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // ❷ Cargar base de datos de zonas
    tz.initializeTimeZones();

    // ❸ Fijar manualmente Veracruz / CDMX
    tz.setLocalLocation(tz.getLocation('America/Mexico_City'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      const InitializationSettings(android: android),
    );

    // Canal por defecto
    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
      'default', 'Recordatorios',
      description: 'Notificaciones de eventos',
      importance: Importance.high,
    ));
  }

  static Future<void> scheduleEventReminder({
    required String idEvento,
    required String titulo,
    required DateTime fechaEvento,
  }) async {
    final trigger = fechaEvento.subtract(const Duration(minutes: 30));
    if (trigger.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      idEvento.hashCode,
      titulo,
      '',
      tz.TZDateTime.from(trigger, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'default',
          'Recordatorios',
          channelDescription: 'Notificaciones de eventos',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> cancel(String idEvento) =>
      _plugin.cancel(idEvento.hashCode);
}
*/
