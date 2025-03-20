import 'package:flutter/material.dart';
import 'dart:async';
import 'package:tempet/src/presentation/widgets/loading_overlay.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Después de 3 segundos, navega a la pantalla de login.
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingOverlay(
        isLoading: true,
        child: Container(
          color: Colors.white,
        ),
      ),
    );
  }
}
