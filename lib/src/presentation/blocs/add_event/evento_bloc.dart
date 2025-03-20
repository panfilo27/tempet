import 'package:flutter_bloc/flutter_bloc.dart';
import 'evento_event.dart';
import 'evento_state.dart';
import '../../../domain/usecases/agregar_evento_usecase.dart';
import '../../../domain/usecases/get_eventos_usecase.dart';

/// [EventoBloc] gestiona la adición y carga de eventos.
/// Utiliza el caso de uso [AgregarEventoUseCase] para agregar eventos
/// y [GetEventosUseCase] para cargarlos.
class EventoBloc extends Bloc<EventoEvent, EventoState> {
  final AgregarEventoUseCase agregarEventoUseCase;
  final GetEventosUseCase getEventosUseCase;

  EventoBloc({
    required this.agregarEventoUseCase,
    required this.getEventosUseCase,
  }) : super(const EventoInitial()) {
    on<AddEventoButtonPressed>(_onAddEventoButtonPressed);
    on<LoadEventos>(_onLoadEventos);
  }

  /// Maneja el evento de agregar un evento.
  Future<void> _onAddEventoButtonPressed(AddEventoButtonPressed event, Emitter<EventoState> emit) async {
    emit(const EventoLoading());
    try {
      await agregarEventoUseCase(event.event);
      emit(const EventoSuccess());
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
}
