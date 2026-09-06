import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  /// Açık şema — krem sayfa, beyaz kart, derin coral marka.
  static ThemeData get light => _build(
        brightness: Brightness.light,
        primary: AppColors.coral650,
        onPrimary: AppColors.paper,
        primaryContainer: AppColors.coral50,
        onPrimaryContainer: AppColors.coral700,
        surface: AppColors.cream,
        surfaceContainer: AppColors.paper,
        onSurface: AppColors.ink800,
        onSurfaceVariant: AppColors.ink600,
        outline: AppColors.ink300,
        outlineVariant: AppColors.ink200,
        error: AppColors.red550,
        onError: AppColors.paper,
        displayColor: AppColors.ink900,
      );

  /// Koyu şema — kavrulmuş kahve yüzeyler. Açığın tersi değil: marka
  /// aydınlanır (coral400) ve üstündeki yazı koyulaşır, Material 3'ün
  /// primary / on-primary kalıbı gibi.
  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        primary: AppColors.coral400,
        onPrimary: AppColors.espresso800,
        primaryContainer: const Color(0xFF33190F),
        onPrimaryContainer: AppColors.coral200,
        surface: AppColors.espresso800,
        surfaceContainer: AppColors.espresso700,
        onSurface: AppColors.sand100,
        onSurfaceVariant: AppColors.sand300,
        outline: AppColors.espresso500,
        outlineVariant: AppColors.espresso600,
        error: AppColors.red300,
        onError: AppColors.espresso800,
        displayColor: AppColors.sand50,
      );

  /// Sistem çubuklarının ikon rengi — zeminin tersi olmalı, yoksa
  /// koyu temada saat ve pil simgeleri kaybolur.
  static SystemUiOverlayStyle overlay(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
      statusBarBrightness: dark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor:
          dark ? AppColors.espresso800 : AppColors.paper,
      systemNavigationBarIconBrightness:
          dark ? Brightness.light : Brightness.dark,
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required Color primary,
    required Color onPrimary,
    required Color primaryContainer,
    required Color onPrimaryContainer,
    required Color surface,
    required Color surfaceContainer,
    required Color onSurface,
    required Color onSurfaceVariant,
    required Color outline,
    required Color outlineVariant,
    required Color error,
    required Color onError,
    required Color displayColor,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: AppColors.trust550,
      onSecondary: AppColors.paper,
      surface: surface,
      onSurface: onSurface,
      surfaceContainer: surfaceContainer,
      surfaceContainerHighest: surfaceContainer,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      error: error,
      onError: onError,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: surface,
      canvasColor: surface,
      dividerColor: outlineVariant,
      textTheme: GoogleFonts.plusJakartaSansTextTheme().apply(
        bodyColor: onSurface,
        displayColor: displayColor,
      ),
      splashFactory: InkRipple.splashFactory,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: brightness == Brightness.dark
            ? AppColors.espresso700
            : AppColors.ink900,
        contentTextStyle: GoogleFonts.plusJakartaSans(
          color: brightness == Brightness.dark
              ? AppColors.sand50
              : AppColors.paper,
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
