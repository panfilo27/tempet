/// lib/src/presentation/pages/user/user_data_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tempet/src/domain/usecases/auth_usecases.dart';

class UserDataPage extends StatelessWidget {
  const UserDataPage({Key? key}) : super(key: key);

  // Utiliza el caso de uso LogoutUser
  Future<void> _cerrarSesion(BuildContext context) async {
    await context.read<LogoutUser>()();      // sign-out
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<GetCurrentUser>()();     // User?
    final email = user?.email ?? 'usuario@example.com';
    final initials = email.substring(0, 2).toUpperCase();

    return Scaffold(
      appBar: AppBar(title: const Text("Datos del Usuario")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                child: Text(initials,
                    style: const TextStyle(fontSize: 40, color: Colors.blue)),
              )),
          const SizedBox(height: 16),
          Text(email,
              style:
              const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _cerrarSesion(context),
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text("Cerrar Sesión", style: TextStyle(fontSize: 16)),
            ),
          ),
        ]),
      ),
    );
  }
}
