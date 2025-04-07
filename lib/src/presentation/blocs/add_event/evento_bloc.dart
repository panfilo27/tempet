import 'package:flutter_bloc/flutter_bloc.dart';
import 'evento_event.dart';
import 'evento_state.dart';
import '../../../domain/usecases/agregar_evento_usecase.dart';
import '../../../domain/usecases/get_eventos_usecase.dart';
import '../../../domain/usecases/update_evento_usecase.dart';
import '../../../domain/usecases/delete_evento_usecase.dart';

/// [EventoBloc] gestiona la adición, actualización, eliminación y carga de eventos.
class EventoBloc extends Bloc<EventoEvent, EventoState> {
  final AgregarEventoUseCase agregarEventoUseCase;
  final GetEventosUseCase getEventosUseCase;
  final UpdateEventoUseCase updateEventoUseCase;
  final DeleteEventoUseCase deleteEventoUseCase;

  EventoBloc({
    required this.agregarEventoUseCase,
    required this.getEventosUseCase,
    required this.updateEventoUseCase,
    required this.deleteEventoUseCase,
  }) : super(const EventoInitial()) {
    on<AddEventoButtonPressed>(_onAddEventoButtonPressed);
    on<LoadEventos>(_onLoadEventos);
    on<UpdateEventoButtonPressed>(_onUpdateEventoButtonPressed);
    on<DeleteEventoButtonPressed>(_onDeleteEventoButtonPressed);
  }

  /// Maneja el evento de agregar un nuevo evento.
  Future<void> _onAddEventoButtonPressed(AddEventoButtonPressed event, Emitter<EventoState> emit) async {
    emit(const EventoLoading());
    try {
      await agregarEventoUseCase(event.event);
      final eventos = await getEventosUseCase();
      emit(EventoLoaded(eventos));
    } catch (e) {
      emit(EventoFailure(e.toString()));
    }
  }

  /// Maneja el evento de cargar la lista de eventos.
  Future<void> _onLoadEventos(LoadEventos event, Emitter<EventoState> emit) async {
    emit(const EventoLoading());
    try {
      final eventos = await getEventosUseCase();
      emit(EventoLoaded(eventos));
    } catch (e) {
      emit(EventoFailure(e.toString()));
    }
  }

  /// Maneja el evento de actualizar un evento existente.
  Future<void> _onUpdateEventoButtonPressed(UpdateEventoButtonPressed event, Emitter<EventoState> emit) async {
    emit(const EventoLoading());
    try {
      await updateEventoUseCase(event.event);
      final eventos = await getEventosUseCase();
      emit(EventoLoaded(eventos));
    } catch (e) {
      emit(EventoFailure(e.toString()));
    }
  }

  /// Maneja el evento de eliminar un evento.
  Future<void> _onDeleteEventoButtonPressed(DeleteEventoButtonPressed event, Emitter<EventoState> emit) async {
    emit(const EventoLoading());
    try {
      await deleteEventoUseCase(event.idEvento);
      final eventos = await getEventosUseCase();
      emit(EventoLoaded(eventos));
    } catch (e) {
      emit(EventoFailure(e.toString()));
    }
  }
}
