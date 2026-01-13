import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Core Colors
  static const Color dashOrange = Color(0xFFFF6B35);
  static const Color yolkYellow = Color(0xFFF7C548);
  static const Color lettuceGreen = Color(0xFF00CC66);
  static const Color asphaltBlue = Color(0xFF2B2D42);
  static const Color sidewalkGrey = Color(0xFF8D99AE);
  static const Color creamCanvas = Color(0xFFFFF8F0);
  static const Color ketchupRed = Color(0xFFEF233C);

  // Border Colors (Darker shades for "Sticker" effect)
  static const Color dashOrangeBorder = Color(0xFFC4491A);
  static const Color creamCanvasBorder = asphaltBlue;

  // Design Constants
  static const double radiusStandard = 24.0;
  static const double radiusButton = 30.0;
  static const double radiusInner = 16.0;

  static const double borderWidth = 3.0;
  static const double buttonBorderWidth = 4.0;

  // Text Styles
  static TextStyle get headlineTextStyle => GoogleFonts.lilitaOne(
        fontSize: 24,
        color: Colors.white,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodyTextStyle => GoogleFonts.nunito(
        fontSize: 16,
        color: asphaltBlue,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get buttonTextStyle => GoogleFonts.lilitaOne(
        fontSize: 24,
        color: Colors.white,
      );

  // Theme Data
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: asphaltBlue,
      colorScheme: ColorScheme.fromSeed(
        seedColor: dashOrange,
        primary: dashOrange,
        secondary: yolkYellow,
        surface: creamCanvas,
        error: ketchupRed,
      ),
      textTheme: TextTheme(
        displayLarge: headlineTextStyle.copyWith(fontSize: 48),
        displayMedium: headlineTextStyle.copyWith(fontSize: 32),
        displaySmall: headlineTextStyle.copyWith(fontSize: 24),
        bodyLarge: bodyTextStyle,
        bodyMedium: bodyTextStyle.copyWith(fontSize: 14),
        labelLarge: buttonTextStyle,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: dashOrange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
            side: const BorderSide(
              color: dashOrangeBorder,
              width: buttonBorderWidth,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
          elevation: 0, // We use custom shadows usually, but 0 for flat look
        ),
      ),
    );
  }
}

