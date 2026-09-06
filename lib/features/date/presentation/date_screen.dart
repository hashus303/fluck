import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/flock_widgets.dart';
import '../../../l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/services/location_controller.dart';
import '../../premium/data/premium_service.dart';
import '../data/discovery_repository.dart';
import 'date_deck.dart';
import '../../premium/presentation/paywall_screen.dart';

/// Date sekmesi — İNSAN keşfi.
///
/// Bilgi mimarisi: "flock keşfi" Ana Sayfa'nın işi (nabız, zar, vibe, liste
/// hepsi orada). Bu sekme yalnızca insan keşfine bakar, böylece iki sekme
/// birbirini tekrar etmez.
///
/// Flock+ kilitliyken satış ekranı, açıkken deste gösterir.
class DateScreen extends StatelessWidget {
  const DateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PremiumState>(
      valueListenable: PremiumService.instance.state,
      builder: (context, plus, _) =>
          plus.isPlus ? const _DateHome() : const _Locked(),
    );
  }
}

/// Kilitli hâli — Flock+ satışının ana vitrini.
class _Locked extends StatelessWidget {
  const _Locked();

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          Text(t.dateTitle, style: AppText.display(28)),
          const SizedBox(height: 2),
          Text(t.dateLede, style: AppText.body(14, color: AppColors.textMuted)),
          const SizedBox(height: 26),

          // Kilitli kart yığını — arkada ne olduğunu hissettirir.
          const _TeaserStack(),
          const SizedBox(height: 30),

          Text(t.dateLockedTitle,
              textAlign: TextAlign.center, style: AppText.display(22)),
          const SizedBox(height: 8),
          Text(t.dateLockedBody,
              textAlign: TextAlign.center,
              style: AppText.body(14, color: AppColors.textMuted)),
          const SizedBox(height: 22),

          FlockButton(
            label: t.dateUnlockCta,
            full: true,
            onPressed: () =>
                PaywallScreen.show(context, contextTitle: t.dateTitle),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              '${PremiumService.priceLabel} · ${t.plusTrialBadge}',
              style: AppText.body(12, color: AppColors.textFaint),
            ),
          ),
        ],
      ),
    );
  }
}

/// Üst üste binmiş, kilitli kart yığını — destenin görsel vaadi.
class _TeaserStack extends StatelessWidget {
  const _TeaserStack();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Stack(alignment: Alignment.center, children: [
        _card(angle: -0.13, scale: 0.92, opacity: 0.55, dx: -34, dy: 10),
        _card(angle: 0.11, scale: 0.96, opacity: 0.75, dx: 34, dy: 5),
        _card(angle: 0, scale: 1, opacity: 1, locked: true),
      ]),
    );
  }

  Widget _card({
    required double angle,
    required double scale,
    required double opacity,
    double dx = 0,
    double dy = 0,
    bool locked = false,
  }) {
    return Transform.translate(
      offset: Offset(dx, dy),
      child: Transform.rotate(
      angle: angle,
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: 190,
            height: 230,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.brandSoft, AppColors.brandSoftStrong],
              ),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.brandSoftStrong),
              boxShadow: AppColors.shadowCard,
            ),
            alignment: Alignment.center,
            child: locked
                ? Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.lock_rounded,
                        size: 26, color: AppColors.brand),
                  )
                : null,
            ),
          ),
        ),
      ),
    );
  }
}

/// Flock+ üyesinin Date akışı: önce keşfedilebilirlik onayı, sonra deste.
///
/// Onay ZORUNLU çünkü tek yönlü gözlem adil değil — destede birilerine
/// bakıyorsan sen de destede görünürsün. Aynı ekran konumun nasıl saklandığını
/// söylediği için gizlilik rızasının alındığı yer de burası.
class _DateHome extends StatefulWidget {
  const _DateHome();
  @override
  State<_DateHome> createState() => _DateHomeState();
}

class _DateHomeState extends State<_DateHome> {
  String? _uid;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    _uid = uid;
    if (uid != null) await DiscoveryRepository.instance.loadDiscoverable(uid);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _enable() async {
    final uid = _uid;
    if (uid == null) return;
    final point = LocationScope.of(context).point;
    setState(() => _loading = true);
    await DiscoveryRepository.instance.setDiscoverable(uid, true, at: point);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final uid = _uid;
    if (_loading || uid == null) {
      return Center(
          child: CircularProgressIndicator(color: AppColors.brand));
    }
    return ValueListenableBuilder<bool>(
      valueListenable: DiscoveryRepository.instance.discoverable,
      builder: (context, on, _) =>
          on ? DateDeck(uid: uid) : _OptIn(onEnable: _enable),
    );
  }
}

/// Keşfedilebilirlik onayı — hem adalet hem gizlilik rızası.
class _OptIn extends StatelessWidget {
  final VoidCallback onEnable;
  const _OptIn({required this.onEnable});

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          Text(t.dateTitle, style: AppText.display(28)),
          const SizedBox(height: 2),
          Text(t.dateLede, style: AppText.body(14, color: AppColors.textMuted)),
          const SizedBox(height: 26),
          const _TeaserStack(),
          const SizedBox(height: 30),
          Text(t.dateOptInTitle,
              textAlign: TextAlign.center, style: AppText.display(22)),
          const SizedBox(height: 8),
          Text(t.dateOptInBody,
              textAlign: TextAlign.center,
              style: AppText.body(14, color: AppColors.textMuted)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.successSoft,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.lock_outline, size: 17, color: AppColors.success),
              const SizedBox(width: 9),
              Expanded(
                child: Text(t.dateOptInPrivacy,
                    style: AppText.body(12.5, color: AppColors.success)),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          FlockButton(label: t.dateOptInCta, full: true, onPressed: onEnable),
        ],
      ),
    );
  }
}
