// lib/src/presentation/widgets/edit_event_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tempet/src/domain/entities/evento.dart';
import '../../domain/entities/recordatorio.dart';
import '../../domain/entities/tarea.dart';
import '../blocs/add_event/evento_bloc.dart';
import '../blocs/add_event/evento_event.dart';

class EditEventPanel extends StatefulWidget {
  final Evento evento;
  final VoidCallback onClose;

  const EditEventPanel({
    Key? key,
    required this.evento,
    required this.onClose,
  }) : super(key: key);

  @override
  State<EditEventPanel> createState() => _EditEventPanelState();
}

class _EditEventPanelState extends State<EditEventPanel> {
  // ────────── tipo de evento ──────────
  late bool _isReminder;

  // ────────── texto ──────────
  late final _titleCtrl = TextEditingController();
  late final _descCtrl  = TextEditingController();

  // ────────── fechas / horas ──────────
  late DateTime _startDate, _endDate;
  late TimeOfDay _startTime, _endTime;

  // ────────── color / repetir ──────────
  late Color _color;
  final _repeatOpts = ['Una vez', 'Diario', 'Semanal', 'Mensual', 'Anual'];
  late String _repeat;

  // ════════════════════════════════════
  //                INIT
  // ════════════════════════════════════
  @override
  void initState() {
    super.initState();

    _isReminder = widget.evento.recordatorio.repetir.isNotEmpty;

    _titleCtrl.text = widget.evento.titulo;
    _descCtrl.text  = widget.evento.detalles;

    _startDate = widget.evento.fechaInicio;
    _startTime = TimeOfDay(
        hour: _startDate.hour, minute: _startDate.minute);

    _endDate   = widget.evento.fechaFin;
    _endTime   = TimeOfDay(
        hour: _endDate.hour, minute: _endDate.minute);

    _color  = Color(widget.evento.color);
    _repeat = _isReminder
        ? widget.evento.recordatorio.repetir
        : _repeatOpts.first;

    // de arranque ya garantizamos coherencia
    if (_isReminder) _ensureCoherence();
  }

  // ════════════════════════════════════
  //        CONSISTENCIA START / END
  // ════════════════════════════════════
  DateTime get _startDT => DateTime(
    _startDate.year,
    _startDate.month,
    _startDate.day,
    _startTime.hour,
    _startTime.minute,
  );

  DateTime get _endDT => DateTime(
    _endDate.year,
    _endDate.month,
    _endDate.day,
    _endTime.hour,
    _endTime.minute,
  );

  void _ensureCoherence({bool movedStart = false, bool movedEnd = false}) {
    if (!_isReminder) return;

    DateTime s = _startDT;
    DateTime e = _endDT;

    if (movedStart && e.isBefore(s)) {
      // mover fin +1h30
      e = s.add(const Duration(hours: 1, minutes: 30));
      _endDate = DateTime(e.year, e.month, e.day);
      _endTime = TimeOfDay(hour: e.hour, minute: e.minute);
    } else if (movedEnd && e.isBefore(s)) {
      // mover inicio -1h
      s = e.subtract(const Duration(hours: 1));
      _startDate = DateTime(s.year, s.month, s.day);
      _startTime = TimeOfDay(hour: s.hour, minute: s.minute);
    }
  }

  // ════════════════════════════════════
  //               PICKERS
  // ════════════════════════════════════
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

  // ════════════════════════════════════
  //            FORMATEO FECHA/HORA
  // ════════════════════════════════════
  String _fDate(DateTime d) =>
      DateFormat('EEEE, d MMMM y', 'es_ES').format(d);
  String _fTime(TimeOfDay t) {
    final n  = DateTime.now();
    final dt = DateTime(n.year, n.month, n.day, t.hour, t.minute);
    return DateFormat('HH:mm').format(dt);
  }

  // ════════════════════════════════════
  //               WIDGETS AUX
  // ════════════════════════════════════
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

  // ════════════════════════════════════
  //               FORMULARIOS
  // ════════════════════════════════════
  Widget _taskForm() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        TextField(
            controller: _titleCtrl,
            decoration:
            const InputDecoration(labelText: 'Título de la tarea')),
        const SizedBox(height: 16),
        _rowDateTime(
          date: _startDate,
          time: _startTime,
          onPickDate: () => _pickDate(_startDate, (p) {
            setState(() => _startDate = p);
          }, helpText: 'Fecha de la tarea'),
          onPickTime: () =>
              _pickTime(_startTime, (p) => setState(() => _startTime = p)),
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
          controller: _descCtrl,
          decoration:
          const InputDecoration(labelText: 'Detalles de la tarea'),
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
            onPressed: _submit, child: const Text('Guardar cambios')),
      ],
    ),
  );

  Widget _reminderForm() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        TextField(
            controller: _titleCtrl,
            decoration:
            const InputDecoration(labelText: 'Título del recordatorio')),
        const SizedBox(height: 16),
        _rowDateTime(
          date: _startDate,
          time: _startTime,
          onPickDate: () => _pickDate(_startDate, (p) {
            setState(() {
              _startDate = p;
              _ensureCoherence(movedStart: true);
            });
          }, helpText: 'Inicio'),
          onPickTime: () => _pickTime(_startTime, (p) {
            setState(() {
              _startTime = p;
              _ensureCoherence(movedStart: true);
            });
          }),
        ),
        const SizedBox(height: 16),
        _rowDateTime(
          date: _endDate,
          time: _endTime,
          onPickDate: () => _pickDate(_endDate, (p) {
            setState(() {
              _endDate = p;
              _ensureCoherence(movedEnd: true);
            });
          }, helpText: 'Fin', firstDate: _startDate),
          onPickTime: () => _pickTime(_endTime, (p) {
            setState(() {
              _endTime = p;
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
          controller: _descCtrl,
          decoration: const InputDecoration(labelText: 'Detalles'),
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
            onPressed: _submit, child: const Text('Guardar cambios')),
      ],
    ),
  );

  // ════════════════════════════════════
  //              SUBMIT
  // ════════════════════════════════════
  void _submit() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    final details = _descCtrl.text.trim();

    final inicio = _startDT;
    final fin    = _isReminder ? _endDT : inicio;

    final updated = widget.evento.copyWith(
      titulo       : title,
      detalles     : details,
      fechaInicio  : inicio,
      fechaFin     : fin,
      color        : _color.value,
      tarea        : Tarea(prioridad: _isReminder ? 'normal' : 'alta'),
      recordatorio : Recordatorio(
        repetir  : _isReminder ? _repeat : '',
        ubicacion: _isReminder ? widget.evento.recordatorio.ubicacion : '',
      ),
    );

    context.read<EventoBloc>().add(UpdateEventoButtonPressed(event: updated));
    widget.onClose();
  }

  // ════════════════════════════════════
  //                BUILD
  // ════════════════════════════════════
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // agarradera
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
        Padding(
          padding: const EdgeInsets.only(top: 12.0, bottom: 4),
          child: Text(
            _isReminder ? 'Editar Recordatorio' : 'Editar Tarea',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(child: _isReminder ? _reminderForm() : _taskForm()),
      ],
    ),
  );

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }
}
