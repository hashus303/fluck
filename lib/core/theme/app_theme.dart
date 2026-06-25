import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Flock Design System ölçü token'ları.
class AppRadius {
  AppRadius._();
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 18.0;
  static const xl = 24.0;
  static const card = 20.0;
  static const pill = 999.0;
}

class AppSpace {
  AppSpace._();
  static const x1 = 4.0;
  static const x2 = 8.0;
  static const x3 = 12.0;
  static const x4 = 16.0;
  static const x5 = 20.0;
  static const x6 = 24.0;
  static const x7 = 32.0;
  static const gutter = 20.0;
}

/// Tipografi: Display = Bricolage Grotesque, Body = Plus Jakarta Sans,
/// Mono = JetBrains Mono.
class AppText {
  AppText._();

  static TextStyle display(double size,
          {FontWeight weight = FontWeight.w700, Color? color}) =>
      GoogleFonts.bricolageGrotesque(
        fontSize: size,
        fontWeight: weight,
        letterSpacing: -size * 0.03,
        height: 1.08,
        color: color ?? AppColors.textStrong,
      );

  static TextStyle body(double size,
          {FontWeight weight = FontWeight.w400, Color? color}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        letterSpacing: -size * 0.01,
        height: 1.45,
        color: color ?? AppColors.textBody,
      );

  static TextStyle mono(double size,
          {FontWeight weight = FontWeight.w600, Color? color}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: weight,
        letterSpacing: -size * 0.02,
        color: color ?? AppColors.textStrong,
      );

  static TextStyle eyebrow({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.0,
        color: color ?? AppColors.textFaint,
      );
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      primary: AppColors.brand,
      surface: AppColors.bgPage,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bgPage,
      textTheme: GoogleFonts.plusJakartaSansTextTheme().apply(
        bodyColor: AppColors.textBody,
        displayColor: AppColors.textStrong,
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }
}
