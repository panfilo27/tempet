import 'package:tempet/src/domain/repositories/evento_repository.dart';

class DeleteEventoUseCase {
  final EventoRepository repository;

  DeleteEventoUseCase(this.repository);

  Future<void> call(String idEvento) async {
    await repository.deleteEvento(idEvento);
  }
}
