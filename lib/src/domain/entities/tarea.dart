// lib/src/domain/entities/tarea.dart

class Tarea {
  final String prioridad;            // alta / normal / baja…
  final String estado;               // pendiente / completada

  Tarea({
    required this.prioridad,
    this.estado = 'pendiente',
  });

  factory Tarea.fromMap(Map<String, dynamic> map) {
    return Tarea(
      prioridad: map['prioridad'] ?? 'normal',
      estado   : map['estado']    ?? 'pendiente',
    );
  }

  Map<String, dynamic> toMap() => {
    'prioridad': prioridad,
    'estado'   : estado,
  };

  Tarea copyWith({String? prioridad, String? estado}) => Tarea(
    prioridad: prioridad ?? this.prioridad,
    estado   : estado   ?? this.estado,
  );
}
