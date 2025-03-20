// lib/src/presentation/widgets/add_event_panel.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempet/src/domain/entities/evento.dart';
import 'package:tempet/src/domain/entities/recordatorio.dart';
import 'package:tempet/src/domain/entities/tarea.dart';
import 'package:tempet/src/presentation/blocs/add_event/evento_bloc.dart';
import 'package:tempet/src/presentation/blocs/add_event/evento_event.dart';

/// Widget que muestra un formulario para agregar un nuevo evento.
/// Se utiliza el [EventoBloc] para disparar la operación de agregar el evento a Firebase.
class AddEventPanel extends StatefulWidget {
  /// Tipo de evento a agregar: "reminder" o "task" (o cualquier otro).
  final String eventType;

  /// Función que se ejecuta al cerrar el panel.
  final VoidCallback onClose;

  /// Si se quiere editar un evento existente, se puede pasar la información; de lo contrario, es nulo.
  final dynamic existingMeeting;

  const AddEventPanel({
    Key? key,
    required this.eventType,
    required this.onClose,
    this.existingMeeting,
  }) : super(key: key);

  @override
  _AddEventPanelState createState() => _AddEventPanelState();
}

class _AddEventPanelState extends State<AddEventPanel> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  // Puedes agregar más controladores para fecha, hora, etc.

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  /// Función que valida el formulario, crea el objeto [Evento] y despacha el evento al Bloc.
  void _submitEvent() {
    if (_formKey.currentState!.validate()) {
      // Crea el objeto Evento con datos mínimos. Ajusta según tus necesidades.
      final newEvent = Evento(
        idEvento: DateTime.now().millisecondsSinceEpoch.toString(),
        descripcion: _descriptionController.text,
        fechaHora: DateTime.now(), // En un caso real, usar el valor ingresado.
        repetir: widget.eventType == "reminder" ? "diario" : "semanal",
        estado: "pendiente",
        notificaciones: [], // Podrías agregar lógica para notificaciones.
        // Si es tarea, se asigna prioridad; si es recordatorio, se asigna repetir/ubicación.
        tarea: Tarea(prioridad: widget.eventType == "task" ? "alta" : "normal"),
        recordatorio: Recordatorio(
          repetir: widget.eventType == "reminder" ? "diario" : "",
          ubicacion: widget.eventType == "reminder" ? "Oficina" : "",
        ),
      );

      // Despacha el evento al Bloc para agregar el nuevo evento.
      context.read<EventoBloc>().add(AddEventoButtonPressed(event: newEvent));

      // Cierra el panel después de enviar.
      widget.onClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // SingleChildScrollView evita overflow en pantallas pequeñas.
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.eventType == "reminder"
                  ? "Agregar Recordatorio"
                  : "Agregar Tarea",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Campo para la descripción del evento.
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: "Descripción del evento",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Por favor, ingrese una descripción";
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Botón para enviar el formulario.
            ElevatedButton(
              onPressed: _submitEvent,
              child: const Text("Agregar Evento"),
            ),
          ],
        ),
      ),
    );
  }
}
