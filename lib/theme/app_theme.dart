import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: const Color(0xFF232A7A),
      scaffoldBackgroundColor: const Color(0xFFF9F9F9),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: const Color(0xFF232A7A),
        secondary: const Color(0xFFFFC72C),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFC72C),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF232A7A),
        ),
        bodyLarge: TextStyle(
          color: Colors.black87,
        ),
        bodyMedium: TextStyle(
          color: Colors.black54,
        ),
      ),
      fontFamily: 'Montserrat',
    );
  }
} 