// lib/src/presentation/pages/splash/splash_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempet/src/domain/usecases/auth_usecases.dart';
import 'package:tempet/src/presentation/widgets/loading_overlay.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    // Pequeña pausa para mostrar el logo / animación.
    Timer(const Duration(seconds: 2), () {
      // Caso de uso para saber si hay usuario logeado.
      final user = context.read<GetCurrentUser>()();

      // Si existe, vamos directo al calendario; si no, al login.
      final nextRoute = user != null ? '/calendar' : '/login';
      Navigator.of(context).pushReplacementNamed(nextRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingOverlay(
        isLoading: true,
        child: Container(color: Colors.white),
      ),
    );
  }
}
