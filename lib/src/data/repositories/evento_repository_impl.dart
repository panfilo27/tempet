import 'package:firebase_auth/firebase_auth.dart';                // NUEVO
import '../../domain/entities/evento.dart';
import '../../domain/repositories/evento_repository.dart';
import '../datasources/remote/evento_firestore_datasource.dart';

/// Implementación de [EventoRepository] que usa el datasource remoto.
class EventoRepositoryImpl implements EventoRepository {
  final EventoFirestoreDatasource remoteDatasource;

  EventoRepositoryImpl({required this.remoteDatasource});

  @override
  Future<void> addEvento(Evento evento) async {
    await remoteDatasource.addEvento(evento);
  }

  /// Devuelve solo los eventos del usuario autenticado.
  @override
  Future<List<Evento>> getEventos() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return []; // o lanza una excepción, según tu flujo.
    return await remoteDatasource.getEventos(userId: uid);
  }

  @override
  Future<void> deleteEvento(String idEvento) async {
    return remoteDatasource.deleteEvento(idEvento);
  }

  @override
  Future<void> updateEvento(Evento evento) async {
    return remoteDatasource.updateEvento(evento);
  }

  @override
  Future<void> updateEstadoTarea(String idEvento, String estado) =>
      remoteDatasource.updateEstadoTarea(
        idEvento: idEvento,
        nuevoEstado: estado,
      );
}
