// lib/src/presentation/widgets/add_event_panel.dart
import 'package:firebase_auth/firebase_auth.dart';          // ← NUEVO
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:tempet/src/domain/entities/evento.dart';
import '../../domain/entities/recordatorio.dart';
import '../../domain/entities/tarea.dart';

import '../blocs/add_event/evento_bloc.dart';
import '../blocs/add_event/evento_event.dart';

/// Panel para **crear** un nuevo evento (Tarea o Recordatorio).
class AddEventPanel extends StatefulWidget {
  /// "task" o "reminder"
  final String eventType;
  final VoidCallback onClose;

  const AddEventPanel({
    Key? key,
    required this.eventType,
    required this.onClose,
  }) : super(key: key);

  @override
  State<AddEventPanel> createState() => _AddEventPanelState();
}

class _AddEventPanelState extends State<AddEventPanel>
    with SingleTickerProviderStateMixin {
  // ────────── control de pestañas ──────────
  late final TabController _tab = TabController(
      length: 2, vsync: this, initialIndex: widget.eventType == 'task' ? 0 : 1);

  // ────────── texto ──────────
  final _title = TextEditingController();
  final _desc  = TextEditingController();

  // ────────── datos Tarea ──────────
  late DateTime _taskDate  = DateTime.now();
  late TimeOfDay _taskTime = TimeOfDay.now();

  // ────────── datos Recordatorio ──────────
  late DateTime _remStartDate  = DateTime.now();
  late TimeOfDay _remStartTime = TimeOfDay.now();
  late DateTime _remEndDate    =
  _remStartDate.add(const Duration(hours: 1, minutes: 30));
  late TimeOfDay _remEndTime =
  TimeOfDay.fromDateTime(_remEndDate); // ≈ + 1 h 30 min

  // ────────── otros campos ──────────
  Color _color = Colors.blue;
  final _repeatOpts = ['Una vez', 'Diario', 'Semanal', 'Mensual', 'Anual'];
  String _repeat   = 'Una vez';

  // ════════════════════════════════════════════════════════════════
  //                       PICKERS Y HELPERS
  // ════════════════════════════════════════════════════════════════
  Future<void> _pickDate(
      DateTime current,
      ValueChanged<DateTime> cb, {
        String? helpText,
        DateTime? firstDate,
      }) async {
    final p = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: firstDate ?? DateTime.now().subtract(const Duration(days: 365)),
      lastDate : DateTime.now().add(const Duration(days: 365)),
      helpText : helpText,
    );
    if (p != null) cb(p);
  }

  Future<void> _pickTime(
      TimeOfDay current,
      ValueChanged<TimeOfDay> cb,
      ) async {
    final p = await showTimePicker(context: context, initialTime: current);
    if (p != null) cb(p);
  }

  Future<void> _pickColor() async {
    final p = await showDialog<Color>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Seleccionar color'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _cOpt(Colors.red),
            _cOpt(Colors.green),
            _cOpt(Colors.blue),
            _cOpt(Colors.orange),
            _cOpt(Colors.purple),
            _cOpt(Colors.teal),
          ],
        ),
      ),
    );
    if (p != null) setState(() => _color = p);
  }

  Widget _cOpt(Color c) =>
      GestureDetector(onTap: () => Navigator.of(context).pop(c),
          child: CircleAvatar(backgroundColor: c, radius: 20));

  String _fDate(DateTime d) =>
      DateFormat('EEEE, d MMMM y', 'es_ES').format(d);
  String _fTime(TimeOfDay t) {
    final n  = DateTime.now();
    final dt = DateTime(n.year, n.month, n.day, t.hour, t.minute);
    return DateFormat('HH:mm').format(dt);
  }

  // ════════════════════════════════════════════════════════════════
  //                  CONSISTENCIA START / END
  // ════════════════════════════════════════════════════════════════
  DateTime get _startDT => DateTime(
    _remStartDate.year,
    _remStartDate.month,
    _remStartDate.day,
    _remStartTime.hour,
    _remStartTime.minute,
  );

  DateTime get _endDT => DateTime(
    _remEndDate.year,
    _remEndDate.month,
    _remEndDate.day,
    _remEndTime.hour,
    _remEndTime.minute,
  );

  /// Asegura que el fin sea ≥ inicio.
  /// Si no, ajusta automáticamente para mantener coherencia.
  void _ensureCoherence({bool movedStart = false, bool movedEnd = false}) {
    DateTime s = _startDT;
    DateTime e = _endDT;

    if (movedStart && e.isBefore(s)) {
      // fin queda detrás → fin = inicio + 1h30
      e = s.add(const Duration(hours: 1, minutes: 30));
      _remEndDate = DateTime(e.year, e.month, e.day);
      _remEndTime = TimeOfDay(hour: e.hour, minute: e.minute);
    } else if (movedEnd && e.isBefore(s)) {
      // fin < inicio → inicio = fin - 1h
      s = e.subtract(const Duration(hours: 1));
      _remStartDate = DateTime(s.year, s.month, s.day);
      _remStartTime = TimeOfDay(hour: s.hour, minute: s.minute);
    }
  }

  // ════════════════════════════════════════════════════════════════
  //                          UI AUX
  // ════════════════════════════════════════════════════════════════
  Widget _rowDateTime({
    required DateTime date,
    required TimeOfDay time,
    required VoidCallback onPickDate,
    required VoidCallback onPickTime,
  }) => Row(children: [
    Expanded(
        child: OutlinedButton.icon(
          icon: const Icon(Icons.calendar_today),
          label: Text(_fDate(date)),
          onPressed: onPickDate,
        )),
    const SizedBox(width: 8),
    Expanded(
        child: OutlinedButton.icon(
          icon: const Icon(Icons.access_time),
          label: Text(_fTime(time)),
          onPressed: onPickTime,
        )),
  ]);

  // ════════════════════════════════════════════════════════════════
  //                     FORMULARIOS
  // ════════════════════════════════════════════════════════════════
  Widget _taskForm() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        TextField(
            controller: _title,
            decoration:
            const InputDecoration(labelText: 'Título de la tarea')),
        const SizedBox(height: 16),
        _rowDateTime(
          date: _taskDate,
          time: _taskTime,
          onPickDate: () => _pickDate(
            _taskDate,
                (p) => setState(() => _taskDate = p),
            helpText: 'Fecha de la tarea',
          ),
          onPickTime: () =>
              _pickTime(_taskTime, (p) => setState(() => _taskTime = p)),
        ),
        const SizedBox(height: 16),
        Row(children: [
          const Text('Color: '),
          GestureDetector(
              onTap: _pickColor,
              child: CircleAvatar(backgroundColor: _color, radius: 20)),
        ]),
        const SizedBox(height: 16),
        TextField(
            controller: _desc,
            decoration:
            const InputDecoration(labelText: 'Detalles de la tarea'),
            maxLines: 3),
        const SizedBox(height: 24),
        ElevatedButton(
            onPressed: _submit, child: const Text('Guardar Tarea')),
      ],
    ),
  );

  Widget _reminderForm() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        TextField(
            controller: _title,
            decoration:
            const InputDecoration(labelText: 'Título del recordatorio')),
        const SizedBox(height: 16),
        _rowDateTime(
          date: _remStartDate,
          time: _remStartTime,
          onPickDate: () => _pickDate(_remStartDate, (p) {
            setState(() {
              _remStartDate = p;
              _ensureCoherence(movedStart: true);
            });
          }, helpText: 'Fecha de inicio'),
          onPickTime: () => _pickTime(_remStartTime, (p) {
            setState(() {
              _remStartTime = p;
              _ensureCoherence(movedStart: true);
            });
          }),
        ),
        const SizedBox(height: 16),
        _rowDateTime(
          date: _remEndDate,
          time: _remEndTime,
          onPickDate: () => _pickDate(_remEndDate, (p) {
            setState(() {
              _remEndDate = p;
              _ensureCoherence(movedEnd: true);
            });
          }, helpText: 'Fecha de fin', firstDate: _remStartDate),
          onPickTime: () => _pickTime(_remEndTime, (p) {
            setState(() {
              _remEndTime = p;
              _ensureCoherence(movedEnd: true);
            });
          }),
        ),
        const SizedBox(height: 16),
        Row(children: [
          const Text('Color: '),
          GestureDetector(
              onTap: _pickColor,
              child: CircleAvatar(backgroundColor: _color, radius: 20)),
        ]),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Repetir'),
          value: _repeat,
          items: _repeatOpts
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: (v) => setState(() => _repeat = v!),
        ),
        const SizedBox(height: 16),
        TextField(
            controller: _desc,
            decoration:
            const InputDecoration(labelText: 'Detalles del recordatorio'),
            maxLines: 3),
        const SizedBox(height: 24),
        ElevatedButton(
            onPressed: _submit, child: const Text('Guardar Recordatorio')),
      ],
    ),
  );

  // ════════════════════════════════════════════════════════════════
  //                          SUBMIT
  // ════════════════════════════════════════════════════════════════
  void _submit() {
    final title = _title.text.trim();
    if (title.isEmpty) return;

    final details = _desc.text.trim();

    final inicio = widget.eventType == 'task'
        ? DateTime(
        _taskDate.year, _taskDate.month, _taskDate.day,
        _taskTime.hour, _taskTime.minute)
        : _startDT;

    final fin = widget.eventType == 'task' ? inicio : _endDT;

    // Obtiene el uid del usuario autenticado
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    final ev = Evento(
      idEvento: DateTime.now().millisecondsSinceEpoch.toString(),
      userId  : uid,                                 // ← NUEVO
      titulo  : title,
      detalles: details,
      fechaInicio: inicio,
      fechaFin   : fin,
      color: _color.value,
      notificaciones: [],
      tarea: Tarea(
        prioridad: widget.eventType == 'task' ? 'alta' : 'normal',
      ),
      recordatorio: Recordatorio(
        repetir  : widget.eventType == 'reminder' ? _repeat : '',
        ubicacion: widget.eventType == 'reminder' ? 'Oficina' : '',
      ),
    );

    context.read<EventoBloc>().add(AddEventoButtonPressed(event: ev));
    widget.onClose();
  }

  // ════════════════════════════════════════════════════════════════
  //                            BUILD
  // ════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    child: Column(children: [
      // “agarre” para cerrar
      GestureDetector(
        onTap: widget.onClose,
        child: Container(
          height: 40,
          width: double.infinity,
          color: Colors.grey[300],
          alignment: Alignment.center,
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2)),
          ),
        ),
      ),
      TabBar(
        controller: _tab,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Theme.of(context).primaryColor,
        tabs: const [Tab(text: 'Tarea'), Tab(text: 'Recordatorio')],
      ),
      Expanded(
          child: TabBarView(
            controller: _tab,
            children: [_taskForm(), _reminderForm()],
          )),
    ]),
  );

  @override
  void dispose() {
    _tab.dispose();
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }
}
