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
