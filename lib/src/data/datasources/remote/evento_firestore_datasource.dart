// lib/src/data/datasources/remote/evento_firestore_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tempet/src/domain/entities/evento.dart';

/// Clase encargada de interactuar con Cloud Firestore para agregar y cargar eventos.
class EventoFirestoreDatasource {
  final FirebaseFirestore firestore;

  /// Constructor que permite inyectar una instancia de [FirebaseFirestore].
  /// Si no se proporciona, se utiliza la instancia por defecto.
  EventoFirestoreDatasource({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  /// Agrega un evento a la colección "eventos" en Firestore.
  Future<void> addEvento(Evento evento) async {
    print('Enviando evento a Firestore: ${evento.toMap()}');
    try {
      await firestore.collection('eventos').doc(evento.idEvento).set(evento.toMap());
      print('Evento agregado exitosamente: ${evento.idEvento}');
    } catch (e) {
      print('Error al agregar evento: $e');
      rethrow;
    }
  }

  /// Recupera la lista de eventos desde la colección "eventos" en Firestore.
  Future<List<Evento>> getEventos() async {
    print('Obteniendo eventos desde Firestore...');
    try {
      QuerySnapshot snapshot = await firestore.collection('eventos').get();
      List<Evento> eventos = snapshot.docs.map((doc) {
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
}
