// lib/src/domain/repositories/auth_repository.dart
///[AuthRepository] es una clase abstracta que define los métodos que
/// se deben implementar en los repositorios de autenticación.
abstract class AuthRepository {
  Future<void> login(String email, String password);
  Future<void> register(String email, String password);
}
