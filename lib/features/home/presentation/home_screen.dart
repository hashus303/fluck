import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/flock.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/geo.dart';
import '../../../core/services/location_controller.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/flock_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_repository.dart';
import '../../flock/data/flock_doc.dart';
import '../../flock/data/flock_repository.dart';
import '../../flock/data/rating_repository.dart';
import '../../notifications/data/notification_repository.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../profile/data/user_profile_repository.dart';
import '../../safety/data/moderation_repository.dart';

class HomeScreen extends StatefulWidget {
  final void Function(Flock)? onOpenInvite;
  const HomeScreen({super.key, this.onOpenInvite});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _filter = 'all';
  double? _radiusKm = 25; // null = her yer
  String? _busyJoinId; // katılma işlemi süren flock

  String? _myUid;
  String _myName = '';

  static const _radiusOptions = <double?>[10, 25, 100, null];

  bool get _live => FirebaseService.instance.isInitialized && _myUid != null;

  /// Puanlama istemi bekleyen (yeni bitmiş, henüz puanlanmamış) flock'lar.
  List<FlockDoc> _toRate = [];
  Set<String> _ratePromptDismissed = {};

  @override
  void initState() {
    super.initState();
    if (FirebaseService.instance.isInitialized) {
      _myUid = AuthRepository.instance.currentUser?.uid;
      if (_myUid != null) {
        UserProfileRepository.instance.fetch(_myUid!).then((p) {
          if (mounted && p != null) setState(() => _myName = p.name);
        }).catchError((_) {/* profil yüklenemedi — sessiz geç */});
        _loadRatePrompts();
        // Engel listesi: feed filtresi için yükle ve değişimini izle.
        ModerationRepository.instance.loadBlocks(_myUid!);
        ModerationRepository.instance.blocked.addListener(_onBlockedChanged);
      }
    }
  }

  void _onBlockedChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    ModerationRepository.instance.blocked.removeListener(_onBlockedChanged);
    super.dispose();
  }

  Future<void> _loadRatePrompts() async {
    try {
      final p = await SharedPreferences.getInstance();
      _ratePromptDismissed =
          (p.getStringList('rate_prompt_dismissed') ?? const []).toSet();
      final expired = await FlockRepository.instance.recentlyExpiredMine(_myUid!);
      final candidates = <FlockDoc>[];
      for (final f in expired) {
        if (_ratePromptDismissed.contains(f.id)) continue;
        if (f.memberUids.length < 2) continue; // puanlanacak başka üye yok
        final rated =
            await RatingRepository.instance.ratedUidsInFlock(f.id, _myUid!);
        final unrated =
            f.memberUids.where((u) => u != _myUid && !rated.contains(u));
        if (unrated.isEmpty) {
          _dismissRatePrompt(f.id, persistOnly: true); // hepsi puanlanmış
          continue;
        }
        candidates.add(f);
      }
      if (mounted && candidates.isNotEmpty) setState(() => _toRate = candidates);
    } catch (_) {/* index/ağ hazır değilse istem gösterme */}
  }

  Future<void> _dismissRatePrompt(String flockId, {bool persistOnly = false}) async {
    _ratePromptDismissed.add(flockId);
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList('rate_prompt_dismissed', _ratePromptDismissed.toList());
    } catch (_) {}
    if (!persistOnly && mounted) {
      setState(() => _toRate.removeWhere((f) => f.id == flockId));
    }
  }

  /// Alt sayfa: bitmiş flock'un üyelerine yıldız ver. Yıldızlar sayfa
  /// kapanırken topluca gönderilir (kapanana kadar fikir değiştirilebilir).
  Future<void> _openRateSheet(FlockDoc doc) async {
    final t = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final given = <String, int>{};
    final others = doc.memberUids.where((u) => u != _myUid).toList();
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.ratePromptTitle, style: AppText.display(22)),
              const SizedBox(height: 4),
              Text(doc.venue,
                  style: AppText.body(14, color: AppColors.textMuted)),
              const SizedBox(height: 16),
              for (final uid in others) ...[
                Row(children: [
                  FutureBuilder<String?>(
                    future: UserProfileRepository.instance.fetchPhotoB64(uid),
                    builder: (_, s) => FlockAvatar(
                        name: doc.memberNames[uid] ?? '',
                        size: 40,
                        photoB64: s.data),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(doc.memberNames[uid] ?? '',
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: AppText.body(14.5, weight: FontWeight.w700))),
                  for (var s = 1; s <= 5; s++)
                    GestureDetector(
                      onTap: () => setSheet(() => given[uid] = s),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1.5),
                        child: Icon(
                            s <= (given[uid] ?? 0)
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            size: 26, color: AppColors.warning),
                      ),
                    ),
                ]),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 6),
              FlockButton(
                label: t.rateDone,
                full: true,
                onPressed: () => Navigator.pop(ctx),
              ),
            ]),
          ),
        ),
      ),
    );
    if (given.isEmpty) return; // hiç yıldız verilmedi — istem kalsın
    var saved = 0;
    for (final e in given.entries) {
      try {
        await RatingRepository.instance.rate(
            flockId: doc.id, raterUid: _myUid!, ratedUid: e.key, stars: e.value);
        saved++;
      } catch (_) {/* daha önce puanlanmış (değiştirilemez) — atla */}
    }
    _dismissRatePrompt(doc.id);
    if (saved > 0) {
      messenger.showSnackBar(SnackBar(content: Text(t.rateThanks)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = LocationScope.of(context);

    if (_live) {
      return StreamBuilder<List<FlockDoc>>(
        stream: FlockRepository.instance.watchActive(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppColors.brand));
          }
          // Engellenen kullanıcıların (host ya da üye) flock'ları gizlenir.
          final docs = (snap.data ?? const <FlockDoc>[])
              .where((d) => !ModerationRepository.instance
                  .hidesFlock(d.hostUid, d.memberUids))
              .toList();
          final flocks = docs.map((d) => d.toFlock()).toList();
          return _feed(loc, flocks, joinedIds: {
            for (final d in docs)
              if (d.memberUids.contains(_myUid)) d.id,
          });
        },
      );
    }

    // Firebase yoksa örnek veriyle çalış (çevrimdışı mod).
    return _feed(loc, kFlocks, joinedIds: const {});
  }

  Widget _feed(LocationController loc, List<Flock> source, {required Set<String> joinedIds}) {
    final t = AppL10n.of(context);

    final ranked = source
        .map((f) => (flock: f, km: haversineKm(loc.point, f.point)))
        .where((e) => _filter == 'all' || e.flock.vibeId == _filter)
        .where((e) => _radiusKm == null || e.km <= _radiusKm!)
        .toList()
      ..sort((a, b) => a.km.compareTo(b.km));

    return SafeArea(
      bottom: false,
      child: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 7, height: 7, decoration: const BoxDecoration(
                    color: AppColors.success, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(t.flocksLiveNearYou(ranked.length),
                    style: AppText.body(13, weight: FontWeight.w700, color: AppColors.success)),
                const Spacer(),
                if (_live) _bell(),
              ]),
              const SizedBox(height: 6),
              Text(t.findYourFlock, style: AppText.display(30)),
              const SizedBox(height: 3),
              Text(t.homeSubtitle, style: AppText.body(14, color: AppColors.textMuted)),
            ]),
          ),
        ),
        // Konum + GPS butonu
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Row(children: [
              const Icon(Icons.location_on_rounded, size: 18, color: AppColors.brand),
              const SizedBox(width: 5),
              Text(loc.labelResolved ? loc.label : (loc.isGps ? t.locMyLocation : loc.label),
                  style: AppText.body(14, weight: FontWeight.w800, color: AppColors.textStrong)),
              const Spacer(),
              GestureDetector(
                onTap: loc.locating ? null : () => _useGps(loc),
                child: Row(children: [
                  loc.locating
                      ? const SizedBox(width: 14, height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brand))
                      : const Icon(Icons.my_location, size: 16, color: AppColors.brand),
                  const SizedBox(width: 5),
                  Text(t.locUseGps,
                      style: AppText.body(12.5, weight: FontWeight.w700, color: AppColors.brand)),
                ]),
              ),
            ]),
          ),
        ),
        // Yeni bitmiş flock için puanlama istemi
        if (_toRate.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
                decoration: BoxDecoration(
                  color: AppColors.coral50,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(children: [
                  const Text('🌟', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(t.ratePromptTitle,
                          style: AppText.body(14,
                              weight: FontWeight.w800,
                              color: AppColors.textStrong)),
                      Text(t.ratePromptBody(_toRate.first.venue),
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: AppText.body(12.5, color: AppColors.textMuted)),
                    ]),
                  ),
                  TextButton(
                    onPressed: () => _openRateSheet(_toRate.first),
                    child: Text(t.rateAction,
                        style: AppText.body(13.5,
                            weight: FontWeight.w800, color: AppColors.brand)),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _dismissRatePrompt(_toRate.first.id),
                    icon: const Icon(Icons.close,
                        size: 18, color: AppColors.textFaint),
                  ),
                ]),
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
            child: Row(children: [
              for (final r in _radiusOptions) ...[
                _RadiusChip(
                  label: r == null ? t.locAnywhere : t.locWithin(r.round()),
                  selected: _radiusKm == r,
                  onTap: () => setState(() => _radiusKm = r),
                ),
                const SizedBox(width: 8),
              ],
            ]),
          ),
        ),
        SliverToBoxAdapter(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
            child: Row(children: [
              _AllChip(label: t.allVibes, selected: _filter == 'all', onTap: () => setState(() => _filter = 'all')),
              const SizedBox(width: 8),
              for (final v in kVibes) ...[
                _VibeChip(
                  vibe: v,
                  label: vibeLabel(t, v.id),
                  selected: _filter == v.id,
                  onTap: () => setState(() => _filter = _filter == v.id ? 'all' : v.id),
                ),
                const SizedBox(width: 8),
              ],
            ]),
          ),
        ),
        // Şansına bırak — filtredeki rastgele bir flock'u önüne atar.
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
            child: _SurpriseButton(
              label: t.surpriseMe,
              onTap: () => _surprise(ranked, joinedIds),
            ),
          ),
        ),
        if (ranked.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
              child: Center(
                child: Text(t.locNoneInRange,
                    textAlign: TextAlign.center,
                    style: AppText.body(14, color: AppColors.textMuted)),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverList.separated(
              itemCount: ranked.length,
              separatorBuilder: (_, i) => const SizedBox(height: 14),
              itemBuilder: (_, i) {
                final e = ranked[i];
                final joined = joinedIds.contains(e.flock.id);
                return InviteCard(
                  flock: e.flock,
                  distance: distanceLabel(e.km),
                  joined: joined,
                  onJoin: _busyJoinId == e.flock.id ? null : () => _join(e.flock),
                  onTap: () => widget.onOpenInvite?.call(e.flock),
                );
              },
            ),
          ),
      ]),
    );
  }

  Widget _bell() {
    return StreamBuilder<int>(
      stream: NotificationRepository.instance.unreadCount(_myUid!),
      builder: (context, snap) {
        final n = snap.data ?? 0;
        return GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => NotificationsScreen(uid: _myUid!),
          )),
          child: Stack(clipBehavior: Clip.none, children: [
            const Icon(Icons.notifications_none_rounded, size: 26, color: AppColors.textStrong),
            if (n > 0)
              Positioned(
                right: -3, top: -3,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  decoration: const BoxDecoration(color: AppColors.brand, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(n > 9 ? '9+' : '$n',
                      style: AppText.body(10, weight: FontWeight.w800, color: Colors.white)),
                ),
              ),
          ]),
        );
      },
    );
  }

  /// Zar at: katılabileceğin (üye olmadığın, dolu olmayan) flock'lardan
  /// rastgele birini alt sayfada gösterir — spontane katılımın kestirmesi.
  void _surprise(List<({Flock flock, double km})> ranked, Set<String> joinedIds) {
    final t = AppL10n.of(context);
    final pool = ranked
        .where((e) => !joinedIds.contains(e.flock.id) && !e.flock.full)
        .toList();
    if (pool.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.surpriseNone)));
      return;
    }
    final rnd = Random();
    var pick = pool[rnd.nextInt(pool.length)];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheet) => Container(
          decoration: const BoxDecoration(
            color: AppColors.bgPage,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderStrong,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(children: [
              const Text('🎲', style: TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t.surpriseTitle, style: AppText.display(20)),
                  Text(t.surpriseSubtitle, style: AppText.body(13, color: AppColors.textMuted)),
                ]),
              ),
            ]),
            const SizedBox(height: 14),
            InviteCard(
              flock: pick.flock,
              distance: distanceLabel(pick.km),
              onJoin: () {
                Navigator.pop(sheetCtx);
                _join(pick.flock);
              },
              onTap: () {
                Navigator.pop(sheetCtx);
                widget.onOpenInvite?.call(pick.flock);
              },
            ),
            const SizedBox(height: 12),
            FlockButton(
              label: t.spinAgain,
              variant: FlockBtn.soft,
              full: true,
              leadingIcon: Icons.casino_rounded,
              onPressed: pool.length < 2
                  ? null
                  : () => setSheet(() {
                        var next = pick;
                        while (next.flock.id == pick.flock.id) {
                          next = pool[rnd.nextInt(pool.length)];
                        }
                        pick = next;
                      }),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _useGps(LocationController loc) async {
    final err = await loc.useDeviceLocation();
    if (err == LocationError.none || !mounted) return;
    final t = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    switch (err) {
      case LocationError.serviceDisabled:
        messenger.showSnackBar(SnackBar(content: Text(t.locServiceOff)));
      case LocationError.deniedForever:
        messenger.showSnackBar(SnackBar(
          content: Text(t.locPermDeniedForever),
          action: SnackBarAction(
            label: t.locOpenSettings,
            onPressed: () => LocationService.instance.openSettings(),
          ),
        ));
      case LocationError.denied:
        messenger.showSnackBar(SnackBar(content: Text(t.locPermDenied)));
      case LocationError.failed:
      case LocationError.none:
        messenger.showSnackBar(SnackBar(content: Text(t.locGpsFailed)));
    }
  }

  Future<void> _join(Flock flock) async {
    final t = AppL10n.of(context);
    if (!_live) {
      // Çevrimdışı modda yalnızca görsel onay.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.joinedBadge)));
      return;
    }
    setState(() => _busyJoinId = flock.id);
    try {
      await FlockRepository.instance.join(flock.id, _myUid!, _myName.isEmpty ? 'Flocker' : _myName);
    } on FlockJoinException catch (e) {
      if (mounted) {
        final msg = e.code == 'full' ? t.flockFull : t.errGeneric;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.errGeneric)));
      }
    } finally {
      if (mounted) setState(() => _busyJoinId = null);
    }
  }
}

/// Koyu, tam genişlik "zar" butonu — spontane katılımın kahramanı.
class _SurpriseButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SurpriseButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.ink900, Color(0xFF3A3F52)],
          ),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: AppColors.shadowCard,
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('🎲', style: TextStyle(fontSize: 17)),
          const SizedBox(width: 8),
          Text(label, style: AppText.body(14.5, weight: FontWeight.w800, color: Colors.white)),
        ]),
      ),
    );
  }
}

class _RadiusChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _RadiusChip({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink900 : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: selected ? AppColors.ink900 : AppColors.borderSubtle, width: 1.5),
        ),
        child: Text(label,
            style: AppText.body(12.5, weight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.textBody)),
      ),
    );
  }
}

class _AllChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _AllChip({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.brand : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: selected ? AppColors.brand : AppColors.borderSubtle, width: 1.5),
        ),
        child: Text(label,
            style: AppText.body(13, weight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.textBody)),
      ),
    );
  }
}

class _VibeChip extends StatelessWidget {
  final Vibe vibe;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _VibeChip({required this.vibe, required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? vibe.color : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: selected ? vibe.color : AppColors.borderSubtle, width: 1.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(vibe.emoji, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 7),
          Text(label,
              style: AppText.body(13, weight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.textBody)),
        ]),
      ),
    );
  }
}
