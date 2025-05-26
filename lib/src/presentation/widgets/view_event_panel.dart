// lib/src/presentation/widgets/view_event_panel.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tempet/src/domain/entities/evento.dart';
import 'package:tempet/src/presentation/blocs/add_event/evento_bloc.dart';
import 'package:tempet/src/presentation/blocs/add_event/evento_event.dart';

/// Panel que muestra la información de un evento (tarea o recordatorio)
/// y permite editarlo o borrarlo.
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

  String _formatDate(DateTime d) =>
      DateFormat('EEEE, d MMMM y', 'es_ES').format(d);
  String _formatTime(DateTime d) => DateFormat('HH:mm').format(d);

  @override
  Widget build(BuildContext context) {
    final bool isReminder = evento.recordatorio.repetir.isNotEmpty;
    final DateTime start  = evento.fechaInicio;
    final DateTime end    = evento.fechaFin;
    final Color color     = Color(evento.color);

    return Material(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barra superior
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
                  onSelected: (v) =>
                  v == 'edit' ? onEdit() : onDelete(),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit',   child: Text('Editar')),
                    PopupMenuItem(value: 'delete', child: Text('Borrar')),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),

          // Título
          ListTile(
            title   : const Text('Título', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(evento.titulo),
          ),
          const Divider(),

          // Detalles
          ListTile(
            title   : const Text('Detalles', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(evento.detalles.isNotEmpty ? evento.detalles : 'Sin detalles'),
          ),
          const Divider(),

          // Inicio
          ListTile(
            title   : const Text('Inicio', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${_formatDate(start)} - ${_formatTime(start)}'),
          ),

          // Fin (solo recordatorio)
          if (isReminder) ...[
            const Divider(),
            ListTile(
              title   : const Text('Fin', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${_formatDate(end)} - ${_formatTime(end)}'),
            ),
          ],
          const Divider(),

          // Color
          ListTile(
            title   : const Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: CircleAvatar(backgroundColor: color, radius: 16),
          ),
          const Divider(),

          // Repetir o Estado
          if (isReminder) ...[
            ListTile(
              title   : const Text('Repetir', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(evento.recordatorio.repetir),
            ),
          ] else ...[
            ListTile(
              title: const Text('Estado', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: evento.tarea.estado == 'pendiente'
                  ? ElevatedButton(
                onPressed: () {
                  context.read<EventoBloc>().add(
                    CambiarEstadoTarea(
                      idEvento: evento.idEvento,
                      nuevoEstado: 'completada',
                    ),
                  );
                  onClose();
                },
                child: const Text('Marcar como completada'),
              )
                  : Text(evento.tarea.estado),
            ),
          ],
        ],
      ),
    );
  }
}
