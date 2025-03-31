// lib/src/presentation/pages/login/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempet/src/domain/usecases/auth_usecases.dart';
import 'package:tempet/src/data/repositories/firebase_auth_repository_impl.dart';
import 'package:tempet/src/presentation/blocs/login/login_bloc.dart';
import 'package:tempet/src/presentation/blocs/login/login_event.dart';
import 'package:tempet/src/presentation/blocs/login/login_state.dart';
import 'package:tempet/src/presentation/widgets/loading_overlay.dart';
import 'package:tempet/src/presentation/theme/app_theme.dart';
import 'package:lottie/lottie.dart';

/// Widget que muestra el logo animado con efecto de rebote.
class AnimatedLogo extends StatefulWidget {
  const AnimatedLogo({Key? key}) : super(key: key);

  @override
  _AnimatedLogoState createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );
    _animation = Tween<double>(begin: 0.4, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Image.asset(
        'assets/images/calendarioimg.png',
        width: 120,
        height: 100,
      ),
    );
  }
}

/// Página de inicio de sesión.
class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  /// Muestra un Snackbar de éxito.
  void _showSuccessSnackBar(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Login exitoso',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: appColors?.success ?? Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 6,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Muestra un Snackbar de error con el mensaje recibido.
  void _showErrorSnackBar(BuildContext context, String error) {
    final appColors = Theme.of(context).extension<AppColorsExtension>();
    print(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: appColors?.danger ?? Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 6,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(
        // Se inyectan los casos de uso utilizando la implementación de Firebase.
        loginUser: LoginUser(FirebaseAuthRepositoryImpl()),
        registerUser: RegisterUser(FirebaseAuthRepositoryImpl()),
      ),
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginFailure) {
            // Se muestra directamente el mensaje de error amigable.
            _showErrorSnackBar(context, state.error);
          } else if (state is LoginSuccess) {
            _showSuccessSnackBar(context);
            Navigator.pushReplacementNamed(context, '/calendar');
          }
        },
        child: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            bool isLoading = state is LoginLoading;
            return LoadingOverlay(
              isLoading: isLoading,
              child: Scaffold(
                body: Stack(
                  children: [
                    // Fondo animado.
                    Positioned.fill(
                      child: Lottie.asset(
                        'assets/lottie/fondo.json',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Container(
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedLogo(),
                              SizedBox(height: 24),
                              _LoginForm(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Formulario de inicio de sesión.
class _LoginForm extends StatefulWidget {
  const _LoginForm({Key? key}) : super(key: key);

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              prefixIcon: Icon(Icons.email),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, ingrese su correo';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Ingrese un correo válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
                child: Icon(
                  _showPassword ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            ),
            obscureText: !_showPassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, ingrese una contraseña';
              }
              if (value.length < 6) {
                return 'La contraseña debe tener al menos 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                if (_formKey.currentState?.validate() ?? false) {
                  context.read<LoginBloc>().add(
                    LoginButtonPressed(
                      email: _emailController.text,
                      password: _passwordController.text,
                    ),
                  );
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text('Iniciar sesión'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/register');
            },
            child: const Text('¿No tienes cuenta? Regístrate'),
          ),
        ],
      ),
    );
  }
}
