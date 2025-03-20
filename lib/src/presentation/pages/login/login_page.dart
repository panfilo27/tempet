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
/// Se utiliza un AnimationController para controlar la animación del logo.
class AnimatedLogo extends StatefulWidget {
  const AnimatedLogo({Key? key}) : super(key: key);

  @override
  _AnimatedLogoState createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  /// Inicializa el controlador y configura la animación.
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
    // Inicia la animación después de un breve retraso.
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  /// Libera el controlador de animación para evitar fugas de memoria.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Construye el widget que muestra el logo escalado según la animación.
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

/// Página de inicio de sesión que permite al usuario autenticarse.
/// Se inyecta el [LoginBloc] con sus respectivos casos de uso de login y registro.
class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  /// Muestra un Snackbar de éxito cuando el login es exitoso.
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

  /// Construye la interfaz principal de la página de login.
  /// Se utiliza [BlocProvider] para inyectar el [LoginBloc] y [BlocListener] y [BlocBuilder]
  /// para reaccionar a los cambios de estado.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(
        // Se inyectan los casos de uso para login y registro utilizando la implementación de Firebase.
        loginUser: LoginUser(FirebaseAuthRepositoryImpl()),
        registerUser: RegisterUser(FirebaseAuthRepositoryImpl()),
      ),
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginFailure) {
            _showErrorSnackBar(context, 'Error: ${state.error}');
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
                    // Fondo animado con Lottie que se adapta al tamaño del contenedor.
                    Positioned.fill(
                      child: Lottie.asset(
                        'assets/lottie/fondo.json',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Center(
                      // SingleChildScrollView permite desplazar el contenido en pantallas pequeñas para evitar overflow.
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Container(
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            // Fondo blanco semitransparente para resaltar el formulario.
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
                              // Muestra el logo animado.
                              AnimatedLogo(),
                              SizedBox(height: 24),
                              // Incluye el formulario de login.
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

/// Formulario de inicio de sesión que captura el correo y la contraseña del usuario.
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

  /// Inicializa los controladores para los campos de texto.
  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  /// Libera los controladores para evitar fugas de memoria.
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Construye el formulario de login, que incluye campos para correo y contraseña,
  /// y un botón para disparar el evento de inicio de sesión.
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Campo de texto para ingresar el correo electrónico.
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
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Ingrese un correo válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Campo de texto para ingresar la contraseña.
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: const Icon(Icons.lock),
              // Botón para alternar la visibilidad de la contraseña.
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
          // Botón que envía el formulario y dispara el evento de login.
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Oculta el teclado al presionar el botón.
                FocusScope.of(context).unfocus();
                if (_formKey.currentState?.validate() ?? false) {
                  // Dispara el evento de login con los datos ingresados.
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
          // Botón para navegar a la página de registro.
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
