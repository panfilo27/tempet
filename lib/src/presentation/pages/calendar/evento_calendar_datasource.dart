// lib/src/presentation/pages/calendar/evento_calendar_datasource.dart

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:tempet/src/domain/entities/evento.dart';

/// Adaptador entre tu entidad [Evento] y los `Appointment`
/// que necesita el `SfCalendar`.
class EventoCalendarDataSource extends CalendarDataSource {
  EventoCalendarDataSource(List<Evento> source) {
    appointments = source;
  }

  Evento _ev(int i) => appointments![i] as Evento;

  // ────────────── mapeo básico ──────────────
  @override DateTime getStartTime(int index) => _ev(index).fechaInicio;
  @override DateTime getEndTime(int index)   => _ev(index).fechaFin;
  @override String getSubject(int index)     => _ev(index).titulo;
  @override Color getColor(int index)        => Color(_ev(index).color);

  /// Un evento se considera "all-day" cuando abarca ≥1 día completo
  /// (diferencia en días ≥ 1).
  @override bool isAllDay(int index) =>
      _ev(index).fechaFin.difference(_ev(index).fechaInicio).inDays >= 1;
}
