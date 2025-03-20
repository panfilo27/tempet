// lib/src/presentation/widgets/view_event_panel.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tempet/src/domain/entities/evento.dart';

/// Panel que muestra la información de un evento y permite editar o borrarlo.
class ViewEventPanel extends StatelessWidget {
  final Evento evento;
  final VoidCallback onClose;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ViewEventPanel({
    Key? key,
    required this.evento,
    required this.onClose,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  /// Formatea una fecha según el formato 'EEEE, d MMMM y' en español.
  String _formatDate(DateTime date) {
    return DateFormat('EEEE, d MMMM y', 'es_ES').format(date);
  }

  /// Formatea una hora según el formato 'HH:mm'.
  String _formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    // Se determina si el evento es un recordatorio en función de su descripción.
    // Ajusta esta lógica según las propiedades de tu entidad Evento.
    bool isReminder = evento.descripcion.toLowerCase().contains("recordatorio");

    // Se utiliza la propiedad fechaHora como inicio.
    DateTime start = evento.fechaHora;
    // Para el fin, en este ejemplo asumimos una duración fija de 1 hora si es recordatorio.
    DateTime end = isReminder ? evento.fechaHora.add(const Duration(hours: 1)) : evento.fechaHora;
    // Para el color, usamos un color fijo; si tu entidad tiene una propiedad para ello, utilízala.
    Color color = Colors.blue;

    return Material(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle superior con menú de opciones.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 40,
            color: Colors.grey[300],
            child: Row(
              children: [
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Editar'),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Borrar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          // Información del título.
          ListTile(
            title: const Text('Título', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(evento.descripcion),
          ),
          const Divider(),
          // Información de la fecha y hora de inicio.
          ListTile(
            title: const Text('Inicio', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${_formatDate(start)} - ${_formatTime(start)}'),
          ),
          // Si es recordatorio, mostramos también la fecha y hora de fin.
          if (isReminder) ...[
            const Divider(),
            ListTile(
              title: const Text('Fin', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${_formatDate(end)} - ${_formatTime(end)}'),
            ),
          ],
          const Divider(),
          // Información del color.
          ListTile(
            title: const Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: CircleAvatar(
              backgroundColor: color,
              radius: 16,
            ),
          ),
          const Divider(),
          // Información de la descripción (aquí se muestra "Sin descripción" por defecto).
          ListTile(
            title: const Text('Descripción', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Sin descripción'),
          ),
        ],
      ),
    );
  }
}
