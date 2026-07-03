import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../services/geo.dart';
import '../services/geocoding_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import 'flock_widgets.dart';

/// Harita üzerinde konum seç — OpenStreetMap (anahtarsız).
/// Üstte yer arama, altta merkez-pin'li sürüklenebilir harita.
/// Seçim değiştikçe [onChanged] (konum + kısa bölge etiketi) tetiklenir.
class LocationPicker extends StatefulWidget {
  final LatLng initial;
  final void Function(LatLng point, String? areaLabel) onChanged;
  final double height;
  const LocationPicker({
    super.key,
    required this.initial,
    required this.onChanged,
    this.height = 220,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final _mapController = MapController();
  final _searchCtrl = TextEditingController();
  List<GeoPlace> _results = const [];
  bool _searching = false;
  Timer? _reverseDebounce;
  LatLng _center = const LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    _center = widget.initial;
  }

  @override
  void dispose() {
    _reverseDebounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _runSearch() async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) return;
    setState(() => _searching = true);
    final res = await GeocodingService.search(q, near: _center);
    if (!mounted) return;
    setState(() {
      _results = res;
      _searching = false;
    });
  }

  void _pickResult(GeoPlace place) {
    setState(() {
      _results = const [];
      _searchCtrl.text = place.name;
      _center = place.point;
    });
    _mapController.move(ll.LatLng(place.point.lat, place.point.lng), 16);
    widget.onChanged(place.point, place.shortLabel);
  }

  void _onMapMove(MapCamera camera, bool hasGesture) {
    _center = LatLng(camera.center.latitude, camera.center.longitude);
    // Sürükleme bitince (debounce) konum + ters-geocode etiketi bildir.
    _reverseDebounce?.cancel();
    _reverseDebounce = Timer(const Duration(milliseconds: 700), () async {
      final label = await GeocodingService.reverseLabel(_center);
      if (!mounted) return;
      widget.onChanged(_center, label);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Arama
      Row(children: [
        Expanded(
          child: TextField(
            controller: _searchCtrl,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _runSearch(),
            style: AppText.body(15, weight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: t.venueSearchHint,
              hintStyle: AppText.body(15, color: AppColors.textFaint),
              prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.surfaceCard,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _searching ? null : _runSearch,
          child: Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: AppColors.brand,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: _searching
                ? const Padding(
                    padding: EdgeInsets.all(13),
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
          ),
        ),
      ]),
      // Sonuç listesi
      if (_results.isNotEmpty) ...[
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(children: [
            for (final r in _results)
              ListTile(
                dense: true,
                leading: const Icon(Icons.place, size: 18, color: AppColors.brand),
                title: Text(r.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: AppText.body(14, weight: FontWeight.w600)),
                subtitle: Text(r.shortLabel, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: AppText.body(12, color: AppColors.textMuted)),
                onTap: () => _pickResult(r),
              ),
          ]),
        ),
      ],
      const SizedBox(height: 10),
      // Harita + merkez pin
      ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: SizedBox(
          height: widget.height,
          child: Stack(alignment: Alignment.center, children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: ll.LatLng(widget.initial.lat, widget.initial.lng),
                initialZoom: 15,
                onPositionChanged: _onMapMove,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag | InteractiveFlag.doubleTapZoom,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.fluck.app',
                ),
                const OsmAttribution(),
              ],
            ),
            // Sabit merkez pin — harita altında kaydıkça konum değişir.
            const Padding(
              padding: EdgeInsets.only(bottom: 28),
              child: Icon(Icons.location_on, size: 38, color: AppColors.brand),
            ),
          ]),
        ),
      ),
      const SizedBox(height: 6),
      Text(t.venuePinHint, style: AppText.body(12, color: AppColors.textMuted)),
    ]);
  }
}
