import 'package:equatable/equatable.dart';
import '../../../domain/entities/evento.dart';

/// Clase base para los estados del [EventoBloc].
abstract class EventoState extends Equatable {
  const EventoState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial.
class EventoInitial extends EventoState {
  const EventoInitial();
}

/// Estado de carga (se muestra mientras se procesa una operación).
class EventoLoading extends EventoState {
  const EventoLoading();
}

/// Estado que indica que la operación de agregar fue exitosa.
class EventoSuccess extends EventoState {
  const EventoSuccess();
}

/// Estado que indica que ocurrió un error.
class EventoFailure extends EventoState {
  final String error;

  const EventoFailure(this.error);

  @override
  List<Object?> get props => [error];
}

/// Estado que contiene la lista de eventos cargados.
class EventoLoaded extends EventoState {
  final List<Evento> eventos;

  const EventoLoaded(this.eventos);

  @override
  List<Object?> get props => [eventos];
}
