// lib/src/domain/repositories/evento_repository.dart

import '../entities/evento.dart';

/// Interfaz del repositorio para gestionar eventos.
abstract class EventoRepository {
  /// Agrega un nuevo evento.
  Future<void> addEvento(Evento evento);

  /// Recupera la lista de eventos.
  Future<List<Evento>> getEventos();
}
