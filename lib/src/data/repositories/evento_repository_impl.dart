// lib/src/data/repositories/evento_repository_impl.dart

import '../../domain/entities/evento.dart';
import '../../domain/repositories/evento_repository.dart';
import '../datasources/remote/evento_firestore_datasource.dart';

/// Implementación de [EventoRepository] que utiliza el datasource remoto.
class EventoRepositoryImpl implements EventoRepository {
  final EventoFirestoreDatasource remoteDatasource;

  /// Constructor que inyecta la instancia de [EventoFirestoreDatasource].
  EventoRepositoryImpl({required this.remoteDatasource});

  /// Agrega un evento delegando la operación directamente al datasource remoto.
  @override
  Future<void> addEvento(Evento evento) async {
    await remoteDatasource.addEvento(evento);
  }

  /// Recupera la lista de eventos delegando la operación al datasource remoto.
  @override
  Future<List<Evento>> getEventos() async {
    return await remoteDatasource.getEventos();
  }

  @override
  Future<void> deleteEvento(String idEvento) async {
    return remoteDatasource.deleteEvento(idEvento);
  }
  @override
  Future<void> updateEvento(Evento evento) async {
    return remoteDatasource.updateEvento(evento);
  }
}

