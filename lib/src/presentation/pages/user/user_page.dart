import 'package:flutter/material.dart';

class UserDataPage extends StatelessWidget {
  const UserDataPage({Key? key}) : super(key: key);

  void _cerrarSesion(BuildContext context) {
    // Aquí agregas la lógica para cerrar sesión.
    // Por ejemplo, limpiar las credenciales y navegar a la pantalla de login.
    Navigator.pushNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Datos del Usuario"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Foto del usuario
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                child: const Text(
                  "JP",
                  style: TextStyle(fontSize: 40, color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Nombre del usuario
            const Text(
              "Juan Pérez",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Correo electrónico
            const Text(
              "juanperez@example.com",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Spacer(),
            // Botón para cerrar sesión
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _cerrarSesion(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: const Text(
                  "Cerrar Sesión",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
