import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Archivo generado con la configuración de Firebase
import 'src/presentation/routes/app_router.dart';
import 'src/presentation/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Importaciones para eventos
import 'src/data/datasources/remote/evento_firestore_datasource.dart';
import 'src/data/repositories/evento_repository_impl.dart';
import 'src/domain/usecases/agregar_evento_usecase.dart';
import 'src/domain/usecases/get_eventos_usecase.dart';
import 'src/domain/usecases/update_evento_usecase.dart';
import 'src/domain/usecases/delete_evento_usecase.dart';
import 'src/presentation/blocs/add_event/evento_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

/// [MyApp] es el widget principal de la aplicación.
/// Se inyectan las dependencias necesarias, incluyendo el [EventoBloc]
/// para gestionar la adición, actualización, eliminación y carga de eventos.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Instancia del datasource remoto para eventos.
    final eventoFirestoreDatasource = EventoFirestoreDatasource();

    // Instancia del repositorio de eventos usando el datasource remoto.
    final eventoRepository = EventoRepositoryImpl(remoteDatasource: eventoFirestoreDatasource);

    // Creación del caso de uso para agregar eventos.
    final agregarEventoUseCase = AgregarEventoUseCase(eventoRepository);

    // Creación del caso de uso para cargar eventos.
    final getEventosUseCase = GetEventosUseCase(eventoRepository);

    // Creación del caso de uso para actualizar eventos.
    final updateEventoUseCase = UpdateEventoUseCase(eventoRepository);

    // Creación del caso de uso para eliminar eventos.
    final deleteEventoUseCase = DeleteEventoUseCase(eventoRepository);

    return MultiBlocProvider(
      providers: [
        // Inyección del EventoBloc con todos los casos de uso.
        BlocProvider<EventoBloc>(
          create: (_) => EventoBloc(
            agregarEventoUseCase: agregarEventoUseCase,
            getEventosUseCase: getEventosUseCase,
            updateEventoUseCase: updateEventoUseCase,
            deleteEventoUseCase: deleteEventoUseCase,
          ),
        ),
        // Aquí podrías agregar otros BlocProviders si fuera necesario.
      ],
      child: MaterialApp(
        title: 'Tempet',
        theme: AppTheme.temaClaro,
        debugShowCheckedModeBanner: false,
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: '/',
      ),
    );
  }
}
