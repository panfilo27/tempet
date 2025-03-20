import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tempet/src/domain/entities/evento.dart';

import '../../domain/entities/recordatorio.dart';
import '../../domain/entities/tarea.dart';
import '../blocs/add_event/evento_bloc.dart';
import '../blocs/add_event/evento_event.dart';

/// Panel para agregar o editar un evento (ya sea recordatorio o tarea).
class AddEventPanel extends StatefulWidget {
  final String eventType; // "reminder" o "task"
  final VoidCallback onClose;
  final Evento? existingMeeting; // Se actualiza a Evento? en lugar de Meeting?

  /// Si [existingMeeting] es no nulo, se cargan los datos de este evento para edición.
  const AddEventPanel({
    Key? key,
    required this.eventType,
    required this.onClose,
    this.existingMeeting,
  }) : super(key: key);

  @override
  _AddEventPanelState createState() => _AddEventPanelState();
}

class _AddEventPanelState extends State<AddEventPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controladores de texto para título y descripción.
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  // Variables para "Tarea" (fecha/hora de inicio).
  late DateTime _taskDate;
  late TimeOfDay _taskTime;

  // Variables para "Recordatorio" (fecha/hora de inicio y fin).
  late DateTime _reminderStartDate;
  late TimeOfDay _reminderStartTime;
  late DateTime _reminderEndDate;
  late TimeOfDay _reminderEndTime;

  // Color predeterminado o el del evento existente.
  Color _selectedColor = Colors.blue;

  @override
  void initState() {
    super.initState();

    // Se define si se inicia en la pestaña de tarea o recordatorio.
    int initialIndex = widget.eventType == "task" ? 0 : 1;
    _tabController = TabController(length: 2, vsync: this, initialIndex: initialIndex);

    // Inicialización de variables.
    _taskDate = DateTime.now();
    _taskTime = TimeOfDay.now();
    _reminderStartDate = DateTime.now();
    _reminderStartTime = TimeOfDay.now();
    _reminderEndDate = DateTime.now().add(const Duration(hours: 1));
    _reminderEndTime = TimeOfDay.now();

    // Si se está editando un evento existente, se cargan sus valores.
    if (widget.existingMeeting != null) {
      final evento = widget.existingMeeting!;
      _selectedColor = Colors.blue; // Ajusta según la propiedad de color de Evento si la tienes.
      _titleController.text = evento.descripcion;

      if (widget.eventType == 'task') {
        _taskDate = DateTime(
          evento.fechaHora.year,
          evento.fechaHora.month,
          evento.fechaHora.day,
        );
        _taskTime = TimeOfDay(hour: evento.fechaHora.hour, minute: evento.fechaHora.minute);
      } else {
        _reminderStartDate = DateTime(
          evento.fechaHora.year,
          evento.fechaHora.month,
          evento.fechaHora.day,
        );
        _reminderStartTime = TimeOfDay(hour: evento.fechaHora.hour, minute: evento.fechaHora.minute);

        // Para el ejemplo, asumimos que la duración es fija; en un caso real, quizá guardes la hora final.
        _reminderEndDate = DateTime(
          evento.fechaHora.year,
          evento.fechaHora.month,
          evento.fechaHora.day,
        );
        _reminderEndTime = TimeOfDay(hour: evento.fechaHora.hour + 1, minute: evento.fechaHora.minute);
      }
      // Si tienes un campo de descripción adicional, puedes asignarlo a _descController.
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // Métodos para seleccionar fechas, horas y color.
  Future<void> _pickDate(DateTime currentDate, ValueChanged<DateTime> onPicked,
      {String? helpText, DateTime? firstDate, DateTime? lastDate}) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: firstDate ?? DateTime.now().subtract(const Duration(days: 365)),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365)),
      helpText: helpText,
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _pickTime(TimeOfDay currentTime, ValueChanged<TimeOfDay> onPicked) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _pickColor() async {
    Color? picked = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Seleccionar color"),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _colorOption(Colors.red),
              _colorOption(Colors.green),
              _colorOption(Colors.blue),
              _colorOption(Colors.orange),
              _colorOption(Colors.purple),
              _colorOption(Colors.teal),
            ],
          ),
        ),
      ),
    );
    if (picked != null) setState(() => _selectedColor = picked);
  }

  Widget _colorOption(Color color) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(color),
      child: CircleAvatar(
        backgroundColor: color,
        radius: 20,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, d MMMM y', 'es_ES').format(date);
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt);
  }

  Widget _buildDateTimeRow({
    required String label,
    required DateTime date,
    required TimeOfDay time,
    required VoidCallback onDatePressed,
    required VoidCallback onTimePressed,
  }) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onDatePressed,
            icon: const Icon(Icons.calendar_today),
            label: Text(_formatDate(date)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onTimePressed,
            icon: const Icon(Icons.access_time),
            label: Text(_formatTime(time)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: "Título de la tarea",
              border: OutlineInputBorder(),
            ),
          ),
          const Divider(height: 32),
          _buildDateTimeRow(
            label: "Inicio",
            date: _taskDate,
            time: _taskTime,
            onDatePressed: () => _pickDate(_taskDate, (picked) => setState(() => _taskDate = picked),
                helpText: "Selecciona la fecha de la tarea"),
            onTimePressed: () => _pickTime(_taskTime, (picked) => setState(() => _taskTime = picked)),
          ),
          const Divider(height: 32),
          Row(
            children: [
              const Text("Color: "),
              GestureDetector(
                onTap: _pickColor,
                child: CircleAvatar(
                  backgroundColor: _selectedColor,
                  radius: 20,
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: "Detalles de la tarea",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitEvent,
            child: const Text("Guardar Tarea"),
          ),
        ],
      ),
    );
  }

  Widget _buildEventForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: "Título del recordatorio",
              border: OutlineInputBorder(),
            ),
          ),
          const Divider(height: 32),
          _buildDateTimeRow(
            label: "Inicio",
            date: _reminderStartDate,
            time: _reminderStartTime,
            onDatePressed: () => _pickDate(
              _reminderStartDate,
                  (picked) => setState(() => _reminderStartDate = picked),
              helpText: "Fecha de inicio",
            ),
            onTimePressed: () => _pickTime(
              _reminderStartTime,
                  (picked) => setState(() => _reminderStartTime = picked),
            ),
          ),
          const SizedBox(height: 16),
          _buildDateTimeRow(
            label: "Fin",
            date: _reminderEndDate,
            time: _reminderEndTime,
            onDatePressed: () => _pickDate(
              _reminderEndDate,
                  (picked) => setState(() => _reminderEndDate = picked),
              helpText: "Fecha de fin",
              firstDate: _reminderStartDate,
            ),
            onTimePressed: () => _pickTime(
              _reminderEndTime,
                  (picked) => setState(() => _reminderEndTime = picked),
            ),
          ),
          const Divider(height: 32),
          Row(
            children: [
              const Text("Color: "),
              GestureDetector(
                onTap: _pickColor,
                child: CircleAvatar(
                  backgroundColor: _selectedColor,
                  radius: 20,
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: "Descripción del recordatorio",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitEvent,
            child: const Text("Guardar Recordatorio"),
          ),
        ],
      ),
    );
  }

  /// Función que crea el objeto [Evento] y lo envía al Bloc para agregarlo.
  void _submitEvent() {
    if (_titleController.text.trim().isEmpty) return;
    final newEvent = Evento(
      idEvento: DateTime.now().millisecondsSinceEpoch.toString(),
      descripcion: _titleController.text,
      fechaHora: widget.eventType == "task"
          ? DateTime(
        _taskDate.year,
        _taskDate.month,
        _taskDate.day,
        _taskTime.hour,
        _taskTime.minute,
      )
          : DateTime(
        _reminderStartDate.year,
        _reminderStartDate.month,
        _reminderStartDate.day,
        _reminderStartTime.hour,
        _reminderStartTime.minute,
      ),
      repetir: widget.eventType == "reminder" ? "diario" : "semanal",
      estado: "pendiente",
      notificaciones: [],
      tarea: Tarea(prioridad: widget.eventType == "task" ? "alta" : "normal"),
      recordatorio: Recordatorio(
        repetir: widget.eventType == "reminder" ? "diario" : "",
        ubicacion: widget.eventType == "reminder" ? "Oficina" : "",
      ),
    );

    // Despacha el evento al Bloc (se asume que el Bloc ya está inyectado en el árbol).
    context.read<EventoBloc>().add(AddEventoButtonPressed(event: newEvent));

    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Column(
        children: [
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
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: const [
              Tab(text: "Tarea"),
              Tab(text: "Recordatorio"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTaskForm(),
                _buildEventForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
