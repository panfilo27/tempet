import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// ─────────── Rutas / Tema ───────────
import 'src/presentation/routes/app_router.dart';
import 'src/presentation/theme/app_theme.dart';

// ─────────── Eventos ───────────
import 'src/data/datasources/remote/evento_firestore_datasource.dart';
import 'src/data/repositories/evento_repository_impl.dart';
import 'src/domain/usecases/agregar_evento_usecase.dart';
import 'src/domain/usecases/get_eventos_usecase.dart';
import 'src/domain/usecases/update_evento_usecase.dart';
import 'src/domain/usecases/delete_evento_usecase.dart';
import 'src/domain/usecases/cambiar_estado_tarea_usecase.dart';
import 'src/presentation/blocs/add_event/evento_bloc.dart';

// ─────────── Notificaciones ───────────
import 'package:tempet/services/notification_service.dart';
import 'src/data/repositories/notification_repository_impl.dart';
import 'src/domain/usecases/notification_usecases.dart';

// ─────────── Auth ───────────
import 'src/data/repositories/firebase_auth_repository_impl.dart';
import 'src/domain/usecases/auth_usecases.dart';
import 'src/presentation/blocs/login/login_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 1) Inicializamos el servicio de notificaciones locales
/*
  await NotificationService.init();
*/

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ───── Repos y casos de uso de Eventos ─────
    final eventoDatasource = EventoFirestoreDatasource();
    final eventoRepository = EventoRepositoryImpl(remoteDatasource: eventoDatasource);

    final agregarEventoUse = AgregarEventoUseCase(eventoRepository);
    final getEventosUse    = GetEventosUseCase(eventoRepository);
    final updateEventoUse  = UpdateEventoUseCase(eventoRepository);
    final deleteEventoUse  = DeleteEventoUseCase(eventoRepository);
    final cambiarEstadoUse = CambiarEstadoTareaUseCase(eventoRepository);

  /*  // ───── Repos y casos de uso de Notificaciones ─────
    final notifRepo        = NotificationRepositoryImpl();
    final programarNotiUse = ProgramarNotificacionEvento(notifRepo);
    final cancelarNotiUse  = CancelarNotificacionEvento(notifRepo);
*/
    // ───── Auth ─────
    final authRepository    = FirebaseAuthRepositoryImpl();
    final loginUserUse      = LoginUser(authRepository);
    final registerUserUse   = RegisterUser(authRepository);
    final logoutUserUse     = LogoutUser(authRepository);
    final getCurrentUserUse = GetCurrentUser(authRepository);

    return MultiRepositoryProvider(
      providers: [
        // Auth
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: loginUserUse),
        RepositoryProvider.value(value: registerUserUse),
        RepositoryProvider.value(value: logoutUserUse),
        RepositoryProvider.value(value: getCurrentUserUse),

       /* // Eventos / Notis
        RepositoryProvider.value(value: programarNotiUse),
        RepositoryProvider.value(value: cancelarNotiUse),*/
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<EventoBloc>(
            create: (_) => EventoBloc(
              agregarEventoUseCase      : agregarEventoUse,
              getEventosUseCase         : getEventosUse,
              updateEventoUseCase       : updateEventoUse,
              deleteEventoUseCase       : deleteEventoUse,
              cambiarEstadoTareaUseCase : cambiarEstadoUse,
             /* programarNotificacion     : programarNotiUse,   // ← NUEVO
              cancelarNotificacion      : cancelarNotiUse,  */  // ← NUEVO
            ),
          ),
          BlocProvider<LoginBloc>(
            create: (_) => LoginBloc(
              loginUser   : loginUserUse,
              registerUser: registerUserUse,
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Tempet',
          theme: AppTheme.temaClaro,
          debugShowCheckedModeBanner: false,
          onGenerateRoute: AppRouter.generateRoute,
          initialRoute: '/',
        ),
      ),
    );
  }
}
