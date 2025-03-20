// lib/src/domain/entities/tarea.dart

class Tarea {
  final String prioridad;

  Tarea({required this.prioridad});

  factory Tarea.fromMap(Map<String, dynamic> map) {
    return Tarea(
      prioridad: map['prioridad'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'prioridad': prioridad};
  }
}
