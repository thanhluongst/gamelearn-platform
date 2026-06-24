import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryColor = Color(0xFF6C63FF);     // Purple
  static const Color secondaryColor = Color(0xFFFF6584);   // Pink
  static const Color accentColor = Color(0xFF43E97B);      // Green
  static const Color warningColor = Color(0xFFFFBE0B);     // Yellow
  static const Color errorColor = Color(0xFFFF4D6D);       // Red

  // Game Colors
  static const Color goldColor = Color(0xFFFFD700);
  static const Color silverColor = Color(0xFFC0C0C0);
  static const Color bronzeColor = Color(0xFFCD7F32);
  static const Color xpColor = Color(0xFF6C63FF);
  static const Color coinColor = Color(0xFFFFD700);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF3F3D9E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFF9A9E), Color(0xFFFFBE0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient coolGradient = LinearGradient(
    colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Game type gradients
  static const Map<String, LinearGradient> gameGradients = {
    'fishing': LinearGradient(colors: [Color(0xFF00C6FF), Color(0xFF0072FF)]),
    'gold_mining': LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
    'car_race': LinearGradient(colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)]),
    'treasure_hunt': LinearGradient(colors: [Color(0xFF11998E), Color(0xFF38EF7D)]),
    'puzzle': LinearGradient(colors: [Color(0xFFDA22FF), Color(0xFF9733EE)]),
    'arena': LinearGradient(colors: [Color(0xFFF7971E), Color(0xFFFFD200)]),
  };

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      error: errorColor,
    ),
    textTheme: GoogleFonts.nunitoTextTheme().copyWith(
      displayLarge: GoogleFonts.nunito(
        fontSize: 32, fontWeight: FontWeight.w800, color: const Color(0xFF1A1A2E),
      ),
      displayMedium: GoogleFonts.nunito(
        fontSize: 28, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E),
      ),
      headlineLarge: GoogleFonts.nunito(
        fontSize: 24, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E),
      ),
      headlineMedium: GoogleFonts.nunito(
        fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E),
      ),
      titleLarge: GoogleFonts.nunito(
        fontSize: 18, fontWeight: FontWeight.w700,
      ),
      titleMedium: GoogleFonts.nunito(
        fontSize: 16, fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w400),
      labelLarge: GoogleFonts.nunito(
        fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.5,
      ),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: const Color(0xFF1A1A2E),
      titleTextStyle: GoogleFonts.nunito(
        fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF1A1A2E),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: primaryColor.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5F5FF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE0E0FF), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      labelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w600),
    ),
    scaffoldBackgroundColor: const Color(0xFFF8F8FF),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: Color(0xFF9E9E9E),
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF0D0D1A),
  );

  // Difficulty colors
  static Color difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy': return const Color(0xFF43E97B);
      case 'medium': return const Color(0xFFFFBE0B);
      case 'hard': return const Color(0xFFFF4D6D);
      default: return const Color(0xFF9E9E9E);
    }
  }

  static String difficultyLabel(String difficulty) {
    switch (difficulty) {
      case 'easy': return 'Dễ';
      case 'medium': return 'Trung bình';
      case 'hard': return 'Khó';
      default: return 'Không rõ';
    }
  }
}
