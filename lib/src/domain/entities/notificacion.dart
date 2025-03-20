// lib/src/domain/entities/notificacion.dart

class Notificacion {
  final String idNotificacion;
  final String mensaje;
  final DateTime fechaHora;

  Notificacion({
    required this.idNotificacion,
    required this.mensaje,
    required this.fechaHora,
  });

  factory Notificacion.fromMap(Map<String, dynamic> map) {
    return Notificacion(
      idNotificacion: map['idNotificacion'] ?? '',
      mensaje: map['mensaje'] ?? '',
      fechaHora: DateTime.parse(map['fechaHora']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idNotificacion': idNotificacion,
      'mensaje': mensaje,
      'fechaHora': fechaHora.toIso8601String(),
    };
  }
}
