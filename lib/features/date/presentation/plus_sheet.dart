import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/flock_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../premium/data/premium_service.dart';
import '../../profile/data/user_profile_repository.dart';
import '../data/discovery_repository.dart';
import '../data/likes_repository.dart';

/// Flock+ paneli — Date destesindeki kalbe basılı tutunca açılır.
///
/// İçerik SAHİCİ tutulur: burada yalnızca gerçekten çalışan şey var
/// ("seni beğenenler" + abonelik durumu). Mesajlaşma uygulamada henüz yok;
/// boş bir "Mesajlar" sekmesi koymak kullanıcıya olmayan bir şey vaat eder.
class PlusSheet extends StatelessWidget {
  final String uid;
  const PlusSheet({super.key, required this.uid});

  static Future<void> show(BuildContext context, String uid) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlusSheet(uid: uid),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scroll) => DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.bgPage,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          // Tutamak — sayfanın sürüklenebildiğini söyler.
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              controller: scroll,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              children: [
                Text(t.plusTitle, style: AppText.display(28)),
                const SizedBox(height: 2),
                Text(t.plusSheetLede,
                    style: AppText.body(14, color: AppColors.textMuted)),
                const SizedBox(height: 20),
                _AdmirersSection(uid: uid),
                const SizedBox(height: 24),
                _StatusSection(uid: uid),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

/// Seni beğenenler — panelin asıl içeriği.
class _AdmirersSection extends StatefulWidget {
  final String uid;
  const _AdmirersSection({required this.uid});
  @override
  State<_AdmirersSection> createState() => _AdmirersSectionState();
}

class _AdmirersSectionState extends State<_AdmirersSection> {
  List<Admirer>? _rows;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final rows = await LikesRepository.instance.incoming(widget.uid);
      if (mounted) setState(() => _rows = rows);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    final rows = _rows;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
            child: Text(t.plusAdmirersTitle, style: AppText.display(19))),
        if (rows != null && rows.isNotEmpty)
          Text('${rows.length}',
              style: AppText.body(14,
                  weight: FontWeight.w800, color: AppColors.brand)),
      ]),
      const SizedBox(height: 10),
      if (_error != null)
        _note(t.plusAdmirersError)
      else if (rows == null)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child:
              Center(child: CircularProgressIndicator(color: AppColors.brand)),
        )
      else if (rows.isEmpty)
        _note(t.plusAdmirersEmpty)
      else
        for (final a in rows) ...[
          _AdmirerRow(meUid: widget.uid, admirer: a),
          const SizedBox(height: 8),
        ],
    ]);
  }

  Widget _note(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Text(text,
            style: AppText.body(13.5, color: AppColors.textMuted)),
      );
}

class _AdmirerRow extends StatefulWidget {
  final String meUid;
  final Admirer admirer;
  const _AdmirerRow({required this.meUid, required this.admirer});
  @override
  State<_AdmirerRow> createState() => _AdmirerRowState();
}

class _AdmirerRowState extends State<_AdmirerRow> {
  late bool _mutual = widget.admirer.mutual;
  bool _busy = false;

  Future<void> _likeBack() async {
    if (_busy) return;
    setState(() => _busy = true);
    await DiscoveryRepository.instance.like(widget.meUid, widget.admirer.uid);
    if (mounted) {
      setState(() {
        _mutual = true;
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    final a = widget.admirer;
    return InkSurface(
      color: AppColors.surfaceCard,
      radius: AppRadius.md,
      borderColor: _mutual ? AppColors.brandSoftStrong : AppColors.borderSubtle,
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        FutureBuilder<String?>(
          initialData: UserProfileRepository.instance.cachedPhoto(a.uid),
          future: UserProfileRepository.instance.fetchPhotoB64(a.uid),
          builder: (_, snap) =>
              FlockAvatar(name: a.name, size: 46, photoB64: snap.data),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(a.age > 0 ? '${a.name}, ${a.age}' : a.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.body(14.5,
                    weight: FontWeight.w700, color: AppColors.textStrong)),
            const SizedBox(height: 2),
            Text(_mutual ? t.plusMutualHint : t.plusLikedYouHint,
                maxLines: 2,
                style: AppText.body(12, color: AppColors.textMuted)),
          ]),
        ),
        const SizedBox(width: 8),
        if (_mutual)
          FlockBadge(t.plusMutualBadge, icon: '💞', tone: BadgeTone.coral)
        else
          FlockButton(
            label: t.plusLikeBack,
            variant: FlockBtn.soft,
            onPressed: _busy ? null : _likeBack,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          ),
      ]),
    );
  }
}

/// Abonelik durumu — panelin ikinci yarısı.
class _StatusSection extends StatelessWidget {
  final String uid;
  const _StatusSection({required this.uid});

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    return ValueListenableBuilder<PremiumState>(
      valueListenable: PremiumService.instance.state,
      builder: (context, plus, _) {
        final days = plus.trialDaysLeft;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t.plusStatusTitle, style: AppText.display(19)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.brandSoft,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.brandSoftStrong),
            ),
            child: Row(children: [
              Icon(Icons.workspace_premium_rounded,
                  size: 22, color: AppColors.brandHover),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  days != null ? t.plusTrialActiveTitle(days) : t.plusActiveTitle,
                  style: AppText.body(14,
                      weight: FontWeight.w700, color: AppColors.brandHover),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 10),
          Text(t.plusMessagesSoon,
              style: AppText.body(12.5, color: AppColors.textFaint)),
        ]);
      },
    );
  }
}
