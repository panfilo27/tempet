// lib/src/presentation/blocs/login/login_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempet/src/domain/usecases/auth_usecases.dart';
import 'login_event.dart';
import 'login_state.dart';

/// [LoginBloc] se encarga de manejar los eventos de la pantalla de login.
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUser loginUser;
  final RegisterUser registerUser;

  LoginBloc({
    required this.loginUser,
    required this.registerUser,
  }) : super(const LoginInitial()) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
    on<RegisterButtonPressed>(_onRegisterButtonPressed);
  }

  /// Maneja el evento [LoginButtonPressed] y emite estados según el resultado.
  Future<void> _onLoginButtonPressed(
      LoginButtonPressed event, Emitter<LoginState> emit) async {
    emit(const LoginLoading());
    try {
      await loginUser(event.email, event.password);
      emit(const LoginSuccess());
    } catch (e) {
      final error = e.toString();
      String friendlyError = error;
      // Verifica si el error corresponde a credenciales inválidas.
      if (error.contains("Usuario no encontrado") ||
          error.contains("Contraseña incorrecta") ||
          error.contains("incorrect, malformed or has expired")) {
        friendlyError =
        "El usuario o la contraseña son incorrectos. Por favor, inténtalo de nuevo.";
      }
      // Si el error es por falta de conexión.
      else if (error.contains("A network error")) {
        friendlyError =
        "No se pudo conectar. Por favor, verifica tu conexión a internet.";
      }
      emit(LoginFailure(friendlyError));
    }
  }

  /// Maneja el evento [RegisterButtonPressed] y emite estados según el resultado.
  Future<void> _onRegisterButtonPressed(
      RegisterButtonPressed event, Emitter<LoginState> emit) async {
    emit(const LoginLoading());
    try {
      await registerUser(
        event.email,
        event.password,
        event.confirmPassword,
      );
      emit(const LoginSuccess());
    } catch (e) {
      final error = e.toString();
      String friendlyError = error;
      // Se puede aplicar la misma lógica para mensajes amigables.
      if (error.contains("A network error")) {
        friendlyError =
        "No se pudo conectar. Por favor, verifica tu conexión a internet.";
      }
      emit(LoginFailure(friendlyError));
    }
  }
}
