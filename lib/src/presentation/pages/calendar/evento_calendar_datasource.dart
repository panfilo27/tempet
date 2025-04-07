//lib/src/presentation/pages/calendar/evento_calendar_datasource.dart

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:tempet/src/domain/entities/evento.dart';

/// DataSource para el calendario, basado en una lista de [Evento].
class EventoCalendarDataSource extends CalendarDataSource {
  EventoCalendarDataSource(List<Evento> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    final Evento evento = appointments![index] as Evento;
    return evento.fechaHora;
  }

  @override
  DateTime getEndTime(int index) {
    final Evento evento = appointments![index] as Evento;
    // Asumimos una duración fija de 1 hora para cada evento; ajústalo según tus necesidades.
    return evento.fechaHora.add(const Duration(hours: 1));
  }

  @override
  String getSubject(int index) {
    final Evento evento = appointments![index] as Evento;
    return evento.descripcion;
  }

  @override
  Color getColor(int index) {
    // Puedes personalizar el color si tu entidad Evento tiene esa propiedad.
    return Colors.blue;
  }
}
