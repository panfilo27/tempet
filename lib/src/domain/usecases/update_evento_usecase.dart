import 'package:tempet/src/domain/entities/evento.dart';
import 'package:tempet/src/domain/repositories/evento_repository.dart';

class UpdateEventoUseCase {
  final EventoRepository repository;

  UpdateEventoUseCase(this.repository);

  Future<void> call(Evento evento) async {
    await repository.updateEvento(evento);
  }
}
