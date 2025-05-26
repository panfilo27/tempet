import 'notificacion.dart';
import 'tarea.dart';
import 'recordatorio.dart';

/// Entidad que representa un evento (tarea o recordatorio).
class Evento {
  final String idEvento;
  final String userId;                 // ➊ NUEVO
  final String titulo;
  final String detalles;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final int color;
  final List<Notificacion> notificaciones;
  final Tarea tarea;
  final Recordatorio recordatorio;

  Evento({
    required this.idEvento,
    required this.userId,              // ➊ NUEVO
    required this.titulo,
    required this.detalles,
    required this.fechaInicio,
    required this.fechaFin,
    required this.color,
    required this.notificaciones,
    required this.tarea,
    required this.recordatorio,
  });

  // ─────────── copyWith ───────────
  Evento copyWith({
    String? idEvento,
    String? userId,                    // ➊ NUEVO
    String? titulo,
    String? detalles,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    int? color,
    List<Notificacion>? notificaciones,
    Tarea? tarea,
    Recordatorio? recordatorio,
  }) {
    return Evento(
      idEvento      : idEvento      ?? this.idEvento,
      userId        : userId        ?? this.userId,   // ➊
      titulo        : titulo        ?? this.titulo,
      detalles      : detalles      ?? this.detalles,
      fechaInicio   : fechaInicio   ?? this.fechaInicio,
      fechaFin      : fechaFin      ?? this.fechaFin,
      color         : color         ?? this.color,
      notificaciones: notificaciones ?? this.notificaciones,
      tarea         : tarea         ?? this.tarea,
      recordatorio  : recordatorio  ?? this.recordatorio,
    );
  }

  // ─────────── fromMap / toMap ───────────
  factory Evento.fromMap(Map<String, dynamic> map) {
    final inicioStr = map['fechaInicio'] as String?;
    final finStr    = map['fechaFin']    as String?;

    return Evento(
      idEvento : map['idEvento'] as String? ?? '',
      userId   : map['userId']   as String? ?? '',    // ➊
      titulo   : map['titulo']   as String? ?? '',
      detalles : map['detalles'] as String? ?? '',
      fechaInicio: (inicioStr != null && inicioStr.isNotEmpty)
          ? DateTime.parse(inicioStr)
          : DateTime.now(),
      fechaFin: (finStr != null && finStr.isNotEmpty)
          ? DateTime.parse(finStr)
          : DateTime.now(),
      color: map['color'] as int? ?? 0xFF2196F3,
      notificaciones: map['notificaciones'] != null
          ? (map['notificaciones'] as List)
          .map((e) => Notificacion.fromMap(e as Map<String, dynamic>))
          .toList()
          : [],
      tarea       : Tarea.fromMap(map['tarea'] as Map<String, dynamic>),
      recordatorio: Recordatorio.fromMap(
          map['recordatorio'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toMap() => {
    'idEvento'      : idEvento,
    'userId'        : userId,                       // ➊
    'titulo'        : titulo,
    'detalles'      : detalles,
    'fechaInicio'   : fechaInicio.toIso8601String(),
    'fechaFin'      : fechaFin.toIso8601String(),
    'color'         : color,
    'notificaciones': notificaciones.map((n) => n.toMap()).toList(),
    'tarea'         : tarea.toMap(),
    'recordatorio'  : recordatorio.toMap(),
  };

  @override
  String toString() => 'Evento($titulo @ $fechaInicio)';
}
