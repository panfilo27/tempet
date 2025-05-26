// lib/src/domain/repositories/notification_repository.dart
abstract class NotificationRepository {
  Future<void> scheduleNotification({
    required String idEvento,
    required String title,
    required DateTime fechaEvento,
  });

  Future<void> cancelNotification(String idEvento);
}
