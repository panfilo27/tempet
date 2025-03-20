// lib/src/domain/entities/evento.dart

import 'notificacion.dart';
import 'tarea.dart';
import 'recordatorio.dart';

/// Entidad que representa un evento que puede incluir tareas y recordatorios.
class Evento {
  final String idEvento;
  final String descripcion;
  final DateTime fechaHora;
  final String repetir;
  final String estado;
  final List<Notificacion> notificaciones;
  final Tarea tarea;
  final Recordatorio recordatorio;

  Evento({
    required this.idEvento,
    required this.descripcion,
    required this.fechaHora,
    required this.repetir,
    required this.estado,
    required this.notificaciones,
    required this.tarea,
    required this.recordatorio,
  });

  /// Factory constructor para construir un [Evento] a partir de un Map.
  factory Evento.fromMap(Map<String, dynamic> map) {
    return Evento(
      idEvento: map['idEvento'] ?? '',
      descripcion: map['descripcion'] ?? '',
      fechaHora: DateTime.parse(map['fechaHora']),
      repetir: map['repetir'] ?? '',
      estado: map['estado'] ?? '',
      notificaciones: map['notificaciones'] != null
          ? (map['notificaciones'] as List)
          .map((e) => Notificacion.fromMap(e as Map<String, dynamic>))
          .toList()
          : [],
      tarea: Tarea.fromMap(map['tarea'] as Map<String, dynamic>),
      recordatorio: Recordatorio.fromMap(map['recordatorio'] as Map<String, dynamic>),
    );
  }

  /// Convierte este evento en un mapa para su almacenamiento.
  Map<String, dynamic> toMap() {
    return {
      'idEvento': idEvento,
      'descripcion': descripcion,
      'fechaHora': fechaHora.toIso8601String(),
      'repetir': repetir,
      'estado': estado,
      'notificaciones': notificaciones.map((n) => n.toMap()).toList(),
      'tarea': tarea.toMap(),
      'recordatorio': recordatorio.toMap(),
    };
  }
}
