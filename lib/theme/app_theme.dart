import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Backgrounds
  static const Color darkNavy = Color(0xFF05052F);
  static const Color deepNavy = Color(0xFF08083D);
  static const Color secondaryNavy = Color(0xFF11145C);
  static const Color cardNavy = Color(0xFF0D1045);
  static const Color cardNavyLight = Color(0xFF141959);
  static const Color bottomNavBg = Color(0xFF03051F);

  // Primary Blues & Cyans
  static const Color electricBlue = Color(0xFF246BFF);
  static const Color brightBlue = Color(0xFF2878FF);
  static const Color brightCyan = Color(0xFF11C7F5);
  static const Color lightCyan = Color(0xFF29D7F5);

  // Accents
  static const Color successGreen = Color(0xFF00D66B);
  static const Color brightGreen = Color(0xFF16E676);
  static const Color purple = Color(0xFF5B45D6);
  static const Color violet = Color(0xFF7548E8);
  static const Color teal = Color(0xFF00BFA6);
  static const Color orange = Color(0xFFFF9D24);
  static const Color alertRed = Color(0xFFE52C35);

  // Neutrals
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFFB7BED2);
  static const Color secondaryGrey = Color(0xFF858DA6);
  static const Color borderSubtle = Color(0x33246BFF);
  static const Color borderLight = Color(0x22FFFFFF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF246BFF), Color(0xFF11C7F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF6548D8), Color(0xFF4B35C5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenTealGradient = LinearGradient(
    colors: [Color(0xFF00D5B0), Color(0xFF00A982)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFFFAA32), Color(0xFFF27D00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient redGradient = LinearGradient(
    colors: [Color(0xFFEF3B3B), Color(0xFFC91F2A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF168CFF), Color(0xFF16C8F0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF0E134D), Color(0xFF080B33)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkNavy,
      primaryColor: AppColors.electricBlue,
      canvasColor: AppColors.darkNavy,
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.dark().textTheme.copyWith(
          displayLarge: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.textWhite,
            letterSpacing: -0.5,
          ),
          displayMedium: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.textWhite,
          ),
          headlineLarge: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textWhite,
          ),
          headlineMedium: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textWhite,
          ),
          titleLarge: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textWhite,
          ),
          titleMedium: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textGrey,
          ),
          bodyLarge: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textWhite,
          ),
          bodyMedium: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textGrey,
          ),
          labelLarge: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textWhite,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.deepNavy,
        hintStyle: GoogleFonts.poppins(
          color: AppColors.secondaryGrey,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.poppins(
          color: AppColors.textGrey,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.borderSubtle, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.borderSubtle, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.brightCyan, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.alertRed, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.electricBlue,
        secondary: AppColors.brightCyan,
        surface: AppColors.deepNavy,
        error: AppColors.alertRed,
      ),
    );
  }
}
