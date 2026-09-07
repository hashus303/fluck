import 'dart:convert';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../models/flock.dart';
import '../services/map_config.dart';
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
        color: AppColors.surfaceCard,
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
    Color bg = AppColors.brandSoft, fg = AppColors.brandHover, dot = AppColors.brand;
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

/// OSM tile kullanım politikası gereği zorunlu atıf — harita köşesine konur.
class OsmAttribution extends StatelessWidget {
  const OsmAttribution({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(MapConfig.attribution,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ),
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
        bg = AppColors.brandSoft;
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
/// Dokunulabilir yüzey: gölge DIŞTA, dolgu + kenarlık [Material]'da, dalga
/// [InkWell]'de.
///
/// Sıra önemli — InkWell opak bir Container'ın ÜSTÜNE gelmezse dalga arkada
/// kalır ve hiç görünmez (Flutter'ın klasik tuzağı). Gölge de Material'ın
/// içine konamayacağı için dışarıda ayrı bir katman.
class InkSurface extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final double radius;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? shadow;
  final EdgeInsetsGeometry padding;

  const InkSurface({
    super.key,
    required this.child,
    required this.color,
    this.onTap,
    this.radius = AppRadius.card,
    this.borderColor,
    this.borderWidth = 1,
    this.shadow,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadow,
      ),
      child: Material(
        color: color,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: borderColor == null
              ? BorderSide.none
              : BorderSide(color: borderColor!, width: borderWidth),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Görsel boyutu büyütmeden dokunma hedefini Material'ın 48 dp tabanına
/// çıkarır: çipin çevresine görünmez, dokunuşu yakalayan alan ekler.
///
/// Material'ın kuralı görünen kutuyu değil DOKUNMA HEDEFİNİ 48 dp ister; çipi
/// büyütmek yoğunluğu bozardı (ana sayfada iki çip sırası var). Framework'ün
/// kendi `MaterialTapTargetSize.padded` davranışının aynısı.
class TapTarget extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double minSize;
  const TapTarget({
    super.key,
    required this.child,
    this.onTap,
    this.minSize = 48,
  });

  @override
  Widget build(BuildContext context) {
    // InkWell hem 48 dp'lik alanın tamamını dokunulabilir yapar hem de dalgayı
    // verir; dalga çipin kendisinden bir tık geniş bir hâle olarak çıkar.
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        // Dalga çipten bir tık taşar (hedef 48 dp, çip daha kısa); nötr gri
        // yerine markadan türetilmiş yumuşak bir hâle daha az yabancı durur.
        splashColor: AppColors.brand.withValues(alpha: 0.10),
        highlightColor: AppColors.brand.withValues(alpha: 0.05),
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: minSize, minHeight: minSize),
          child: Center(widthFactor: 1, heightFactor: 1, child: child),
        ),
      ),
    );
  }
}

/// base64 profil fotoğrafları için çözülmüş görsel önbelleği.
///
/// PERF: Eskiden [MemoryImage] doğrudan  içinde kuruluyordu. MemoryImage'ın
/// eşitliği bayt listesinin KİMLİĞİNE baktığından her yeniden çizim yeni bir
/// örnek üretiyor, Flutter'ın görsel önbelleği ıskalıyor ve JPEG yeniden
/// çözülüyordu — üstelik avatarların bulunduğu yer en çok kaydırılan yüzey.
/// Aynı base64 için aynı örneği döndürerek çözümü bir kereye indiriyoruz.
class AvatarImageCache {
  AvatarImageCache._();

  /// Fotoğraflar 320px/q72'ye küçültüldüğü için tanesi ~20 KB; 64 giriş ~1-2 MB.
  static const _maxEntries = 64;
  static final _entries = <String, MemoryImage>{};

  /// Ölçüm için: gerçekten kaç kez çözüldü / kaç kez önbellekten geldi.
  static int decodes = 0;
  static int hits = 0;

  static ImageProvider? of(String? b64) {
    if (b64 == null || b64.isEmpty) return null;
    final cached = _entries[b64];
    if (cached != null) {
      hits++;
      // LRU: erişileni sona taşı ki en eski atılsın.
      _entries.remove(b64);
      _entries[b64] = cached;
      return cached;
    }
    try {
      final image = MemoryImage(base64Decode(b64));
      decodes++;
      if (_entries.length >= _maxEntries) _entries.remove(_entries.keys.first);
      _entries[b64] = image;
      return image;
    } catch (_) {
      return null; // bozuk veri — baş harflere düş
    }
  }
}

class FlockAvatar extends StatelessWidget {
  final String name;
  final double size;
  /// Varsa gerçek profil fotoğrafı (base64 JPEG); yoksa baş harfler.
  final String? photoB64;
  const FlockAvatar({super.key, required this.name, this.size = 36, this.photoB64});

  /// Ada göre sabit renk — aynı kişi her yerde aynı rengi alsın diye
  /// baş harflerle birlikte kart zeminlerinde de kullanılır.
  static Color hueFor(String name) =>
      _palette[(name.isEmpty ? 0 : name.codeUnitAt(0)) % _palette.length];

  static List<Color> get _palette => [
    AppColors.coral400, AppColors.trust500, AppColors.sky500,
    AppColors.vibeGames, AppColors.vibeFood, AppColors.vibeBar,
  ];

  @override
  Widget build(BuildContext context) {
    final image = AvatarImageCache.of(photoB64);
    final parts = name.trim().split(' ');
    final initials = parts.map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();
    final hue = _palette[(name.isEmpty ? 0 : name.codeUnitAt(0)) % _palette.length];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: hue,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surfaceCard, width: 2),
        image: image == null ? null : DecorationImage(image: image, fit: BoxFit.cover),
      ),
      alignment: Alignment.center,
      child: image != null
          ? null
          : Text(initials,
              style: AppText.body(size * 0.38, weight: FontWeight.w700, color: Colors.white)),
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

enum FlockBtn { primary, secondary, soft, danger, dangerSoft }

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
        fg = AppColors.onBrand;
        shadow = AppColors.glowCoral;
        break;
      case FlockBtn.secondary:
        bg = AppColors.surfaceCard;
        fg = AppColors.textStrong;
        border = Border.all(color: AppColors.borderStrong);
        break;
      case FlockBtn.soft:
        bg = AppColors.brandSoft;
        fg = AppColors.brandHover;
        break;
      case FlockBtn.danger:
        bg = AppColors.danger;
        fg = AppColors.onDanger;
        shadow = AppColors.glowDanger;
        break;
      // Yıkıcı ama ASIL eylem olmayan düğme: yanında dolu bir birincil düğme
      // varken kırmızı dolgu onunla yarışıyor. Renk uyarıyı taşımaya devam
      // eder, ağırlık geri çekilir.
      case FlockBtn.dangerSoft:
        bg = AppColors.dangerSoft;
        fg = AppColors.danger;
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
              Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(15, weight: FontWeight.w700, color: fg)),
              ),
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
    return InkSurface(
      onTap: onTap,
      color: AppColors.surfaceCard,
      borderColor: AppColors.borderSubtle,
      shadow: AppColors.shadowCard,
      padding: const EdgeInsets.all(16),
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
    );
  }
}
