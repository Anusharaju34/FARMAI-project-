import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors (Smart Farming)
  static const Color primaryGreen = Color(0xFF2E7D32);   // Forest Green
  static const Color lightGreen = Color(0xFF4CAF50);     // Mint Green
  static const Color accentGreen = Color(0xFF8BC34A);    // Lime Green
  static const Color darkGreen = Color(0xFF1E2A1F);      // Deep Earth Green
  static const Color warningOrange = Color(0xFFF9A825);  // Warning Yellow/Orange
  static const Color alertRed = Color(0xFFE53935);       // Danger Red
  
  static const Color waterBlue = Color(0xFF29B6F6);      // Water
  static const Color earthBrown = Color(0xFF8D6E63);     // Earth
  static const Color skyBlue = Color(0xFF81D4FA);        // Sky

  static const Color sunYellow = Color(0xFFFFB300);
  static const Color soilBrown = Color(0xFF8D6E63);
  static const Color seedGreen = Color(0xFF2E7D32);

  // Light Theme Palette
  static const Color backgroundLight = Color(0xFFF7FAF3); // Light Background
  static const Color surfaceLight = Color(0xFFFFFFFF);    // Cards/Sheets
  static const Color borderLight = Color(0xFFE2EBE0);     // Soft Border

  // Dark Theme Palette
  static const Color backgroundDark = Color(0xFF1E2A1F);  // Dark Background
  static const Color surfaceDark = Color(0xFF253426);     // Dark Cards
  static const Color borderDark = Color(0xFF2D3E2F);      // Dark Border

  static const Color cardLight = surfaceLight;
  static const Color cardDark = surfaceDark;

  static List<BoxShadow> get premiumShadow {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: primaryGreen.withOpacity(0.02),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ];
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.light,
        primary: primaryGreen,
        secondary: lightGreen,
        tertiary: accentGreen,
        surface: surfaceLight,
        background: backgroundLight,
        outline: borderLight,
      ),
      textTheme: _buildTextTheme(Brightness.light),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: primaryGreen),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: primaryGreen,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: borderLight, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderLight, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: alertRed, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
        hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: CircleBorder(),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceLight,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.dark,
        primary: lightGreen,
        secondary: accentGreen,
        tertiary: primaryGreen,
        surface: surfaceDark,
        background: backgroundDark,
        outline: borderDark,
      ),
      textTheme: _buildTextTheme(Brightness.dark),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: borderDark, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightGreen,
          foregroundColor: Colors.black87,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightGreen,
          side: const BorderSide(color: lightGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderDark, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightGreen, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
        hintStyle: GoogleFonts.poppins(color: Colors.white38, fontSize: 14),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: lightGreen,
        foregroundColor: Colors.black87,
        elevation: 6,
        shape: CircleBorder(),
      ),
    );
  }

  static TextTheme _buildTextTheme(Brightness brightness) {
    final color =
        brightness == Brightness.light ? Colors.black87 : Colors.white;
    return GoogleFonts.poppinsTextTheme(
      TextTheme(
        displayLarge:
            TextStyle(fontSize: 57, fontWeight: FontWeight.w800, color: color, letterSpacing: -1.5),
        displayMedium:
            TextStyle(fontSize: 45, fontWeight: FontWeight.w800, color: color, letterSpacing: -1),
        displaySmall:
            TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: color, letterSpacing: -0.5),
        headlineLarge:
            TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: color),
        headlineMedium:
            TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: color),
        headlineSmall:
            TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: color),
        titleLarge:
            TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color),
        titleMedium:
            TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color),
        titleSmall:
            TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
        bodyLarge:
            TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: color, height: 1.5),
        bodyMedium:
            TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: color, height: 1.4),
        bodySmall:
            TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: color),
        labelLarge:
            TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
        labelMedium:
            TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color),
        labelSmall:
            TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color),
      ),
    );
  }
}
