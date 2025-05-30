import 'package:equatable/equatable.dart';
import '../../../domain/entities/evento.dart';

/// Clase base para los eventos del [EventoBloc].
abstract class EventoEvent extends Equatable {
  const EventoEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para agregar un nuevo evento.
class AddEventoButtonPressed extends EventoEvent {
  final Evento event;

  const AddEventoButtonPressed({required this.event});

  @override
  List<Object?> get props => [event];
}

/// Evento para cargar los eventos existentes.
class LoadEventos extends EventoEvent {
  const LoadEventos();
}

/// Evento para actualizar un evento existente.
class UpdateEventoButtonPressed extends EventoEvent {
  final Evento event;

  const UpdateEventoButtonPressed({required this.event});

  @override
  List<Object?> get props => [event];
}

/// Evento para eliminar un evento.
class DeleteEventoButtonPressed extends EventoEvent {
  final String idEvento;

  const DeleteEventoButtonPressed({required this.idEvento});

  @override
  List<Object?> get props => [idEvento];
}

/// Evento para cambiar el estado de una tarea.
class CambiarEstadoTarea extends EventoEvent {
  final String idEvento;
  final String nuevoEstado;

  const CambiarEstadoTarea({required this.idEvento, required this.nuevoEstado});

  @override
  List<Object?> get props => [idEvento, nuevoEstado];
}
