import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

/// Clase que representa un evento (recordatorio o tarea)
class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}

/// DataSource para el SfCalendar basado en una lista de Meeting
class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) => appointments![index].from;

  @override
  DateTime getEndTime(int index) => appointments![index].to;

  @override
  String getSubject(int index) => appointments![index].eventName;

  @override
  Color getColor(int index) => appointments![index].background;

  @override
  bool isAllDay(int index) => appointments![index].isAllDay;
}

/// Datos falsos para la semana que incluye el 25 de febrero de 2025.
/// Suponiendo que la semana va de lunes 24 feb a domingo 2 mar de 2025.
final List<Meeting> dummyMeetings = <Meeting>[
  // 5 Recordatorios
  Meeting(
    'Recordatorio 1',
    DateTime(2025, 2, 24, 9, 0),
    DateTime(2025, 2, 24, 10, 0),
    Colors.red,
    false,
  ),
  Meeting(
    'Recordatorio 2',
    DateTime(2025, 2, 25, 11, 0),
    DateTime(2025, 2, 25, 12, 0),
    Colors.blue,
    false,
  ),
  Meeting(
    'Recordatorio 3',
    DateTime(2025, 2, 26, 14, 0),
    DateTime(2025, 2, 26, 15, 0),
    Colors.green,
    false,
  ),
  Meeting(
    'Recordatorio 4',
    DateTime(2025, 2, 28, 16, 0),
    DateTime(2025, 2, 28, 17, 0),
    Colors.orange,
    false,
  ),
  Meeting(
    'Recordatorio 5',
    DateTime(2025, 3, 1, 10, 0),
    DateTime(2025, 3, 1, 11, 0),
    Colors.purple,
    false,
  ),
  // 3 Tareas
  Meeting(
    'Tarea 1',
    DateTime(2025, 2, 25, 8, 0),
    DateTime(2025, 2, 25, 8, 30),
    Colors.teal,
    false,
  ),
  Meeting(
    'Tarea 2',
    DateTime(2025, 2, 27, 13, 0),
    DateTime(2025, 2, 27, 13, 30),
    Colors.indigo,
    false,
  ),
  Meeting(
    'Tarea 3',
    DateTime(2025, 3, 2, 12, 0),
    DateTime(2025, 3, 2, 12, 30),
    Colors.brown,
    false,
  ),
];
