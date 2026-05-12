import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color red = Color(0xFFE60000);
  static const Color darkRed = Color(0xFF9E0000);
  static const Color black = Color(0xFF0A0A0A);
  static const Color darkCard = Color(0xFF141414);
  static const Color darkSurface = Color(0xFF1C1C1C);
  static const Color gold = Color(0xFFFFD700);
  static const Color white = Color(0xFFF5F5F5);
  static const Color grey = Color(0xFF888888);

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: black,
        colorScheme: const ColorScheme.dark(
          primary: red,
          secondary: gold,
          surface: darkCard,
        ),
        textTheme: GoogleFonts.cairoTextTheme(
          const TextTheme(
            displayLarge: TextStyle(color: white),
            bodyLarge: TextStyle(color: white),
            bodyMedium: TextStyle(color: white),
          ),
        ),
      );
}
