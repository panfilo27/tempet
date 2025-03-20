import 'package:flutter/material.dart';
import 'package:tempet/src/presentation/pages/login/login_page.dart';
import 'package:tempet/src/presentation/pages/login/register_page.dart';
import 'package:tempet/src/presentation/pages/search_page.dart';
import 'package:tempet/src/presentation/pages/user/user_page.dart';
import '../pages/calendar/calendar_page.dart';
import '../pages/splash/splash_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/calendar':
        return MaterialPageRoute(builder: (_) => const CalendarPage());
      case '/search':
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
          const SearchPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end);
            final offsetAnimation = animation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
        case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case '/userData': // Nueva ruta para los datos del usuario
        return MaterialPageRoute(builder: (_) => const UserDataPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No se definió la ruta ${settings.name}'),
            ),
          ),
        );
    }
  }
}
