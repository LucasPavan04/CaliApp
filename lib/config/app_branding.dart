import 'package:flutter/material.dart';

/// Configuración de marca del gimnasio.
/// Para adaptar la app a otro cliente, modificá solo este archivo y los assets.
class AppBranding {
  // ——— Identidad ———
  static const String appName = 'Cali App';
  static const String gymName = 'Cali Gym';

  /// WhatsApp: código de país + número, sin + ni espacios.
  static const String whatsapp = '5491112345678';

  // ——— Assets ———
  static const String headerImage = 'assets/F2.PNG';

  // ——— Colores ———
  static const Color primary = Color(0xFFFFD700);
  static const Color primaryDark = Color(0xFFFFC107);
  static const Color primaryAccent = Color(0xFFE6B800);
  static const Color primaryIcon = Color(0xFFC9A600);
  static const Color whatsappGreen = Color(0xFF25D366);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primary,
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: primary,
          contentTextStyle: TextStyle(color: Colors.black),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) return primary;
            return null;
          }),
          checkColor: MaterialStateProperty.all(Colors.black87),
        ),
        chipTheme: ChipThemeData(
          selectedColor: primary.withOpacity(0.4),
          checkmarkColor: Colors.black87,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.06),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

  static OutlineInputBorder inputBorder({double radius = 12}) =>
      OutlineInputBorder(borderRadius: BorderRadius.circular(radius));

  static OutlineInputBorder focusedInputBorder({double radius = 12}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: primary, width: 2),
      );

  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.black,
      );

  static BoxDecoration primaryChipDecoration({double opacity = 0.25}) =>
      BoxDecoration(
        color: primary.withOpacity(opacity),
        borderRadius: BorderRadius.circular(8),
      );

  static BoxDecoration primarySectionDecoration({double opacity = 0.2}) =>
      BoxDecoration(
        color: primary.withOpacity(opacity),
        borderRadius: BorderRadius.circular(10),
      );
}
