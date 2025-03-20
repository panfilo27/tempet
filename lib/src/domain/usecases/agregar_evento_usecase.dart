// lib/src/domain/usecases/agregar_evento_usecase.dart

import '../entities/evento.dart';
import '../repositories/evento_repository.dart';

/// Caso de uso para agregar un evento.
/// Este caso de uso se encarga de delegar la operación al repositorio correspondiente.
class AgregarEventoUseCase {
  final EventoRepository repository;

  /// Constructor que inyecta el repositorio de eventos.
  AgregarEventoUseCase(this.repository);

  /// Ejecuta el proceso de agregar un [evento].
  /// Retorna un [Future] que se completa cuando la operación finaliza.
  Future<void> call(Evento evento) async {
    await repository.addEvento(evento);
  }
}
