// lib/src/domain/usecases/auth_usecases.dart

import '../repositories/auth_repository.dart';

/// Caso de uso para iniciar sesión.
/// Recibe un repositorio que implementa [AuthRepository] para delegar la lógica de autenticación.
class LoginUser {
  final AuthRepository repository;

  /// Constructor que inyecta el repositorio de autenticación.
  LoginUser(this.repository);

  /// Método que ejecuta el proceso de login.
  /// - [email]: Correo electrónico del usuario.
  /// - [password]: Contraseña del usuario.
  ///
  /// Llama al método [login] del repositorio para autenticar al usuario.
  Future<void> call(String email, String password) async {
    await repository.login(email, password);
  }
}

/// Caso de uso para registrar a un usuario.
/// Recibe un repositorio que implementa [AuthRepository] para delegar la lógica de registro.
class RegisterUser {
  final AuthRepository repository;

  /// Constructor que inyecta el repositorio de autenticación.
  RegisterUser(this.repository);

  /// Método que ejecuta el proceso de registro.
  /// - [email]: Correo electrónico del usuario.
  /// - [password]: Contraseña del usuario.
  /// - [confirmPassword]: Confirmación de la contraseña del usuario.
  ///
  /// Valida que las contraseñas coincidan y luego llama al método [register] del repositorio.
  /// Lanza una [Exception] si las contraseñas no coinciden.
  Future<void> call(String email, String password, String confirmPassword) async {
    if (password != confirmPassword) {
      throw Exception('Las contraseñas no coinciden');
    }
    await repository.register(email, password);
  }
}
