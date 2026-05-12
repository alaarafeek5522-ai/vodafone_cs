import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color red = Color(0xFFE60000);
  static const Color darkRed = Color(0xFF9E0000);
  static const Color gold = Color(0xFFFFD700);

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        colorScheme: const ColorScheme.dark(
          primary: red,
          secondary: gold,
          surface: Color(0xFF141414),
        ),
        textTheme: GoogleFonts.cairoTextTheme(
          const TextTheme(
            displayLarge: TextStyle(color: Colors.white),
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
          ),
        ),
      );

  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        colorScheme: const ColorScheme.light(
          primary: red,
          secondary: gold,
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.cairoTextTheme(
          const TextTheme(
            displayLarge: TextStyle(color: Color(0xFF0A0A0A)),
            bodyLarge: TextStyle(color: Color(0xFF0A0A0A)),
            bodyMedium: TextStyle(color: Color(0xFF0A0A0A)),
          ),
        ),
      );
}
