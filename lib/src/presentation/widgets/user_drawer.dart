import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:tempet/src/presentation/pages/user/user_page.dart';

class UserDrawer extends StatelessWidget {
  final Function(CalendarView) onViewChange;

  const UserDrawer({Key? key, required this.onViewChange}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text("Juan Pérez"),
            accountEmail: const Text("juanperez@example.com"),
            currentAccountPicture: InkWell(
              onTap: () {
                // Navega a la pantalla de datos del usuario
                Navigator.pushNamed(context, '/userData');
              },
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  "JP",
                  style: TextStyle(fontSize: 24, color: Colors.blue),
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
