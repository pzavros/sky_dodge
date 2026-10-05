import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppPalette {
  static const Color deepSpace = Color(0xFF081427);
  static const Color nebulaBlue = Color(0xFF114D84);
  static const Color skyCyan = Color(0xFF3FD5FF);
  static const Color sunOrange = Color(0xFFFFB347);
  static const Color electricPink = Color(0xFFFF5DB2);
  static const Color panelDark = Color(0xCC10233F);
  static const Color panelBorder = Color(0x66AEE6FF);
}

ThemeData buildGameTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppPalette.skyCyan,
      brightness: Brightness.dark,
      primary: AppPalette.skyCyan,
      secondary: AppPalette.sunOrange,
      surface: const Color(0xFF0E1B34),
    ),
    scaffoldBackgroundColor: Colors.transparent,
  );

  final textTheme = GoogleFonts.baloo2TextTheme(base.textTheme).copyWith(
    displayLarge: GoogleFonts.bungee(
      fontSize: 52,
      color: Colors.white,
      letterSpacing: 1.1,
    ),
    headlineLarge: GoogleFonts.bungee(
      fontSize: 36,
      color: Colors.white,
      letterSpacing: 0.8,
    ),
    titleLarge: GoogleFonts.bungee(fontSize: 22, color: Colors.white),
    bodyLarge: GoogleFonts.baloo2(fontSize: 20, color: Colors.white),
    bodyMedium: GoogleFonts.baloo2(fontSize: 18, color: Colors.white),
    labelLarge: GoogleFonts.baloo2(
      fontSize: 18,
      color: Colors.white,
      fontWeight: FontWeight.w700,
    ),
  );

  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: const Color(0x66203A5D),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: textTheme.titleLarge,
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Color(0xFF15355B),
      contentTextStyle: TextStyle(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      color: AppPalette.panelDark,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
  );
}
