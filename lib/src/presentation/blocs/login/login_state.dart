// lib/src/presentation/blocs/login/login_state.dart

import 'package:equatable/equatable.dart';

/// Clase base para los estados de autenticación en la pantalla de login.
/// Hereda de [Equatable] para facilitar la comparación de instancias.
abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial de la pantalla de login.
class LoginInitial extends LoginState {
  const LoginInitial();
}

/// Estado que indica que se está realizando una operación (login o registro)
/// y se muestra una interfaz de carga.
class LoginLoading extends LoginState {
  const LoginLoading();
}

/// Estado que indica que la operación (login o registro) fue exitosa.
class LoginSuccess extends LoginState {
  const LoginSuccess();
}

/// Estado que indica que hubo un error en la operación (login o registro).
/// Contiene el mensaje de error recibido.
class LoginFailure extends LoginState {
  final String error;

  const LoginFailure(this.error);

  @override
  List<Object?> get props => [error];
}
