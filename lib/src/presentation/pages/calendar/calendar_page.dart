// lib/src/presentation/pages/calendar_page.dart

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:tempet/src/presentation/pages/search_page.dart';
import 'package:tempet/src/presentation/widgets/view_event_panel.dart';
import 'package:tempet/src/presentation/widgets/user_drawer.dart';
import 'package:tempet/src/presentation/widgets/add_event_panel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempet/src/presentation/blocs/add_event/evento_bloc.dart';
import 'package:tempet/src/presentation/blocs/add_event/evento_state.dart';
import 'package:tempet/src/domain/entities/evento.dart';
import '../../blocs/add_event/evento_event.dart';
import 'evento_calendar_datasource.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarView _calendarView = CalendarView.month;
  final CalendarController _calendarController = CalendarController();
  // Fecha inicial para centrar el calendario.
  DateTime _focusedDate = DateTime(2025, 2, 25);

  // Control para el mini menú de FAB.
  bool _isFabMenuExpanded = false;
  final PanelController _panelController = PanelController();
  // Variable para determinar el tipo de evento al agregar/editar.
  String? _addEventType;
  // Evento seleccionado para visualizar detalles.
  Evento? _selectedEvento;

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
    return monthNames[month];
  }

  String get _formattedDate => _getMonthName(_focusedDate.month);


  // callback para cambiar la vista del calendario.
  void _changeCalendarView(CalendarView view) {
    setState(() {
      _calendarView = view;
      _calendarController.view = view;
    });
  }


  // Método que se ejecuta cuando cambia la vista del calendario.
  void _onViewChanged(ViewChangedDetails details) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _focusedDate = details.visibleDates.first;
        });
      }
    });
  }

  // Método para agregar un recordatorio.
  void _onAddReminder() {
    setState(() {
      _addEventType = "reminder";
      _isFabMenuExpanded = false;
      _selectedEvento = null;
    });
    _panelController.open();
  }

  // Método para agregar una tarea.
  void _onAddTask() {
    setState(() {
      _addEventType = "task";
      _isFabMenuExpanded = false;
      _selectedEvento = null;
    });
    _panelController.open();
  }

  // Cuando se toca un evento en el calendario, se abre el panel para visualizarlo.
  void _onEventTap(CalendarTapDetails details) {
    if (details.appointments != null && details.appointments!.isNotEmpty) {
      setState(() {
        _selectedEvento = details.appointments!.first as Evento;
        _addEventType = null; // Se establece en modo visualización.
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

  // Se crea la ruta de búsqueda que inyecta el mismo EventoBloc en SearchPage.
  // Esto permite que la SearchPage acceda a la lista de eventos ya cargados.
  Route _createSearchRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          BlocProvider.value(
            value: BlocProvider.of<EventoBloc>(context),
            child: const SearchPage(),
          ),
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
      // Dependiendo de si hay un evento seleccionado o se está en modo agregar/editar,
      // se muestra el panel correspondiente (ViewEventPanel o AddEventPanel).
      panel: _selectedEvento != null && _addEventType == null
          ? ViewEventPanel(
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
                _addEventType = _selectedEvento!.descripcion
                    .toLowerCase()
                    .contains("recordatorio")
                    ? "reminder"
                    : "task";
              });
              _panelController.open();
            }
          });
        },
        onDelete: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Confirmar eliminación"),
              content: const Text("¿Estás seguro de eliminar este evento?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(), // Cancelar
                  child: const Text("Cancelar"),
                ),
                TextButton(
                  onPressed: () {
                    context.read<EventoBloc>().add(
                      DeleteEventoButtonPressed(idEvento: _selectedEvento!.idEvento),
                    );
                    Navigator.of(context).pop(); // Cierra el diálogo
                    _panelController.close(); // Cierra el panel
                    setState(() {
                      _selectedEvento = null;
                    });
                  },
                  child: const Text("Eliminar"),
                ),
              ],
            ),
          );
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
        existingMeeting: _selectedEvento,
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
                  onPressed: () async {
                    // Al presionar el botón de búsqueda, se navega a SearchPage.
                    // Se espera el resultado (un evento seleccionado) mediante await.
                    final selectedEvent = await Navigator.of(context)
                        .push(_createSearchRoute());
                    // Si se selecciona un evento, se procede a:
                    // 1. Asignar el evento a _selectedEvento.
                    // 2. Actualizar el calendario para que se mueva a la fecha del evento.
                    // 3. Abrir el panel de detalles.
                    if (selectedEvent != null && selectedEvent is Evento) {
                      setState(() {
                        _selectedEvento = selectedEvent;
                        _addEventType = null;
                        // Se actualizan las propiedades del controlador del calendario para moverlo
                        // a la fecha del evento seleccionado.
                        _calendarController.displayDate = selectedEvent.fechaHora;
                        _calendarController.selectedDate = selectedEvent.fechaHora;
                      });
                      _panelController.open();
                    }
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
                    dataSource: EventoCalendarDataSource(state.eventos),
                    onTap: _onEventTap,
                  );
                } else if (state is EventoFailure) {
                  return Center(child: Text("Error al cargar eventos: ${state.error}"));
                } else {
                  // Si el estado es inicial, se lanza el evento para cargar los eventos.
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
