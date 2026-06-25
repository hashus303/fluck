import 'package:flutter/material.dart';

import '../../../core/models/flock.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/flock_widgets.dart';
import '../../../l10n/app_localizations.dart';

/// Harita ekranı — yakındaki flock'ları pin'lerle gösterir.
///
/// Not: Gerçek `GoogleMap` widget'ı bir API anahtarı gerektirir (bkz. README).
/// Anahtar eklenene kadar tasarıma uygun stilize bir placeholder gösterilir.
class MapScreen extends StatelessWidget {
  final void Function(Flock)? onOpenInvite;
  const MapScreen({super.key, this.onOpenInvite});

  @override
  Widget build(BuildContext context) {
    final peek = kFlocks.first;
    return Stack(children: [
      // stylized map backdrop
      Positioned.fill(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.creamDeep, AppColors.cream],
            ),
          ),
          child: CustomPaint(painter: _GridPainter()),
        ),
      ),
      // pins
      const _Pin(left: 0.24, top: 0.30, vibeId: 'coffee'),
      const _Pin(left: 0.62, top: 0.26, vibeId: 'walk'),
      const _Pin(left: 0.72, top: 0.52, vibeId: 'games'),
      const _Pin(left: 0.40, top: 0.60, vibeId: 'bar'),
      const _YouPin(left: 0.48, top: 0.72),

      // top search bar
      Positioned(
        top: 0, left: 0, right: 0,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(children: [
              Expanded(
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(color: AppColors.borderSubtle),
                    boxShadow: AppColors.shadowSm,
                  ),
                  child: Row(children: [
                    const Icon(Icons.search, size: 18, color: AppColors.textMuted),
                    const SizedBox(width: 8),
                    Text(AppL10n.of(context).searchThisArea,
                        style: AppText.body(14, weight: FontWeight.w600, color: AppColors.textMuted)),
                  ]),
                ),
              ),
              const SizedBox(width: 10),
              _GlassIconButton(icon: Icons.tune, onTap: () {}),
            ]),
          ),
        ),
      ),

      // locate-me
      Positioned(
        right: 14, bottom: 180,
        child: _GlassIconButton(icon: Icons.my_location, onTap: () {}),
      ),

      // floating peek card
      Positioned(
        left: 14, right: 14, bottom: 14,
        child: InviteCard(flock: peek, onTap: () => onOpenInvite?.call(peek)),
      ),
    ]);
  }
}

class _Pin extends StatelessWidget {
  final double left, top;
  final String vibeId;
  const _Pin({required this.left, required this.top, required this.vibeId});
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Positioned(
      left: left * size.width,
      top: top * size.height,
      child: VibeDot(vibe: vibeById(vibeId), size: 44),
    );
  }
}

class _YouPin extends StatelessWidget {
  final double left, top;
  const _YouPin({required this.left, required this.top});
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Positioned(
      left: left * size.width,
      top: top * size.height,
      child: Container(
        width: 22, height: 22,
        decoration: BoxDecoration(
          color: AppColors.sky500,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const [BoxShadow(color: Color(0x552D6BE0), blurRadius: 12)],
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassIconButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46, height: 46,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.82),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: AppColors.shadowSm,
        ),
        child: Icon(icon, size: 20, color: AppColors.textBody),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.ink200.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    const step = 56.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
