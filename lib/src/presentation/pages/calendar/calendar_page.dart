import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:tempet/src/presentation/pages/search_page.dart';
import 'package:tempet/src/presentation/widgets/event_info_panel.dart';
import 'package:tempet/src/presentation/widgets/user_drawer.dart';
import 'package:tempet/src/presentation/widgets/add_event_panel.dart';
// Se elimina la importación de datos dummy
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempet/src/presentation/blocs/add_event/evento_bloc.dart';
import 'package:tempet/src/presentation/blocs/add_event/evento_state.dart';
import 'package:tempet/src/domain/entities/evento.dart';

import '../../blocs/add_event/evento_event.dart';
import 'evento_calendar_datasource.dart';

// Incluimos nuestro EventoCalendarDataSource (definido arriba)
// Puedes ubicar la clase en un archivo aparte e importarla.

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarView _calendarView = CalendarView.month;
  final CalendarController _calendarController = CalendarController();
  // Centrado en la semana del 25 de feb de 2025
  DateTime _focusedDate = DateTime(2025, 2, 25);

  // Control para el mini menú de FAB.
  bool _isFabMenuExpanded = false;
  final PanelController _panelController = PanelController();
  // Para el panel de agregar/editar evento (cuando se presionan los mini FABs)
  String? _addEventType;
  // Para el panel de ver evento (cuando se toca un evento existente)
  Evento? _selectedEvento; // Usamos Evento en lugar de Meeting

  @override
  void initState() {
    super.initState();
    _calendarController.view = _calendarView;
  }

  String _getMonthName(int month) {
    const monthNames = [
      "Enero",
      "Febrero",
      "Marzo",
      "Abril",
      "Mayo",
      "Junio",
      "Julio",
      "Agosto",
      "Septiembre",
      "Octubre",
      "Noviembre",
      "Diciembre"
    ];
    return monthNames[month - 1];
  }

  String get _formattedDate => _getMonthName(_focusedDate.month);

  void _changeCalendarView(CalendarView view) {
    setState(() {
      _calendarView = view;
      _calendarController.view = view;
    });
  }

  void _onViewChanged(ViewChangedDetails details) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _focusedDate = details.visibleDates.first;
        });
      }
    });
  }

  // Al pulsar el mini FAB de recordatorio para agregar
  void _onAddReminder() {
    setState(() {
      _addEventType = "reminder";
      _isFabMenuExpanded = false;
      _selectedEvento = null;
    });
    _panelController.open();
  }

  // Al pulsar el mini FAB de tarea para agregar
  void _onAddTask() {
    setState(() {
      _addEventType = "task";
      _isFabMenuExpanded = false;
      _selectedEvento = null;
    });
    _panelController.open();
  }

  // Cuando se toca un evento existente, se muestra el panel en modo de visualización.
  void _onEventTap(CalendarTapDetails details) {
    if (details.appointments != null && details.appointments!.isNotEmpty) {
      setState(() {
        _selectedEvento = details.appointments!.first as Evento;
        _addEventType = null; // Modo visualización
      });
      _panelController.open();
    }
  }

  Widget _buildFabMenu() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        if (_isFabMenuExpanded) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 140.0),
            child: FloatingActionButton(
              onPressed: _onAddReminder,
              mini: true,
              child: const Icon(Icons.alarm),
              tooltip: "Agregar Recordatorio",
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 70.0),
            child: FloatingActionButton(
              onPressed: _onAddTask,
              mini: true,
              child: const Icon(Icons.task_alt),
              tooltip: "Agregar Tarea",
            ),
          ),
        ],
        FloatingActionButton(
          onPressed: () {
            setState(() {
              _isFabMenuExpanded = !_isFabMenuExpanded;
            });
          },
          child: Icon(_isFabMenuExpanded ? Icons.close : Icons.add),
          tooltip: _isFabMenuExpanded ? "Cerrar opciones" : "Agregar Evento",
        ),
      ],
    );
  }

  Route _createSearchRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
      const SearchPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween);
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return SlidingUpPanel(
      controller: _panelController,
      maxHeight: screenHeight * 0.95,
      minHeight: 0,
      snapPoint: 0.20,
      panelSnapping: true,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      // Si hay un evento seleccionado y no estamos en modo edición, mostramos ViewEventPanel;
      // de lo contrario, si _addEventType es no nulo, mostramos AddEventPanel (en modo agregar o editar).
      // ... dentro del build() de CalendarPage

      panel: _selectedEvento != null && _addEventType == null
          ? ViewEventPanel(
        // Asegúrate de adaptar ViewEventPanel para que también trabaje con Evento.
        evento: _selectedEvento!,
        onClose: () {
          _panelController.close();
          setState(() {
            _selectedEvento = null;
          });
        },
        onEdit: () {
          _panelController.close();
          Future.delayed(const Duration(milliseconds: 300), () {
            if (_selectedEvento != null) {
              setState(() {
                _addEventType = _selectedEvento!.descripcion.toLowerCase().contains("recordatorio")
                    ? "reminder"
                    : "task";
              });
              _panelController.open();
            }
          });
        },
        onDelete: () {
          // Lógica para borrar el evento.
        },
      )
          : (_addEventType != null
          ? AddEventPanel(
        eventType: _addEventType!,
        onClose: () {
          _panelController.close();
          setState(() {
            _addEventType = null;
            _selectedEvento = null;
          });
        },
        existingMeeting: _selectedEvento, // Ahora es de tipo Evento?
      )
          : Container()),
      onPanelClosed: () {
        setState(() {
          _selectedEvento = null;
          _addEventType = null;
        });
      },
      body: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: Text(_formattedDate),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    Navigator.of(context).push(_createSearchRoute());
                  },
                ),
              ],
            ),
            drawer: UserDrawer(onViewChange: _changeCalendarView),
            body: BlocBuilder<EventoBloc, EventoState>(
              builder: (context, state) {
                if (state is EventoLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is EventoLoaded) {
                  return SfCalendar(
                    controller: _calendarController,
                    view: _calendarView,
                    allowedViews: const [
                      CalendarView.day,
                      CalendarView.week,
                      CalendarView.month,
                      CalendarView.schedule,
                    ],
                    onViewChanged: _onViewChanged,
                    headerHeight: 0,
                    monthViewSettings: const MonthViewSettings(
                      appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                    ),
                    // Usamos nuestro EventoCalendarDataSource con los eventos reales.
                    dataSource: EventoCalendarDataSource(state.eventos),
                    onTap: _onEventTap,
                  );
                } else if (state is EventoFailure) {
                  return Center(child: Text("Error al cargar eventos: ${state.error}"));
                } else {
                  // En estado inicial, lanzamos el evento para cargar eventos y mostramos un indicador.
                  context.read<EventoBloc>().add(const LoadEventos());
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          if (_isFabMenuExpanded)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isFabMenuExpanded = false;
                  });
                },
                child: Container(
                  color: Colors.black.withOpacity(0.65),
                ),
              ),
            ),
          Positioned(
            bottom: 32,
            right: 16,
            child: _buildFabMenu(),
          ),
        ],
      ),
    );
  }
}
