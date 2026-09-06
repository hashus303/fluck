import 'package:flutter/material.dart';

import '../../../core/services/location_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/flock_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../profile/data/user_profile_repository.dart';
import '../../safety/data/moderation_repository.dart';
import '../data/discovery_repository.dart';

/// Date destesi — yakındaki doğrulanmış kişiler.
///
/// Ürün çerçevesi (B kararı): burada "eşleşme" yok. Beğendiğin kişiyi
/// FLOCK'UNA davet edersin; buluşma her zaman grupça kalır. Bu yüzden
/// karşılıklı beğenide "eşleştiniz" değil, "sen de beğenmişsin" denir.
class DateDeck extends StatefulWidget {
  final String uid;
  const DateDeck({super.key, required this.uid});

  @override
  State<DateDeck> createState() => _DateDeckState();
}

class _DateDeckState extends State<DateDeck> {
  List<DiscoveryPerson>? _people;
  int _index = 0;
  bool _busy = false;
  Object? _error;

  /// Kartın sürüklenme miktarı — hem görsel geri bildirim hem karar eşiği.
  double _dragX = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _people = null;
      _error = null;
      _index = 0;
    });
    try {
      final loc = LocationScope.of(context);
      final people = await DiscoveryRepository.instance.deck(
        uid: widget.uid,
        me: loc.point,
        blocked: ModerationRepository.instance.blocked.value,
      );
      if (mounted) setState(() => _people = people);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  DiscoveryPerson? get _current {
    final list = _people;
    if (list == null || _index >= list.length) return null;
    return list[_index];
  }

  Future<void> _decide(bool liked) async {
    final person = _current;
    if (person == null || _busy) return;
    setState(() => _busy = true);
    bool mutual = false;
    if (liked) {
      mutual = await DiscoveryRepository.instance.like(widget.uid, person.uid);
    } else {
      await DiscoveryRepository.instance.pass(widget.uid, person.uid);
    }
    if (!mounted) return;
    setState(() {
      _index++;
      _dragX = 0;
      _busy = false;
    });
    if (mutual) _showMutual(person);
  }

  void _showMutual(DiscoveryPerson person) {
    final t = AppL10n.of(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(t.dateMutual(person.name)),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);

    if (_error != null) {
      return _Message(
        emoji: '⚠️',
        title: t.errGeneric,
        body: t.dateDeckRetry,
        actionLabel: t.offlineRetry,
        onAction: _load,
      );
    }
    if (_people == null) {
      return Center(
          child: CircularProgressIndicator(color: AppColors.brand));
    }
    final person = _current;
    if (person == null) {
      return _Message(
        emoji: '🌱',
        title: t.dateEmptyTitle,
        body: t.dateEmptyBody,
        actionLabel: t.dateDeckRefresh,
        onAction: _load,
      );
    }

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Column(children: [
          Row(children: [
            Expanded(child: Text(t.dateTitle, style: AppText.display(26))),
            Text('${_index + 1}/${_people!.length}',
                style: AppText.body(13, color: AppColors.textFaint)),
          ]),
          const SizedBox(height: 14),
          Expanded(child: _card(person)),
          const SizedBox(height: 16),
          _actions(),
        ]),
      ),
    );
  }

  Widget _card(DiscoveryPerson person) {
    final t = AppL10n.of(context);
    // Sürükleme yönüne göre hafif dönüş ve renk ipucu.
    final intent = (_dragX / 120).clamp(-1.0, 1.0);
    return GestureDetector(
      onHorizontalDragUpdate: (d) => setState(() => _dragX += d.delta.dx),
      onHorizontalDragEnd: (_) {
        if (_dragX.abs() > 90) {
          _decide(_dragX > 0);
        } else {
          setState(() => _dragX = 0);
        }
      },
      child: Transform.translate(
        offset: Offset(_dragX, 0),
        child: Transform.rotate(
          angle: intent * 0.08,
          child: InkSurface(
            color: AppColors.surfaceCard,
            borderColor: intent == 0
                ? AppColors.borderSubtle
                : (intent > 0 ? AppColors.success : AppColors.danger),
            borderWidth: intent == 0 ? 1 : 2,
            shadow: AppColors.shadowCard,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  // Fotoğraf ana belgeden ayrıldı: yalnızca GÖRÜNEN kartınki
                  // çekilir. Depo uid'e göre önbelleklediği için geri gelen
                  // kartlar tekrar istek atmaz.
                  child: FutureBuilder<String?>(
                    future: UserProfileRepository.instance
                        .fetchPhotoB64(person.uid),
                    builder: (_, snap) => FlockAvatar(
                        name: person.name, size: 140, photoB64: snap.data),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                    person.age > 0
                        ? '${person.name}, ${person.age}'
                        : person.name,
                    style: AppText.display(24)),
                const SizedBox(height: 6),
                Row(children: [
                  Icon(Icons.verified_rounded,
                      size: 16, color: AppColors.success),
                  const SizedBox(width: 5),
                  Text(t.verified,
                      style: AppText.body(12.5,
                          weight: FontWeight.w700,
                          color: AppColors.success)),
                  if (person.km != null) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.place, size: 15, color: AppColors.textMuted),
                    const SizedBox(width: 3),
                    Text(_km(person.km!),
                        style: AppText.body(12.5, color: AppColors.textMuted)),
                  ],
                ]),
                if (person.interests.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(spacing: 7, runSpacing: 7, children: [
                    for (final i in person.interests.take(6))
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 11, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSunken,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(i,
                            style: AppText.body(12.5,
                                weight: FontWeight.w600,
                                color: AppColors.textBody)),
                      ),
                  ]),
                ],
                const Spacer(),
                Text(t.dateSwipeHint,
                    style: AppText.body(12, color: AppColors.textFaint)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Mesafeyi kaba konumla tutarlı göster: 1 km altı "1 km'den yakın".
  String _km(double v) {
    final t = AppL10n.of(context);
    if (v < 1) return t.dateUnder1Km;
    return '${v.toStringAsFixed(v < 10 ? 1 : 0)} km';
  }

  Widget _actions() {
    final t = AppL10n.of(context);
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _RoundAction(
        icon: Icons.close_rounded,
        label: t.datePass,
        color: AppColors.danger,
        onTap: _busy ? null : () => _decide(false),
      ),
      const SizedBox(width: 28),
      _RoundAction(
        icon: Icons.favorite_rounded,
        label: t.dateLike,
        color: AppColors.brand,
        filled: true,
        onTap: _busy ? null : () => _decide(true),
      ),
    ]);
  }
}

class _RoundAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool filled;
  final VoidCallback? onTap;
  const _RoundAction({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: filled ? color : AppColors.surfaceCard,
        shape: CircleBorder(
            side: BorderSide(color: filled ? color : AppColors.borderStrong)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 64,
            height: 64,
            child: Icon(icon,
                size: 28, color: filled ? AppColors.onBrand : color),
          ),
        ),
      ),
    );
  }
}

/// Boş / hata durumu — her ikisi de bir çıkış yolu sunar.
class _Message extends StatelessWidget {
  final String emoji, title, body, actionLabel;
  final VoidCallback onAction;
  const _Message({
    required this.emoji,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(emoji, style: const TextStyle(fontSize: 44)),
          const SizedBox(height: 18),
          Text(title, textAlign: TextAlign.center, style: AppText.display(22)),
          const SizedBox(height: 8),
          Text(body,
              textAlign: TextAlign.center,
              style: AppText.body(14, color: AppColors.textMuted)),
          const SizedBox(height: 20),
          FlockButton(label: actionLabel, onPressed: onAction),
        ]),
      ),
    );
  }
}
