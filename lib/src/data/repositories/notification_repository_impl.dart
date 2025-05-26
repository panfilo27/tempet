/*
// lib/src/data/repositories/notification_repository_impl.dart
import 'package:tempet/src/domain/repositories/notification_repository.dart';

import '../../../services/notification_service.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  @override
  Future<void> scheduleNotification({
    required String idEvento,
    required String title,
    required DateTime fechaEvento,
  }) async {
    // Dispara la notificación 30 min antes
    await NotificationService.scheduleEventReminder(
      idEvento : idEvento,
      titulo   : title,
      fechaEvento: fechaEvento,
    );
  }

  @override
  Future<void> cancelNotification(String idEvento) =>
      NotificationService.cancel(idEvento);
}
*/
