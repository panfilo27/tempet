// lib/src/domain/usecases/notification_usecases.dart
import '../repositories/notification_repository.dart';

class ProgramarNotificacionEvento {
  final NotificationRepository repo;
  ProgramarNotificacionEvento(this.repo);

  Future<void> call(String idEvento, String titulo, DateTime inicio) =>
      repo.scheduleNotification(
        idEvento: idEvento,
        title: titulo,
        fechaEvento: inicio,
      );
}

class CancelarNotificacionEvento {
  final NotificationRepository repo;
  CancelarNotificacionEvento(this.repo);

  Future<void> call(String idEvento) => repo.cancelNotification(idEvento);
}
