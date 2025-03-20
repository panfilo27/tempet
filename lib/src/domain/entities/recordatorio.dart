// lib/src/domain/entities/recordatorio.dart

class Recordatorio {
  final String repetir;
  final String ubicacion;

  Recordatorio({required this.repetir, required this.ubicacion});

  factory Recordatorio.fromMap(Map<String, dynamic> map) {
    return Recordatorio(
      repetir: map['repetir'] ?? '',
      ubicacion: map['ubicacion'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'repetir': repetir, 'ubicacion': ubicacion};
  }
}
