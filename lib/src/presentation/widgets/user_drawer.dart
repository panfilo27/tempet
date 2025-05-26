// lib/src/presentation/widgets/user_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tempet/src/domain/usecases/auth_usecases.dart';

class UserDrawer extends StatelessWidget {
  final Function(CalendarView) onViewChange;

  const UserDrawer({Key? key, required this.onViewChange}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Caso de uso para obtener el usuario actual
    final User? user = context.read<GetCurrentUser>()();

    // Correo e iniciales
    final String email = user?.email ?? 'usuario@example.com';
    final String initials =
    email.isNotEmpty ? email.substring(0, 2).toUpperCase() : 'US';

    // Si quieres un “nombre” toma lo que está antes de la arroba
    final String name = email.split('@').first;

    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName : Text(name),
            accountEmail: Text(email),
            currentAccountPicture: InkWell(
              onTap: () => Navigator.pushNamed(context, '/userData'),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  initials,
                  style: const TextStyle(fontSize: 24, color: Colors.blue),
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.view_day),
            title: const Text("Vista Día"),
            onTap: () {
              Navigator.pop(context);
              onViewChange(CalendarView.day);
            },
          ),
          ListTile(
            leading: const Icon(Icons.view_week),
            title: const Text("Vista Semana"),
            onTap: () {
              Navigator.pop(context);
              onViewChange(CalendarView.week);
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text("Vista Mes"),
            onTap: () {
              Navigator.pop(context);
              onViewChange(CalendarView.month);
            },
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text("Vista Agenda"),
            onTap: () {
              Navigator.pop(context);
              onViewChange(CalendarView.schedule);
            },
          ),
        ],
      ),
    );
  }
}
