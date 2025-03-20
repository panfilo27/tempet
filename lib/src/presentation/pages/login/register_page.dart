// lib/src/presentation/pages/login/register_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempet/src/domain/usecases/auth_usecases.dart';
import 'package:tempet/src/data/repositories/firebase_auth_repository_impl.dart';
import 'package:tempet/src/presentation/blocs/login/login_bloc.dart';
import 'package:tempet/src/presentation/blocs/login/login_event.dart';
import 'package:tempet/src/presentation/blocs/login/login_state.dart';
import 'package:tempet/src/presentation/widgets/loading_overlay.dart';
import '../../theme/app_theme.dart';
import 'package:lottie/lottie.dart';

/// Widget que muestra el logo animado usando una imagen PNG.
/// Se utiliza un [AnimationController] para generar el efecto de escalado.
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

  /// Libera el controlador para evitar fugas de memoria.
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

/// Página de registro que permite al usuario crear una nueva cuenta.
/// Se inyecta el [LoginBloc] con los casos de uso para login y registro.
class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key}) : super(key: key);

  /// Muestra un Snackbar de éxito cuando el registro se realiza correctamente.
  void _showSuccessSnackBar(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Registro exitoso',
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

  /// Construye la interfaz principal de la página de registro.
  /// Se utiliza [BlocProvider] para inyectar el [LoginBloc] con los casos de uso,
  /// [BlocListener] para reaccionar a los cambios de estado y [BlocBuilder] para reconstruir la UI.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(
        // Inyección de dependencias: se proporcionan los casos de uso utilizando la implementación de Firebase.
        loginUser: LoginUser(FirebaseAuthRepositoryImpl()),
        registerUser: RegisterUser(FirebaseAuthRepositoryImpl()),
      ),
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginFailure) {
            _showErrorSnackBar(context, 'Error: ${state.error}');
          } else if (state is LoginSuccess) {
            _showSuccessSnackBar(context);
            Navigator.pushReplacementNamed(context, '/login');
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
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Muestra el logo animado.
                              const AnimatedLogo(),
                              const SizedBox(height: 24),
                              // Incluye el formulario de registro.
                              const _RegisterForm(),
                              const SizedBox(height: 16),
                              // Botón para navegar a la página de login si ya se tiene una cuenta.
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(context, '/login');
                                },
                                child: const Text(
                                  '¿Ya tienes cuenta? Inicia sesión',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
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

/// Formulario de registro que captura los datos necesarios para crear una cuenta.
/// Incluye campos para nombre de usuario, correo, contraseña y confirmación de contraseña.
class _RegisterForm extends StatefulWidget {
  const _RegisterForm({Key? key}) : super(key: key);

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  /// Inicializa los controladores para cada campo del formulario.
  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  /// Libera los controladores para evitar fugas de memoria.
  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Construye el formulario de registro, que incluye campos para:
  /// - Nombre de usuario
  /// - Correo electrónico
  /// - Contraseña
  /// - Confirmación de contraseña
  /// Y un botón que dispara el evento de registro.
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Campo para ingresar el nombre de usuario.
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Nombre de usuario',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese su nombre de usuario';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Campo para ingresar el correo electrónico.
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              prefixIcon: Icon(Icons.email),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese su correo';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Ingrese un correo válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Campo para ingresar la contraseña.
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
          const SizedBox(height: 16),
          // Campo para confirmar la contraseña.
          TextFormField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Confirmar contraseña',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _showConfirmPassword = !_showConfirmPassword;
                  });
                },
                child: Icon(
                  _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            ),
            obscureText: !_showConfirmPassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, confirme la contraseña';
              }
              if (value != _passwordController.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          // Botón que envía el formulario y dispara el evento de registro.
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Oculta el teclado.
                FocusScope.of(context).unfocus();
                if (_formKey.currentState?.validate() ?? false) {
                  context.read<LoginBloc>().add(
                    RegisterButtonPressed(
                      email: _emailController.text,
                      password: _passwordController.text,
                      confirmPassword: _confirmPasswordController.text,
                    ),
                  );
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text('Registrarse'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
