import 'package:flutter/material.dart';

/// Extensión personalizada para definir colores de éxito y error.
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color? success;
  final Color? danger;

  const AppColorsExtension({
    this.success,
    this.danger,
  });

  @override
  AppColorsExtension copyWith({Color? success, Color? danger}) {
    return AppColorsExtension(
      success: success ?? this.success,
      danger: danger ?? this.danger,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      success: Color.lerp(success, other.success, t),
      danger: Color.lerp(danger, other.danger, t),
    );
  }
}

/// Definición del tema de la aplicación.
class AppTheme {
  static ThemeData get temaClaro {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFFA8DADC), // Pastel azul-verde
      scaffoldBackgroundColor: const Color(0xFFF1FAEE), // Off-white pastel
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF225C4B),
        foregroundColor: Colors.black,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black, backgroundColor: const Color(0xFF225C4B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: _pastelSwatch,
        accentColor: const Color(0xFFF4A261), // Pastel naranja
        brightness: Brightness.light,
      ),
      extensions: const <ThemeExtension<dynamic>>[
        AppColorsExtension(
          success: Color(0xFF2A9D8F),
          danger: Color(0xFFE76F51),
        ),
      ],
    );
  }

  static ThemeData get temaOscuro {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF457B9D), // Azul pastel oscuro
      scaffoldBackgroundColor: const Color(0xFF1D3557), // Azul marino oscuro
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF457B9D),
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, backgroundColor: const Color(0xFF457B9D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: _pastelSwatch,
        accentColor: const Color(0xFFF4A261),
        brightness: Brightness.dark,
      ),
      extensions: const <ThemeExtension<dynamic>>[
        AppColorsExtension(
          success: Color(0xFF2A9D8F),
          danger: Color(0xFFE76F51),
        ),
      ],
    );
  }
}

MaterialColor _pastelSwatch = const MaterialColor(0xFF225C4B, <int, Color>{
  50: Color(0xFFE8F7F5),
  100: Color(0xFFC1E8E1),
  200: Color(0xFF99D8CD),
  300: Color(0xFF70C8B8),
  400: Color(0xFF52BBA8),
  500: Color(0xFFA8DADC), // Color base
  600: Color(0xFF3A9C8C),
  700: Color(0xFF338F81),
  800: Color(0xFF2D8266),
  900: Color(0xFF225C4B),
});
