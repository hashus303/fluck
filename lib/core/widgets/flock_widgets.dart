import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../models/flock.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// İkon-only yuvarlak vibe token'ı — kartlarda ve harita pin'lerinde.
class VibeDot extends StatelessWidget {
  final Vibe vibe;
  final double size;
  const VibeDot({super.key, required this.vibe, this.size = 46});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.paper,
        shape: BoxShape.circle,
        border: Border.all(color: vibe.color, width: 2),
        boxShadow: AppColors.shadowSm,
      ),
      alignment: Alignment.center,
      child: Text(vibe.emoji, style: TextStyle(fontSize: size * 0.46)),
    );
  }
}

/// Mono geri sayım pill'i — 2 saatlik pencere; 30dk altı amber, 10dk altı danger.
class CountdownPill extends StatelessWidget {
  final int minutesLeft;
  const CountdownPill({super.key, required this.minutesLeft});

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.coral50, fg = AppColors.brandHover, dot = AppColors.brand;
    if (minutesLeft <= 10) {
      bg = const Color(0xFFFDECEC);
      fg = AppColors.danger;
      dot = AppColors.danger;
    } else if (minutesLeft <= 30) {
      bg = const Color(0xFFFEF4E3);
      fg = const Color(0xFFB57208);
      dot = AppColors.warning;
    }
    final h = minutesLeft ~/ 60;
    final m = minutesLeft % 60;
    final label = h > 0 ? '${h}h ${m.toString().padLeft(2, '0')}m' : '${m}m';

    return Container(
      padding: const EdgeInsets.fromLTRB(9, 5, 11, 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(AppL10n.of(context).timeLeft(label), style: AppText.mono(12, color: fg)),
      ]),
    );
  }
}

enum BadgeTone { success, coral, neutral, warning, danger }

class FlockBadge extends StatelessWidget {
  final String label;
  final String? icon;
  final BadgeTone tone;
  const FlockBadge(this.label, {super.key, this.icon, this.tone = BadgeTone.neutral});

  @override
  Widget build(BuildContext context) {
    late Color bg, fg;
    switch (tone) {
      case BadgeTone.success:
        bg = AppColors.successSoft;
        fg = AppColors.success;
        break;
      case BadgeTone.coral:
        bg = AppColors.coral50;
        fg = AppColors.brandHover;
        break;
      case BadgeTone.warning:
        bg = const Color(0xFFFEF4E3);
        fg = const Color(0xFFB57208);
        break;
      case BadgeTone.danger:
        bg = const Color(0xFFFDECEC);
        fg = AppColors.danger;
        break;
      case BadgeTone.neutral:
        bg = AppColors.surfaceSunken;
        fg = AppColors.textMuted;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Text(icon!, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700)), const SizedBox(width: 4)],
        Text(label, style: AppText.body(12, weight: FontWeight.w700, color: fg)),
      ]),
    );
  }
}

class VerifiedBadge extends StatelessWidget {
  final String? label;
  const VerifiedBadge({super.key, this.label});
  @override
  Widget build(BuildContext context) =>
      FlockBadge(label ?? AppL10n.of(context).verified, icon: '✓', tone: BadgeTone.success);
}

/// Baş harfli renkli avatar.
class FlockAvatar extends StatelessWidget {
  final String name;
  final double size;
  const FlockAvatar({super.key, required this.name, this.size = 36});

  static const _palette = [
    AppColors.coral400, AppColors.trust500, AppColors.sky500,
    AppColors.vibeGames, AppColors.vibeFood, AppColors.vibeBar,
  ];

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(' ');
    final initials = parts.map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();
    final hue = _palette[name.codeUnitAt(0) % _palette.length];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: hue,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surfaceCard, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(initials, style: AppText.body(size * 0.38, weight: FontWeight.w700, color: Colors.white)),
    );
  }
}

/// Üst üste binen avatar yığını + "x/y joined" sayacı.
class AvatarStack extends StatelessWidget {
  final List<Person> people;
  final int total;
  final double size;
  const AvatarStack({super.key, required this.people, required this.total, this.size = 30});

  @override
  Widget build(BuildContext context) {
    final shown = people.take(4).toList();
    final overlap = size * 0.34;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(
        height: size,
        width: shown.isEmpty ? 0 : size + (shown.length - 1) * (size - overlap),
        child: Stack(
          children: [
            for (var i = 0; i < shown.length; i++)
              Positioned(left: i * (size - overlap), child: FlockAvatar(name: shown[i].name, size: size)),
          ],
        ),
      ),
      const SizedBox(width: 10),
      Text(AppL10n.of(context).joinedCount(people.length, total),
          style: AppText.body(13, weight: FontWeight.w700, color: AppColors.textMuted)),
    ]);
  }
}

enum FlockBtn { primary, secondary, soft, danger }

class FlockButton extends StatelessWidget {
  final String label;
  final FlockBtn variant;
  final bool full;
  final IconData? leadingIcon;
  final VoidCallback? onPressed;
  final EdgeInsets padding;
  const FlockButton({
    super.key,
    required this.label,
    this.variant = FlockBtn.primary,
    this.full = false,
    this.leadingIcon,
    this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
  });

  @override
  Widget build(BuildContext context) {
    late Color bg, fg;
    Border? border;
    List<BoxShadow>? shadow;
    switch (variant) {
      case FlockBtn.primary:
        bg = AppColors.brand;
        fg = Colors.white;
        shadow = AppColors.glowCoral;
        break;
      case FlockBtn.secondary:
        bg = AppColors.surfaceCard;
        fg = AppColors.textStrong;
        border = Border.all(color: AppColors.borderStrong);
        break;
      case FlockBtn.soft:
        bg = AppColors.coral50;
        fg = AppColors.brandHover;
        break;
      case FlockBtn.danger:
        bg = AppColors.danger;
        fg = Colors.white;
        shadow = AppColors.glowDanger;
        break;
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            border: border,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            boxShadow: shadow,
          ),
          child: Container(
            width: full ? double.infinity : null,
            padding: padding,
            alignment: Alignment.center,
            child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
              if (leadingIcon != null) ...[Icon(leadingIcon, size: 18, color: fg), const SizedBox(width: 8)],
              Text(label, style: AppText.body(15, weight: FontWeight.w700, color: fg)),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Feed'in kahramanı — oluşmakta olan tek bir flock kartı.
class InviteCard extends StatelessWidget {
  final Flock flock;
  final bool joined;
  final String? distance; // "1.2 km" — konumdan uzaklık (varsa)
  final VoidCallback? onJoin;
  final VoidCallback? onTap;
  const InviteCard({super.key, required this.flock, this.joined = false, this.distance, this.onJoin, this.onTap});

  @override
  Widget build(BuildContext context) {
    final v = flock.vibe;
    final t = AppL10n.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: AppColors.shadowCard,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            VibeDot(vibe: v, size: 46),
            const SizedBox(width: 13),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 7, children: [
                  Text(vibeLabel(t, flock.vibeId), style: AppText.display(17, color: AppColors.textStrong)),
                  Text('·', style: AppText.body(13, color: AppColors.textFaint)),
                  Text(flock.venue, style: AppText.body(14, weight: FontWeight.w600)),
                ]),
                const SizedBox(height: 3),
                Row(children: [
                  if (distance != null) ...[
                    Text('📍 $distance',
                        style: AppText.body(12.5, weight: FontWeight.w700, color: AppColors.brand)),
                    Text(' · ', style: AppText.body(12.5, color: AppColors.textFaint)),
                  ],
                  Flexible(
                    child: Text(
                        flock.area.isEmpty
                            ? t.isHosting(flock.host)
                            : '${flock.area} · ${t.isHosting(flock.host)}',
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body(12.5, color: AppColors.textMuted)),
                  ),
                  if (flock.verifiedHost) ...[
                    const SizedBox(width: 4),
                    Text('✓', style: AppText.body(12.5, weight: FontWeight.w700, color: AppColors.success)),
                  ],
                ]),
              ]),
            ),
            const SizedBox(width: 8),
            CountdownPill(minutesLeft: flock.minutesLeft),
          ]),
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            AvatarStack(people: flock.members, total: flock.total),
            if (joined)
              FlockBadge(t.joinedBadge, tone: BadgeTone.coral)
            else if (flock.full)
              FlockBadge(t.flockFull, tone: BadgeTone.neutral)
            else
              FlockButton(
                label: t.join,
                onPressed: onJoin,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
          ]),
        ]),
      ),
    );
  }
}
