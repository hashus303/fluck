import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../../../core/models/flock.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/geo.dart';
import '../../../core/services/location_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/flock_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_repository.dart';
import '../../profile/data/user_profile_repository.dart';
import '../data/flock_doc.dart';
import '../data/flock_repository.dart';

/// Flock detayı — harita, üyeler, geri sayım, katıl/ayrıl.
class FlockDetailScreen extends StatefulWidget {
  final String flockId;
  final Flock? fallback; // ilk kare için (çevrimdışı / mock); bildirimden açılınca null
  const FlockDetailScreen({super.key, required this.flockId, this.fallback});

  @override
  State<FlockDetailScreen> createState() => _FlockDetailScreenState();
}

class _FlockDetailScreenState extends State<FlockDetailScreen> {
  String? _myUid;
  String _myName = '';
  bool _busy = false;

  bool get _live => FirebaseService.instance.isInitialized && _myUid != null;

  @override
  void initState() {
    super.initState();
    if (FirebaseService.instance.isInitialized) {
      _myUid = AuthRepository.instance.currentUser?.uid;
      if (_myUid != null) {
        UserProfileRepository.instance.fetch(_myUid!).then((p) {
          if (mounted && p != null) setState(() => _myName = p.name);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_live) {
      // Çevrimdışı: fallback flock'u statik göster.
      if (widget.fallback == null) return _closedScaffold();
      return _scaffold(_fromFlock(widget.fallback!), joined: false, isHost: false);
    }
    return StreamBuilder<FlockDoc?>(
      stream: FlockRepository.instance.watchOne(widget.flockId),
      initialData: widget.fallback != null ? _fromFlock(widget.fallback!) : null,
      builder: (context, snap) {
        final doc = snap.data;
        if (doc == null) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: AppColors.bgPage,
              body: Center(child: CircularProgressIndicator(color: AppColors.brand)),
            );
          }
          // Silinmiş / kapanmış.
          return _closedScaffold();
        }
        return _scaffold(
          doc,
          joined: doc.memberUids.contains(_myUid),
          isHost: doc.hostUid == _myUid,
        );
      },
    );
  }

  FlockDoc _fromFlock(Flock f) => FlockDoc(
        id: f.id,
        vibeId: f.vibeId,
        venue: f.venue,
        area: f.area,
        hostUid: '',
        hostName: f.host,
        verifiedHost: f.verifiedHost,
        lat: f.lat,
        lng: f.lng,
        total: f.total,
        memberUids: const [],
        memberNames: [for (final m in f.members) m.name],
        expiresAt: DateTime.now().add(Duration(minutes: f.minutesLeft)),
      );

  Widget _closedScaffold() {
    final t = AppL10n.of(context);
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(backgroundColor: AppColors.bgPage, elevation: 0,
          leading: const BackButton(color: AppColors.textStrong)),
      body: Center(child: Text(t.flockClosed, style: AppText.body(15, color: AppColors.textMuted))),
    );
  }

  Widget _scaffold(FlockDoc doc, {required bool joined, required bool isHost}) {
    final t = AppL10n.of(context);
    final loc = LocationScope.of(context);
    final v = vibeById(doc.vibeId);
    final km = haversineKm(loc.point, doc.point);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 20, 4),
            child: Row(children: [
              IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back, color: AppColors.textStrong),
              ),
              Expanded(child: Text(t.flockDetails, style: AppText.display(20))),
              CountdownPill(minutesLeft: doc.minutesLeft),
            ]),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                // Harita
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  child: SizedBox(
                    height: 200,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: ll.LatLng(doc.lat, doc.lng),
                        initialZoom: 15,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.fluck.app',
                        ),
                        MarkerLayer(markers: [
                          Marker(
                            point: ll.LatLng(doc.lat, doc.lng),
                            width: 44, height: 44,
                            child: VibeDot(vibe: v, size: 44),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Text(vibeLabel(t, doc.vibeId), style: AppText.display(22)),
                  Text('  ·  ', style: AppText.body(16, color: AppColors.textFaint)),
                  Expanded(child: Text(doc.venue, style: AppText.body(17, weight: FontWeight.w700))),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.place, size: 16, color: AppColors.brand),
                  const SizedBox(width: 4),
                  Text('${distanceLabel(km)}${doc.area.isEmpty ? '' : ' · ${doc.area}'}',
                      style: AppText.body(13.5, color: AppColors.textMuted)),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  if (doc.verifiedHost) const VerifiedBadge(),
                  if (doc.verifiedHost) const SizedBox(width: 8),
                  FlockBadge(t.isHosting(doc.hostName), icon: '🪶', tone: BadgeTone.coral),
                ]),
                const SizedBox(height: 22),
                Text(t.membersTitle, style: AppText.eyebrow()),
                const SizedBox(height: 8),
                Text(t.joinedCount(doc.memberNames.length, doc.total),
                    style: AppText.body(13.5, weight: FontWeight.w700, color: AppColors.textMuted)),
                const SizedBox(height: 12),
                Wrap(spacing: 10, runSpacing: 12, children: [
                  for (var i = 0; i < doc.memberNames.length; i++)
                    _MemberChip(name: doc.memberNames[i], isHost: i == 0),
                ]),
                const SizedBox(height: 8),
              ],
            ),
          ),
          // CTA
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: const BoxDecoration(
              color: AppColors.surfaceCard,
              border: Border(top: BorderSide(color: AppColors.borderSubtle)),
            ),
            child: _busy
                ? const Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: CircularProgressIndicator(color: AppColors.brand)))
                : _cta(t, doc, joined: joined, isHost: isHost),
          ),
        ]),
      ),
    );
  }

  Widget _cta(AppL10n t, FlockDoc doc, {required bool joined, required bool isHost}) {
    if (isHost) {
      return FlockButton(
        label: t.cancelFlock, variant: FlockBtn.danger, full: true,
        onPressed: () => _leave(doc),
      );
    }
    if (joined) {
      return FlockButton(
        label: t.leaveFlock, variant: FlockBtn.secondary, full: true,
        onPressed: () => _leave(doc),
      );
    }
    if (doc.isFull) {
      return FlockButton(label: t.flockFull, variant: FlockBtn.secondary, full: true, onPressed: null);
    }
    return FlockButton(label: t.join, full: true, onPressed: () => _join(doc));
  }

  Future<void> _join(FlockDoc doc) async {
    final t = AppL10n.of(context);
    if (!_live) return;
    setState(() => _busy = true);
    try {
      await FlockRepository.instance.join(doc.id, _myUid!, _myName.isEmpty ? 'Flocker' : _myName);
    } on FlockJoinException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.code == 'full' ? t.flockFull : t.errGeneric)));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.errGeneric)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _leave(FlockDoc doc) async {
    final t = AppL10n.of(context);
    if (!_live) return;
    setState(() => _busy = true);
    try {
      await FlockRepository.instance.leave(doc.id, _myUid!, _myName.isEmpty ? 'Flocker' : _myName);
      if (doc.hostUid == _myUid && mounted) Navigator.maybePop(context);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.errGeneric)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _MemberChip extends StatelessWidget {
  final String name;
  final bool isHost;
  const _MemberChip({required this.name, required this.isHost});
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      FlockAvatar(name: name, size: 52),
      const SizedBox(height: 6),
      SizedBox(
        width: 64,
        child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
            style: AppText.body(12.5, weight: FontWeight.w600)),
      ),
    ]);
  }
}
