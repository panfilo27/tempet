// lib/src/data/repositories/firebase_auth_repository_impl.dart

import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implementación de [AuthRepository] utilizando Firebase Authentication.
///
/// Esta clase se encarga de gestionar la autenticación a través de Firebase,
/// implementando los métodos de login y registro.
class FirebaseAuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth firebaseAuth;

  /// Constructor que permite inyectar una instancia de [FirebaseAuth].
  /// Si no se proporciona, se utiliza la instancia por defecto [FirebaseAuth.instance].
  FirebaseAuthRepositoryImpl({FirebaseAuth? firebaseAuth})
      : firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// Realiza el proceso de login utilizando Firebase Authentication.
  ///
  /// - [email]: Correo electrónico del usuario.
  /// - [password]: Contraseña del usuario.
  ///
  /// Llama a [FirebaseAuth.signInWithEmailAndPassword] y gestiona las excepciones
  /// propias de Firebase, lanzando [Exception] con mensajes descriptivos.
  @override
  Future<void> login(String email, String password) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('Usuario no encontrado');
      } else if (e.code == 'wrong-password') {
        throw Exception('Contraseña incorrecta');
      } else {
        throw Exception('Error: ${e.message}');
      }
    }
  }

  /// Realiza el proceso de registro utilizando Firebase Authentication.
  ///
  /// - [email]: Correo electrónico del usuario.
  /// - [password]: Contraseña del usuario.
  ///
  /// Llama a [FirebaseAuth.createUserWithEmailAndPassword] y gestiona las excepciones
  /// propias de Firebase, lanzando [Exception] con mensajes descriptivos.
  @override
  Future<void> register(String email, String password) async {
    try {
      await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('El correo ya está en uso');
      } else if (e.code == 'invalid-email') {
        throw Exception('Correo inválido');
      } else if (e.code == 'weak-password') {
        throw Exception('La contraseña es demasiado débil');
      } else {
        throw Exception('Error: ${e.message}');
      }
    }
  }

  // ───────────── logout ─────────────
  @override
  Future<void> logout() async => firebaseAuth.signOut();

  // ───────────── usuario actual ─────────────
  @override
  User? get currentUser => firebaseAuth.currentUser;
}
