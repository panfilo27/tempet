// lib/src/domain/usecases/get_eventos_usecase.dart

import '../entities/evento.dart';
import '../repositories/evento_repository.dart';

/// Caso de uso para recuperar la lista de eventos.
class GetEventosUseCase {
  final EventoRepository repository;

  GetEventosUseCase(this.repository);

  /// Ejecuta la operación para obtener los eventos.
  Future<List<Evento>> call() async {
    return await repository.getEventos();
  }
}
