import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../../../core/models/flock.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/geo.dart';
import '../../../core/services/location_controller.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/flock_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_repository.dart';
import '../../flock/data/flock_doc.dart';
import '../../flock/data/flock_repository.dart';

/// Harita ekranı — gerçek OpenStreetMap üzerinde yakındaki flock'lar.
/// Anahtar gerektirmez (OSM tile API + zorunlu atıf). Pin'e dokununca altta
/// kart açılır; karttan detaya gidilir.
class MapScreen extends StatefulWidget {
  final void Function(Flock)? onOpenInvite;
  const MapScreen({super.key, this.onOpenInvite});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _mapController = MapController();
  String? _selectedId;

  bool get _live =>
      FirebaseService.instance.isInitialized &&
      AuthRepository.instance.currentUser != null;

  @override
  Widget build(BuildContext context) {
    final loc = LocationScope.of(context);
    if (_live) {
      return StreamBuilder<List<FlockDoc>>(
        stream: FlockRepository.instance.watchActive(),
        builder: (context, snap) {
          final flocks =
              (snap.data ?? const <FlockDoc>[]).map((d) => d.toFlock()).toList();
          return _map(loc, flocks);
        },
      );
    }
    // Firebase yoksa örnek veriyle çalış (çevrimdışı mod).
    return _map(loc, kFlocks);
  }

  Widget _map(LocationController loc, List<Flock> flocks) {
    final retina = RetinaMode.isHighDensity(context);
    final selected = _selectedId == null
        ? null
        : flocks.where((f) => f.id == _selectedId).firstOrNull;

    return Stack(children: [
      Positioned.fill(
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: ll.LatLng(loc.point.lat, loc.point.lng),
            initialZoom: 12,
            onTap: (_, _) => setState(() => _selectedId = null),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.hashus303.fluck',
              retinaMode: retina,
            ),
            MarkerLayer(markers: [
              // Kullanıcının konumu
              Marker(
                point: ll.LatLng(loc.point.lat, loc.point.lng),
                width: 22,
                height: 22,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.sky500,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: const [
                      BoxShadow(color: Color(0x552D6BE0), blurRadius: 12),
                    ],
                  ),
                ),
              ),
              // Flock pin'leri
              for (final f in flocks)
                Marker(
                  point: ll.LatLng(f.lat, f.lng),
                  width: 44,
                  height: 44,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedId = f.id),
                    child: VibeDot(vibe: f.vibe, size: 44),
                  ),
                ),
            ]),
            const OsmAttribution(),
          ],
        ),
      ),

      // locate-me
      Positioned(
        right: 14,
        bottom: selected == null ? 24 : 190,
        child: _GlassIconButton(icon: Icons.my_location, onTap: () => _locateMe(loc)),
      ),

      // seçili flock kartı
      if (selected != null)
        Positioned(
          left: 14, right: 14, bottom: 14,
          child: InviteCard(
            flock: selected,
            distance: distanceLabel(haversineKm(loc.point, selected.point)),
            onTap: () => widget.onOpenInvite?.call(selected),
          ),
        ),
    ]);
  }

  Future<void> _locateMe(LocationController loc) async {
    final err = await loc.useDeviceLocation();
    if (!mounted) return;
    if (err == LocationError.none) {
      _mapController.move(ll.LatLng(loc.point.lat, loc.point.lng), 14);
      return;
    }
    // Hata: home ekranıyla aynı mesajları göster.
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
