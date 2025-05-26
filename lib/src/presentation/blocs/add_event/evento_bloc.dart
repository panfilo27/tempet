// lib/src/presentation/blocs/add_event/evento_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'evento_event.dart';
import 'evento_state.dart';
import '../../../domain/usecases/agregar_evento_usecase.dart';
import '../../../domain/usecases/get_eventos_usecase.dart';
import '../../../domain/usecases/update_evento_usecase.dart';
import '../../../domain/usecases/delete_evento_usecase.dart';
import '../../../domain/usecases/cambiar_estado_tarea_usecase.dart';
import '../../../domain/usecases/notification_usecases.dart';   // ← NUEVO

/// [EventoBloc] gestiona la adición, actualización, eliminación y carga de eventos.
class EventoBloc extends Bloc<EventoEvent, EventoState> {
  final AgregarEventoUseCase        agregarEventoUseCase;
  final GetEventosUseCase           getEventosUseCase;
  final UpdateEventoUseCase         updateEventoUseCase;
  final DeleteEventoUseCase         deleteEventoUseCase;
  final CambiarEstadoTareaUseCase   cambiarEstadoTareaUseCase;

 /* // ── Casos de uso para notificaciones ──
  final ProgramarNotificacionEvento programarNotificacion;
  final CancelarNotificacionEvento  cancelarNotificacion;*/

  EventoBloc({
    required this.agregarEventoUseCase,
    required this.getEventosUseCase,
    required this.updateEventoUseCase,
    required this.deleteEventoUseCase,
    required this.cambiarEstadoTareaUseCase,
    /*required this.programarNotificacion,   // ← NUEVO
    required this.cancelarNotificacion,  */  // ← NUEVO
  }) : super(const EventoInitial()) {
    on<AddEventoButtonPressed>(_onAddEventoButtonPressed);
    on<LoadEventos>(_onLoadEventos);
    on<UpdateEventoButtonPressed>(_onUpdateEventoButtonPressed);
    on<DeleteEventoButtonPressed>(_onDeleteEventoButtonPressed);
    on<CambiarEstadoTarea>(_onCambiarEstadoTarea);
  }

  /// Maneja el evento de agregar un nuevo evento.
  Future<void> _onAddEventoButtonPressed(
      AddEventoButtonPressed event, Emitter<EventoState> emit) async {
    emit(const EventoLoading());
    try {
      await agregarEventoUseCase(event.event);

     /* // Programar notificación 30 min antes
      await programarNotificacion(
        event.event.idEvento,
        event.event.titulo,
        event.event.fechaInicio,
      );*/

      final eventos = await getEventosUseCase();
      emit(EventoLoaded(eventos));
    } catch (e) {
      emit(EventoFailure(e.toString()));
    }
  }

  /// Maneja el evento de cargar la lista de eventos.
  Future<void> _onLoadEventos(
      LoadEventos event, Emitter<EventoState> emit) async {
    emit(const EventoLoading());
    try {
      final eventos = await getEventosUseCase();
      emit(EventoLoaded(eventos));
    } catch (e) {
      emit(EventoFailure(e.toString()));
    }
  }

  /// Maneja el evento de actualizar un evento existente.
  Future<void> _onUpdateEventoButtonPressed(
      UpdateEventoButtonPressed event, Emitter<EventoState> emit) async {
    emit(const EventoLoading());
    try {
      await updateEventoUseCase(event.event);

     /* // Reprogramar notificación
      await cancelarNotificacion(event.event.idEvento);
      await programarNotificacion(
        event.event.idEvento,
        event.event.titulo,
        event.event.fechaInicio,
      );*/

      final eventos = await getEventosUseCase();
      emit(EventoLoaded(eventos));
    } catch (e) {
      emit(EventoFailure(e.toString()));
    }
  }

  /// Maneja el evento de eliminar un evento.
  Future<void> _onDeleteEventoButtonPressed(
      DeleteEventoButtonPressed event, Emitter<EventoState> emit) async {
    emit(const EventoLoading());
    try {
      await deleteEventoUseCase(event.idEvento);

      /*// Cancelar notificación asociada
      await cancelarNotificacion(event.idEvento);*/

      final eventos = await getEventosUseCase();
      emit(EventoLoaded(eventos));
    } catch (e) {
      emit(EventoFailure(e.toString()));
    }
  }

  /// Maneja el evento de cambiar el Estado de una tarea.
  Future<void> _onCambiarEstadoTarea(
      CambiarEstadoTarea event, Emitter<EventoState> emit) async {
    emit(const EventoLoading());
    try {
      await cambiarEstadoTareaUseCase(event.idEvento, event.nuevoEstado);
      final eventos = await getEventosUseCase();
      emit(EventoLoaded(eventos));
    } catch (e) {
      emit(EventoFailure(e.toString()));
    }
  }
}
