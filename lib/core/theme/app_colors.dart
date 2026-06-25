import 'package:flutter/material.dart';

/// Flock Design System renk token'ları.
/// Kaynak: Flock App UI kit (coral marka, cream zemin, trust-green vurgular).
class AppColors {
  AppColors._();

  // --- Coral (marka) ---
  static const coral50 = Color(0xFFFFF1ED);
  static const coral100 = Color(0xFFFFE0D6);
  static const coral200 = Color(0xFFFFC2AF);
  static const coral300 = Color(0xFFFF9B7E);
  static const coral400 = Color(0xFFFF7350);
  static const coral500 = Color(0xFFFB5436); // brand
  static const coral600 = Color(0xFFE63E22); // brand hover
  static const coral700 = Color(0xFFBE2F18); // brand press

  // --- Trust (güven / safe) ---
  static const trust50 = Color(0xFFE8F8F1);
  static const trust100 = Color(0xFFC7EFDD);
  static const trust300 = Color(0xFF54CB9C);
  static const trust500 = Color(0xFF0E9669); // success
  static const trust600 = Color(0xFF0A7B57);

  // --- Sky (info) ---
  static const sky500 = Color(0xFF2D6BE0);
  static const sky600 = Color(0xFF1F54BD);

  // --- Ink (metin / nötr) ---
  static const ink900 = Color(0xFF1A1512); // text strong
  static const ink800 = Color(0xFF2C2521); // text body
  static const ink600 = Color(0xFF6B5E55); // text muted
  static const ink500 = Color(0xFF8C7E73); // text faint
  static const ink300 = Color(0xFFD2C7BE); // border strong
  static const ink200 = Color(0xFFE8DFD8); // border subtle
  static const ink100 = Color(0xFFF3ECE5); // divider

  // --- Yüzeyler ---
  static const cream = Color(0xFFFBF4EE); // page bg
  static const creamDeep = Color(0xFFF4EAE0); // sunken
  static const paper = Color(0xFFFFFFFF); // card

  // --- Durum renkleri ---
  static const amber500 = Color(0xFFF5A524); // warning
  static const red500 = Color(0xFFE5484D); // danger
  static const red600 = Color(0xFFCB2A30);

  // --- Semantik kısayollar ---
  static const brand = coral500;
  static const brandHover = coral600;
  static const brandSoft = coral50;
  static const success = trust500;
  static const successSoft = trust50;
  static const info = sky500;
  static const warning = amber500;
  static const danger = red500;

  static const bgPage = cream;
  static const surfaceSunken = creamDeep;
  static const surfaceCard = paper;
  static const borderSubtle = ink200;
  static const borderStrong = ink300;

  static const textStrong = ink900;
  static const textBody = ink800;
  static const textMuted = ink600;
  static const textFaint = ink500;

  // --- Vibe (kategori) renkleri — harita pin renklerinden türetildi ---
  static const vibeCoffee = Color(0xFFB87333);
  static const vibeBar = Color(0xFF8B5CF6);
  static const vibeWalk = Color(0xFF2D6BE0);
  static const vibeGames = Color(0xFFC026A8);
  static const vibeFood = Color(0xFFE0681F);
  static const vibeMusic = Color(0xFFDB2777);

  // --- Gölgeler (sıcak tonlu) ---
  static const _shadowTint = Color(0x14281810); // rgba(40,24,16,.08)
  static List<BoxShadow> get shadowCard => const [
        BoxShadow(color: Color(0x0D281810), blurRadius: 4, offset: Offset(0, 2)),
        BoxShadow(color: _shadowTint, blurRadius: 16, offset: Offset(0, 6)),
      ];
  static List<BoxShadow> get shadowSm => const [
        BoxShadow(color: Color(0x0F281810), blurRadius: 2, offset: Offset(0, 1)),
        BoxShadow(color: Color(0x0D281810), blurRadius: 6, offset: Offset(0, 2)),
      ];
  static List<BoxShadow> glowCoral = const [
        BoxShadow(color: Color(0x52FB5436), blurRadius: 20, offset: Offset(0, 6)),
      ];
  static List<BoxShadow> glowDanger = const [
        BoxShadow(color: Color(0x57E5484D), blurRadius: 18, offset: Offset(0, 6)),
      ];
}
