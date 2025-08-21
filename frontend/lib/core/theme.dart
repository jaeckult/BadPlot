import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static final ThemeData light = ThemeData(
    // Modern color scheme with gradient support
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF0077B6), // Deep ocean blue
      brightness: Brightness.light,
    ),
    // Slightly lighter scaffold background for freshness
    scaffoldBackgroundColor: const Color(0xFFF0F8FA),
    // Typography with Poppins for a premium feel
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w700,
        fontSize: 24,
        letterSpacing: -0.5,
        color: Colors.black87,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        fontSize: 18,
        letterSpacing: -0.3,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w400,
        fontSize: 16,
        height: 1.5,
        color: Colors.black87,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w400,
        fontSize: 14,
        height: 1.5,
        color: Colors.black54,
      ),
    ),
    // Transparent app bar with a slight blur effect
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black87,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    ),
    // Neumorphic-inspired card
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    // Elevated button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        backgroundColor: const Color(0xFF0077B6), // Blue
        foregroundColor: Colors.white,
        shadowColor: Colors.black.withOpacity(0.2),
        elevation: 4,
      ),
    ),
    // Outlined button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide(
          color: const Color(0xFF00B4D8).withOpacity(0.6), // Teal border
          width: 1.5,
        ),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        foregroundColor: const Color(0xFF00B4D8), // Teal text
        backgroundColor: Colors.white.withOpacity(0.9),
      ),
    ),
    // Input fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.95),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF0077B6), // Blue when focused
          width: 1.5,
        ),
      ),
      labelStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        color: Colors.black54,
      ),
      hintStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        color: Colors.black.withOpacity(0.4),
      ),
    ),
    // Smooth transitions
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    // Floating action button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF00B4D8), // Teal
      elevation: 4,
      shape: CircleBorder(),
      foregroundColor: Colors.white,
      extendedTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
      ),
    ),
    // Custom extensions
    extensions: <ThemeExtension<dynamic>>[
      AppGradients(
        backgroundGradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0077B6), // Blue
            Color(0xFF00B4D8), // Teal
            Color(0xFF90E0EF), // Light Aqua
          ],
        ),
      ),
    ],
  );
}

class AppGradients extends ThemeExtension<AppGradients> {
  final Gradient backgroundGradient;

  const AppGradients({required this.backgroundGradient});

  @override
  AppGradients copyWith({Gradient? backgroundGradient}) {
    return AppGradients(
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
    );
  }

  @override
  AppGradients lerp(ThemeExtension<AppGradients>? other, double t) {
    if (other is! AppGradients) return this;
    return t < 0.5 ? this : other;
  }
}
