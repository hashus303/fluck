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

class _DateDeckState extends State<DateDeck>
    with SingleTickerProviderStateMixin {
  List<DiscoveryPerson>? _people;
  int _index = 0;
  Object? _error;

  /// Kartın sürüklenme miktarı — hem görsel geri bildirim hem karar eşiği.
  double _dragX = 0;

  /// Kararın verildiği eşik (px). Altında kart yerine döner.
  static const _threshold = 90.0;

  /// Bırakma anının tek yetkili hareketi: kart ya yerine yaslanır ya da
  /// ekrandan savrulur. Parmağı kaldırınca kartın ZIPLAMASI destenin
  /// fiziksel hissini bozuyordu.
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  Animation<double>? _slide;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  /// [_dragX]'i hedefe yumuşatarak taşır. Eğri exponential ease-out: hareket
  /// hızlı başlar, yavaşça oturur.
  void _animateTo(double target, {VoidCallback? onDone}) {
    _slide = Tween<double>(begin: _dragX, end: target).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic),
    )..addListener(() {
        if (mounted) setState(() => _dragX = _slide!.value);
      });
    _anim.forward(from: 0).whenComplete(() {
      if (onDone != null) onDone();
    });
  }

  /// Kartı ekran dışına savurur, sonra kararı uygular.
  void _fling(bool liked) {
    if (_anim.isAnimating) return;
    final w = MediaQuery.sizeOf(context).width;
    _animateTo(liked ? w * 1.15 : -w * 1.15, onDone: () => _decide(liked));
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
      if (mounted) {
        setState(() => _people = people);
        _prefetchAhead();
      }
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  DiscoveryPerson? get _current {
    final list = _people;
    if (list == null || _index >= list.length) return null;
    return list[_index];
  }

  /// Arkada duran kart — üstteki kayarken altından o görünür.
  DiscoveryPerson? get _next {
    final list = _people;
    if (list == null || _index + 1 >= list.length) return null;
    return list[_index + 1];
  }

  /// Karar İYİMSER uygulanır: kart ANINDA geçer, yazma arkada sürer.
  ///
  /// Eskiden Firestore turları bitene kadar bekleniyordu — beğeni üç tur
  /// (swipes yaz, likes yaz, karşılığını oku) yani ~450 ms boş bekleme.
  /// Kaydırma jestinde bu doğrudan hissedilir. Yazma başarısız olursa
  /// kaybedilen tek şey bir kaydırma; Firestore çevrimdışı yazmaları zaten
  /// kuyruğa alır.
  void _decide(bool liked) {
    final person = _current;
    if (person == null) return;
    setState(() {
      _index++;
      _dragX = 0; // yeni kart ortada başlasın
    });
    _prefetchAhead();

    if (liked) {
      DiscoveryRepository.instance.like(widget.uid, person.uid).then((mutual) {
        if (mutual && mounted) _showMutual(person);
      });
    } else {
      DiscoveryRepository.instance.pass(widget.uid, person.uid);
    }
  }

  /// Sıradaki birkaç kartın fotoğrafını önden çeker.
  ///
  /// Fotoğraf ayrı belgede olduğu için kart göründüğü anda istek atılıyordu;
  /// bu da kartın önce boş gelip sonra dolmasına yol açıyor. Depo uid'e göre
  /// önbelleklediği için önden çekmek kartı hazır bulur.
  void _prefetchAhead() {
    final list = _people;
    if (list == null) return;
    for (var i = _index; i < _index + 3 && i < list.length; i++) {
      UserProfileRepository.instance.fetchPhotoB64(list[i].uid);
    }
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
      return Center(child: CircularProgressIndicator(color: AppColors.brand));
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

    final intent = (_dragX / 120).clamp(-1.0, 1.0);

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
          Expanded(
            child: Stack(children: [
              // Arkadaki kart: üstteki kayarken deste hissi versin ve sıradaki
              // kişinin geldiği belli olsun.
              if (_next != null)
                Positioned.fill(
                  child: Transform.scale(
                    scale: 0.94 + 0.06 * intent.abs(),
                    child: Opacity(
                      opacity: 0.55 + 0.45 * intent.abs(),
                      child: _CardFace(person: _next!, intent: 0),
                    ),
                  ),
                ),
              Positioned.fill(
                child: GestureDetector(
                  onHorizontalDragUpdate: (d) =>
                      setState(() => _dragX += d.delta.dx),
                  onHorizontalDragEnd: (_) {
                    if (_dragX.abs() > _threshold) {
                      _fling(_dragX > 0);
                    } else {
                      _animateTo(0);
                    }
                  },
                  child: Transform.translate(
                    offset: Offset(_dragX, 0),
                    child: Transform.rotate(
                      angle: intent * 0.08,
                      child: _CardFace(person: person, intent: intent),
                    ),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          _actions(),
          // Jest ipucu YALNIZCA ilk kartta: kaydırma keşfedilebilir kalsın,
          // sonra ekranı boşuna işgal etmesin.
          if (_index == 0) ...[
            const SizedBox(height: 10),
            Text(t.dateSwipeHint,
                style: AppText.body(12, color: AppColors.textFaint)),
          ],
        ]),
      ),
    );
  }

  Widget _actions() {
    final t = AppL10n.of(context);
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _RoundAction(
        icon: Icons.close_rounded,
        label: t.datePass,
        color: AppColors.danger,
        onTap: () => _fling(false),
      ),
      const SizedBox(width: 28),
      _RoundAction(
        icon: Icons.favorite_rounded,
        label: t.dateLike,
        color: AppColors.brand,
        filled: true,
        onTap: () => _fling(true),
      ),
    ]);
  }
}

/// Kartın yüzü: FOTOĞRAF kartın kendisidir.
///
/// Önceki hâlde 140 px'lik bir daire kartın üstünde duruyor, altında büyük bir
/// boşluk kalıyordu — kart, kendi türünün en güçlü hamlesinden kaçınmıştı.
/// Bilgi fotoğrafın üstündeki perdeye oturur; rozetler sistemin kendi
/// [VerifiedBadge] / [FlockBadge] parçalarıdır, bu ekrana özel bir şey icat
/// edilmedi.
class _CardFace extends StatelessWidget {
  final DiscoveryPerson person;

  /// -1 (sola/geç) … +1 (sağa/beğen). Sürükleme geri bildirimi buradan.
  final double intent;

  const _CardFace({required this.person, required this.intent});

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    final radius = BorderRadius.circular(AppRadius.card);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: AppColors.shadowCard,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(fit: StackFit.expand, children: [
          _photo(),
          // Perde: fotoğraf ne olursa olsun yazı okunur kalsın. Dekorasyon
          // değil okunabilirlik aracı — o yüzden yalnızca alt yarıda.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [Color(0x00000000), Color(0xD9000000)],
              ),
            ),
          ),
          Positioned(left: 20, right: 20, bottom: 20, child: _info(t)),
          if (intent != 0) _stamp(t),
        ]),
      ),
    );
  }

  /// Fotoğraf yoksa kart kişinin sabit rengiyle dolar ve baş harfleri taşır —
  /// boşlukta duran bir daire yerine yine dolu bir yüzey.
  Widget _photo() {
    return FutureBuilder<String?>(
      initialData: UserProfileRepository.instance.cachedPhoto(person.uid),
      future: UserProfileRepository.instance.fetchPhotoB64(person.uid),
      builder: (context, snap) {
        final image = AvatarImageCache.of(snap.data);
        if (image == null) {
          final initials = person.name
              .trim()
              .split(' ')
              .map((w) => w.isNotEmpty ? w[0] : '')
              .take(2)
              .join()
              .toUpperCase();
          return ColoredBox(
            color: FlockAvatar.hueFor(person.name),
            child: Center(
              child:
                  Text(initials, style: AppText.display(88, color: Colors.white)),
            ),
          );
        }
        return Image(image: image, fit: BoxFit.cover);
      },
    );
  }

  Widget _info(AppL10n t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          person.age > 0 ? '${person.name}, ${person.age}' : person.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          // Perde her iki şemada da koyu; yazı sıcak kırık beyaz — nötr gri
          // değil, sistemin koyu şema metin rampasından.
          style: AppText.display(30, color: AppColors.sand50),
        ),
        const SizedBox(height: 10),
        Wrap(spacing: 7, runSpacing: 7, children: [
          const VerifiedBadge(),
          if (person.km != null)
            FlockBadge(_km(t, person.km!), icon: '📍', tone: BadgeTone.coral),
          // İki tane: doğrulama ve mesafe kartın taşıdığı asıl bilgi,
          // ilgi alanları onları bastırmasın.
          for (final i in person.interests.take(2)) FlockBadge(i),
        ]),
      ],
    );
  }

  /// Mesafeyi kaba konumla tutarlı göster: 1 km altı "1 km'den yakın".
  String _km(AppL10n t, double v) =>
      v < 1 ? t.dateUnder1Km : '${v.toStringAsFixed(v < 10 ? 1 : 0)} km';

  /// Sürükleme damgası — kararın ne olacağını jest tamamlanmadan söyler.
  /// Türün imza hareketi; kartın tek yetkili anı burası.
  Widget _stamp(AppL10n t) {
    final liked = intent > 0;
    final color = liked ? AppColors.success : AppColors.danger;
    return Positioned(
      top: 24,
      left: liked ? 24 : null,
      right: liked ? null : 24,
      child: Opacity(
        // Eşiğe varmadan okunur olsun: kullanıcı kararı görsün, sonra bıraksın.
        opacity: (intent.abs() * 1.8).clamp(0.0, 1.0),
        child: Transform.rotate(
          angle: liked ? -0.22 : 0.22,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 3),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              color: Colors.black.withValues(alpha: 0.35),
            ),
            child: Text(
              (liked ? t.dateLike : t.datePass).toUpperCase(),
              style: AppText.display(20, color: color),
            ),
          ),
        ),
      ),
    );
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
            child:
                Icon(icon, size: 28, color: filled ? AppColors.onBrand : color),
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
