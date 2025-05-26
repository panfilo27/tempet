// lib/src/domain/usecases/cambiar_estado_tarea_usecase.dart
import '../repositories/evento_repository.dart';

class CambiarEstadoTareaUseCase {
  final EventoRepository repo;
  CambiarEstadoTareaUseCase(this.repo);

  /// idEvento  : documento a actualizar
  /// nuevoEstado: 'pendiente' | 'completada' | ...
  Future<void> call(String idEvento, String nuevoEstado) =>
      repo.updateEstadoTarea(idEvento, nuevoEstado);
}
