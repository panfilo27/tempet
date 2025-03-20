// lib/src/presentation/blocs/login/login_event.dart

import 'package:equatable/equatable.dart';

/// Clase base para todos los eventos de autenticación.
/// Utiliza [Equatable] para facilitar la comparación de instancias.
abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

/// Evento que se dispara al presionar el botón de iniciar sesión.
/// Contiene el correo y la contraseña ingresados por el usuario.
class LoginButtonPressed extends LoginEvent {
  final String email;
  final String password;

  /// Constructor para [LoginButtonPressed].
  const LoginButtonPressed({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Evento que se dispara al presionar el botón de registro.
/// Contiene el correo, la contraseña y la confirmación de la contraseña ingresados por el usuario.
class RegisterButtonPressed extends LoginEvent {
  final String email;
  final String password;
  final String confirmPassword;

  /// Constructor para [RegisterButtonPressed].
  const RegisterButtonPressed({
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [email, password, confirmPassword];
}
