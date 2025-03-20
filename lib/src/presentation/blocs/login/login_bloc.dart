// lib/src/presentation/blocs/login/login_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempet/src/domain/usecases/auth_usecases.dart';
import 'login_event.dart';
import 'login_state.dart';

/// [LoginBloc] se encarga de manejar los eventos de la pantalla de login.
/// Los eventos que procesa son [LoginButtonPressed] para iniciar sesión
/// y [RegisterButtonPressed] para el registro.
/// Administra los estados: [LoginInitial], [LoginLoading], [LoginSuccess] y [LoginFailure].
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUser loginUser;
  final RegisterUser registerUser;

  /// Constructor de [LoginBloc] que inyecta los casos de uso [loginUser] y [registerUser].
  LoginBloc({
    required this.loginUser,
    required this.registerUser,
  }) : super(const LoginInitial()) {
    // Registra el manejador para el evento de inicio de sesión.
    on<LoginButtonPressed>(_onLoginButtonPressed);
    // Registra el manejador para el evento de registro.
    on<RegisterButtonPressed>(_onRegisterButtonPressed);
  }

  /// Maneja el evento [LoginButtonPressed] que se dispara al presionar el botón de login.
  /// - [event]: Contiene los datos de correo y contraseña.
  /// - [emit]: Función para emitir nuevos estados.
  ///
  /// Emite [LoginLoading] durante el procesamiento y posteriormente
  /// [LoginSuccess] o [LoginFailure] según el resultado del caso de uso.
  Future<void> _onLoginButtonPressed(
      LoginButtonPressed event, Emitter<LoginState> emit) async {
    emit(const LoginLoading());
    try {
      // Llama al caso de uso para iniciar sesión con el correo y contraseña proporcionados.
      await loginUser(event.email, event.password);
      emit(const LoginSuccess());
    } catch (e) {
      // En caso de error, emite el estado de fallo con el mensaje de error.
      emit(LoginFailure(e.toString()));
    }
  }

  /// Maneja el evento [RegisterButtonPressed] que se dispara al presionar el botón de registro.
  /// - [event]: Contiene los datos de correo, contraseña y confirmación de contraseña.
  /// - [emit]: Función para emitir nuevos estados.
  ///
  /// Emite [LoginLoading] durante el procesamiento y posteriormente
  /// [LoginSuccess] o [LoginFailure] según el resultado del caso de uso.
  Future<void> _onRegisterButtonPressed(
      RegisterButtonPressed event, Emitter<LoginState> emit) async {
    emit(const LoginLoading());
    try {
      // Llama al caso de uso para registrar al usuario, validando que las contraseñas coincidan.
      await registerUser(
        event.email,
        event.password,
        event.confirmPassword,
      );
      emit(const LoginSuccess());
    } catch (e) {
      // En caso de error, emite el estado de fallo con el mensaje de error.
      emit(LoginFailure(e.toString()));
    }
  }
}
