import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tempet/src/domain/entities/evento.dart';

/// Gestiona la interacción con Cloud Firestore para eventos.
class EventoFirestoreDatasource {
  final FirebaseFirestore firestore;

  EventoFirestoreDatasource({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  /// Agrega un evento (ya debe llevar su `userId`).
  Future<void> addEvento(Evento evento) async {
    print('Enviando evento a Firestore: ${evento.toMap()}');
    try {
      await firestore
          .collection('eventos')
          .doc(evento.idEvento)
          .set(evento.toMap());
      print('Evento agregado exitosamente: ${evento.idEvento}');
    } catch (e) {
      print('Error al agregar evento: $e');
      rethrow;
    }
  }

  /// Recupera los eventos del usuario indicado.
  Future<List<Evento>> getEventos({required String userId}) async {
    print('Obteniendo eventos de $userId...');
    try {
      final snapshot = await firestore
          .collection('eventos')
          .where('userId', isEqualTo: userId)   // ➋ FILTRO
          .get();

      final eventos = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Evento.fromMap(data);
      }).toList();

      print('Eventos recuperados: ${eventos.length}');
      return eventos;
    } catch (e) {
      print('Error al obtener eventos: $e');
      rethrow;
    }
  }

  /// Elimina un evento por su id.
  Future<void> deleteEvento(String idEvento) async {
    print('Eliminando evento: $idEvento');
    try {
      await firestore.collection('eventos').doc(idEvento).delete();
      print('Evento eliminado.');
    } catch (e) {
      print('Error al eliminar evento: $e');
      rethrow;
    }
  }

  /// Actualiza completamente un evento.
  Future<void> updateEvento(Evento evento) async {
    print('Actualizando evento: ${evento.idEvento}');
    try {
      await firestore
          .collection('eventos')
          .doc(evento.idEvento)
          .update(evento.toMap());
      print('Evento actualizado.');
    } catch (e) {
      print('Error al actualizar evento: $e');
      rethrow;
    }
  }

  /// Cambia sólo el estado de la tarea dentro del evento.
  Future<void> updateEstadoTarea({
    required String idEvento,
    required String nuevoEstado, // 'pendiente' | 'completada' ...
  }) async {
    await firestore.collection('eventos').doc(idEvento).update({
      'tarea.estado': nuevoEstado,
    });
  }
}
