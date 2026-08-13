import 'package:flutter/material.dart';

import '../../../core/models/flock.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/geo.dart';
import '../../../core/services/geocoding_service.dart';
import '../../../core/services/location_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/flock_widgets.dart';
import '../../../core/widgets/location_picker.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_repository.dart';
import '../../flock/data/flock_repository.dart';
import '../../profile/data/user_profile_repository.dart';

/// Create — vibe, gerçek mekan (haritadan), grup boyutu ve süre (30dk–2sa) seç.
class InviteScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onPost;
  const InviteScreen({super.key, this.onBack, this.onPost});

  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  String _vibe = 'coffee';
  int _size = 5;
  int _lifetimeMin = 120; // 30 | 60 | 120

  static const _lifetimeOptions = [30, 60, 120];
  final _venueCtrl = TextEditingController();
  bool _posting = false;

  LatLng? _point;
  String _area = '';

  String? _myUid;
  String _myName = '';
  bool _verified = false;

  @override
  void initState() {
    super.initState();
    if (FirebaseService.instance.isInitialized) {
      _myUid = AuthRepository.instance.currentUser?.uid;
      if (_myUid != null) {
        UserProfileRepository.instance.fetch(_myUid!).then((p) {
          if (mounted && p != null) {
            setState(() {
              _myName = p.name;
              _verified = p.verificationStatus == 'verified';
            });
          }
        }).catchError((_) {/* profil yüklenemedi — sessiz geç */});
      }
    }
  }

  @override
  void dispose() {
    _venueCtrl.dispose();
    super.dispose();
  }

  bool get _canPost => _venueCtrl.text.trim().isNotEmpty;

  String _lifetimeLabel(AppL10n t, int min) => switch (min) {
        30 => t.duration30m,
        60 => t.duration1h,
        _ => t.duration2h,
      };

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    final loc = LocationScope.of(context);
    _point ??= loc.point;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Column(children: [
          // header
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 20, 4),
            child: Row(children: [
              IconButton(
                onPressed: widget.onBack ?? () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back, color: AppColors.textStrong),
              ),
              Text(t.startAFlock, style: AppText.display(20)),
            ]),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              children: [
                Text(t.pickAVibe, style: AppText.eyebrow()),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final v in kVibes)
                    GestureDetector(
                      onTap: () => setState(() => _vibe = v.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                        decoration: BoxDecoration(
                          color: _vibe == v.id ? v.color : AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(
                              color: _vibe == v.id ? v.color : AppColors.borderSubtle, width: 1.5),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(v.emoji, style: const TextStyle(fontSize: 15)),
                          const SizedBox(width: 7),
                          Text(vibeLabel(t, v.id),
                              style: AppText.body(13, weight: FontWeight.w700,
                                  color: _vibe == v.id ? Colors.white : AppColors.textBody)),
                        ]),
                      ),
                    ),
                ]),
                const SizedBox(height: 24),
                Text(t.where, style: AppText.eyebrow()),
                const SizedBox(height: 10),
                // Mekan adı
                TextField(
                  controller: _venueCtrl,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) => setState(() {}),
                  style: AppText.body(15, weight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: t.venueNameHint,
                    hintStyle: AppText.body(15, color: AppColors.textFaint),
                    prefixIcon: const Icon(Icons.storefront, size: 20, color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.surfaceCard,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(color: AppColors.borderSubtle),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(color: AppColors.brand, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Harita seçici
                LocationPicker(
                  initial: _point!,
                  onChanged: (p, area) {
                    _point = p;
                    if (area != null && area.isNotEmpty) _area = area;
                    // Mekan adı boşsa arama sonucunun adını öner.
                    setState(() {});
                  },
                ),
                if (_area.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.place, size: 15, color: AppColors.brand),
                    const SizedBox(width: 5),
                    Expanded(child: Text(_area,
                        style: AppText.body(13, weight: FontWeight.w600, color: AppColors.textMuted))),
                  ]),
                ],
                const SizedBox(height: 20),
                Text(t.groupSize, style: AppText.eyebrow()),
                const SizedBox(height: 10),
                Row(children: [
                  Text(t.peopleCount(_size),
                      style: AppText.body(15, weight: FontWeight.w700, color: AppColors.textStrong)),
                  Expanded(
                    child: Slider(
                      value: _size.toDouble(),
                      min: 3, max: 8, divisions: 5,
                      activeColor: AppColors.brand,
                      label: '$_size',
                      onChanged: (v) => setState(() => _size = v.round()),
                    ),
                  ),
                ]),
                Text(t.minThree, style: AppText.body(12.5, color: AppColors.textMuted)),
                const SizedBox(height: 20),
                Text(t.howLong, style: AppText.eyebrow()),
                const SizedBox(height: 10),
                Row(children: [
                  for (final m in _lifetimeOptions) ...[
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _lifetimeMin = m),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _lifetimeMin == m ? AppColors.brand : AppColors.surfaceCard,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(
                                color: _lifetimeMin == m ? AppColors.brand : AppColors.borderSubtle,
                                width: 1.5),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                              m == 30 ? '⚡ ${_lifetimeLabel(t, m)}' : _lifetimeLabel(t, m),
                              style: AppText.body(13, weight: FontWeight.w700,
                                  color: _lifetimeMin == m ? Colors.white : AppColors.textBody)),
                        ),
                      ),
                    ),
                    if (m != _lifetimeOptions.last) const SizedBox(width: 8),
                  ],
                ]),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.coral50,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(children: [
                    const Icon(Icons.bolt, color: AppColors.brand, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(t.expiryNoteFor(_lifetimeLabel(t, _lifetimeMin)),
                          style: AppText.body(13, weight: FontWeight.w600, color: AppColors.brandHover)),
                    ),
                  ]),
                ),
              ],
            ),
          ),
          // footer CTA
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: const BoxDecoration(
              color: AppColors.surfaceCard,
              border: Border(top: BorderSide(color: AppColors.borderSubtle)),
            ),
            child: _posting
                ? const Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: CircularProgressIndicator(color: AppColors.brand)))
                : FlockButton(
                    label: _canPost
                        ? t.postInviteFor(_lifetimeLabel(t, _lifetimeMin))
                        : t.venueNameRequired,
                    full: true,
                    onPressed: _canPost ? _post : null,
                  ),
          ),
        ]),
      ),
    );
  }

  Future<void> _post() async {
    final t = AppL10n.of(context);
    final point = _point ?? LocationScope.of(context).point;
    final liveMsg = t.inviteLiveFor(_lifetimeLabel(t, _lifetimeMin));

    if (!FirebaseService.instance.isInitialized || _myUid == null) {
      widget.onPost?.call();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(liveMsg)));
      Navigator.maybePop(context);
      return;
    }

    setState(() => _posting = true);
    try {
      // Kullanıcı haritayı hiç oynatmadıysa bölge etiketi boş kalır;
      // kartlarda boş görünmesin diye konumdan çöz (başarısızsa boş kalabilir).
      var area = _area;
      if (area.isEmpty) {
        area = await GeocodingService.reverseLabel(point) ?? '';
      }
      await FlockRepository.instance.create(
        vibeId: _vibe,
        venue: _venueCtrl.text.trim(),
        area: area,
        hostUid: _myUid!,
        hostName: _myName.isEmpty ? 'Flocker' : _myName,
        verifiedHost: _verified,
        lat: point.lat,
        lng: point.lng,
        total: _size,
        lifetime: Duration(minutes: _lifetimeMin),
      );
      if (!mounted) return;
      widget.onPost?.call();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(liveMsg)));
      Navigator.maybePop(context);
    } catch (_) {
      if (mounted) {
        setState(() => _posting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.errGeneric)));
      }
    }
  }
}
