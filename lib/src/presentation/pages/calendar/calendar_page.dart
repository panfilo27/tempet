// lib/src/presentation/pages/calendar_page.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tempet/src/presentation/pages/search_page.dart';
import 'package:tempet/src/presentation/widgets/view_event_panel.dart';
import 'package:tempet/src/presentation/widgets/user_drawer.dart';
import 'package:tempet/src/presentation/widgets/add_event_panel.dart';
import 'package:tempet/src/presentation/widgets/edit_event_panel.dart';

import 'package:tempet/src/presentation/blocs/add_event/evento_bloc.dart';
import 'package:tempet/src/presentation/blocs/add_event/evento_state.dart';
import 'package:tempet/src/presentation/blocs/add_event/evento_event.dart';

import 'package:tempet/src/domain/entities/evento.dart';
import 'evento_calendar_datasource.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // ─────────── Calendario ───────────
  CalendarView _calendarView = CalendarView.month;
  final CalendarController _calendarController = CalendarController();
  DateTime _focusedDate = DateTime(2025, 2, 25);

  // ─────────── Panel flotante ───────────
  final PanelController _panelController = PanelController();
  bool _isEditing = false;
  String? _addEventType; // 'task' | 'reminder'
  Evento? _selectedEvento;

  // ─────────── FAB expansión ───────────
  bool _isFabMenuExpanded = false;

  // ─────────── Carga inicial de eventos ───────────
  bool _requestedEventos = false;

  @override
  void initState() {
    super.initState();
    _calendarController.view = _calendarView;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cargar eventos la primera vez que el widget entra al árbol
    if (!_requestedEventos) {
      context.read<EventoBloc>().add(const LoadEventos());
      _requestedEventos = true;
    }
  }

  // ─────────── helpers de fecha ───────────
  String _getMonthName(int month) => const [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ][month - 1];
  String get _formattedDate => _getMonthName(_focusedDate.month);

  // ─────────── cambio de vista ───────────
  void _changeCalendarView(CalendarView v) {
    setState(() {
      _calendarView = v;
      _calendarController.view = v;
    });
  }

  void _onViewChanged(ViewChangedDetails d) =>
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _focusedDate = d.visibleDates.first);
      });

  // ─────────── handlers FAB ───────────
  void _onAddTask() {
    setState(() {
      _addEventType = 'task';
      _isEditing = false;
      _selectedEvento = null;
      _isFabMenuExpanded = false;
    });
    _panelController.open();
  }

  void _onAddReminder() {
    setState(() {
      _addEventType = 'reminder';
      _isEditing = false;
      _selectedEvento = null;
      _isFabMenuExpanded = false;
    });
    _panelController.open();
  }

  // ─────────── tap en cita ───────────
  void _onEventTap(CalendarTapDetails d) {
    if (d.appointments != null && d.appointments!.isNotEmpty) {
      setState(() {
        _selectedEvento = d.appointments!.first as Evento;
        _addEventType = null;
        _isEditing = false;
      });
      _panelController.open();
    }
  }

  // ─────────── expansión de recurrentes ───────────
  List<Evento> _expandEventos(List<Evento> eventos) {
    final List<Evento> out = [];
    for (final e in eventos) {
      out.add(e);
      final freq = e.recordatorio.repetir;
      if (freq.isEmpty) continue;
      DateTime s = e.fechaInicio, f = e.fechaFin;
      for (int i = 1; i < 360; i++) {
        switch (freq) {
          case 'Diario':
            s = s.add(const Duration(days: 1));
            f = f.add(const Duration(days: 1));
            break;
          case 'Semanal':
            s = s.add(const Duration(days: 7));
            f = f.add(const Duration(days: 7));
            break;
          case 'Mensual':
            s = DateTime(s.year, s.month + 1, s.day, s.hour, s.minute);
            f = DateTime(f.year, f.month + 1, f.day, f.hour, f.minute);
            break;
          case 'Anual':
            s = DateTime(s.year + 1, s.month, s.day, s.hour, s.minute);
            f = DateTime(f.year + 1, f.month, f.day, f.hour, f.minute);
            break;
          default:
            i = 360;
            continue;
        }
        out.add(e.copyWith(
          idEvento: '${e.idEvento}_$i',
          fechaInicio: s,
          fechaFin: f,
        ));
      }
    }
    return out;
  }

  // ─────────── búsqueda ───────────
  Route _createSearchRoute() => PageRouteBuilder(
    pageBuilder: (ctx, a1, a2) => BlocProvider.value(
      value: BlocProvider.of<EventoBloc>(ctx),
      child: const SearchPage(),
    ),
    transitionsBuilder: (ctx, anim, a2, child) => SlideTransition(
        position: anim.drive(
            Tween(begin: const Offset(1, 0), end: Offset.zero)),
        child: child),
  );

  // ─────────── construcción del panel ───────────
  Widget _buildPanel() {
    if (_isEditing && _selectedEvento != null) {
      return EditEventPanel(
        evento: _selectedEvento!,
        onClose: _closePanel,
      );
    }

    if (_selectedEvento != null && _addEventType == null) {
      return ViewEventPanel(
        evento: _selectedEvento!,
        onClose: _closePanel,
        onEdit: () {
          setState(() => _isEditing = true);
        },
        onDelete: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Confirmar eliminación'),
              content: const Text('¿Estás seguro de eliminar este evento?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cancelar')),
                TextButton(
                  child: const Text('Eliminar'),
                  onPressed: () {
                    context.read<EventoBloc>().add(
                        DeleteEventoButtonPressed(
                            idEvento: _selectedEvento!.idEvento));
                    Navigator.of(ctx).pop();
                    _closePanel();
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    if (_addEventType != null) {
      return AddEventPanel(
        eventType: _addEventType!,
        onClose: _closePanel,
      );
    }

    return Container();
  }

  void _closePanel() {
    _panelController.close();
    setState(() {
      _selectedEvento = null;
      _addEventType = null;
      _isEditing = false;
    });
  }

  // ─────────── appointmentBuilder ───────────
  Widget _appointmentBuilder(
      BuildContext context, CalendarAppointmentDetails details) {
    final evento = details.appointments.first as Evento;
    final isCompleted = evento.tarea.estado == 'completada';

    return Container(
      decoration: BoxDecoration(
        color: Color(evento.color),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      child: Text(
        evento.titulo,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white,
          decoration: isCompleted
              ? TextDecoration.lineThrough
              : TextDecoration.none,
          decorationColor: Colors.white,
          decorationThickness: 2,
        ),
      ),
    );
  }

  // ─────────── UI ───────────
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return SlidingUpPanel(
      controller: _panelController,
      maxHeight: h * 0.95,
      minHeight: 0,
      snapPoint: 0.20,
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      panel: _buildPanel(),
      onPanelClosed: _closePanel,
      body: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: Text(_formattedDate),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () async {
                    final sel = await Navigator.of(context)
                        .push(_createSearchRoute());
                    if (sel is Evento) {
                      setState(() {
                        _selectedEvento = sel;
                        _isEditing = false;
                        _addEventType = null;
                        _calendarController
                          ..displayDate = sel.fechaInicio
                          ..selectedDate = sel.fechaInicio;
                      });
                      _panelController.open();
                    }
                  },
                )
              ],
            ),
            drawer: UserDrawer(onViewChange: _changeCalendarView),
            body: BlocBuilder<EventoBloc, EventoState>(
              builder: (ctx, state) {
                if (state is EventoLoading || state is EventoInitial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is EventoFailure) {
                  return Center(
                      child: Text('Error al cargar eventos: ${state.error}'));
                }
                if (state is EventoLoaded) {
                  final data = _expandEventos(state.eventos);
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
                        appointmentDisplayMode:
                        MonthAppointmentDisplayMode.appointment),
                    dataSource: EventoCalendarDataSource(data),
                    onTap: _onEventTap,
                    appointmentBuilder: _appointmentBuilder,
                  );
                }
                // Fallback por si acaso
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          if (_isFabMenuExpanded)
            Positioned.fill(
              child: GestureDetector(
                onTap: () =>
                    setState(() => _isFabMenuExpanded = false),
                child: Container(color: Colors.black.withOpacity(0.65)),
              ),
            ),
          Positioned(
            bottom: 32,
            right: 16,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                if (_isFabMenuExpanded) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 140),
                    child: FloatingActionButton(
                      heroTag: 'fabReminder',
                      mini: true,
                      onPressed: _onAddReminder,
                      child: const Icon(Icons.alarm),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 70),
                    child: FloatingActionButton(
                      heroTag: 'fabTask',
                      mini: true,
                      onPressed: _onAddTask,
                      child: const Icon(Icons.task_alt),
                    ),
                  ),
                ],
                FloatingActionButton(
                  heroTag: 'fabMain',
                  onPressed: () => setState(
                          () => _isFabMenuExpanded = !_isFabMenuExpanded),
                  child:
                  Icon(_isFabMenuExpanded ? Icons.close : Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
