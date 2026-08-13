import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/flock.dart';
import '../../../core/services/geo.dart';

/// Firestore `flocks/{id}` belgesi — gerçek, canlı flock verisi.
/// UI'daki [Flock] modeline [toFlock] ile dönüştürülür.
class FlockDoc {
  final String id;
  final String vibeId;
  final String venue;
  final String area;
  final String hostUid;
  final String hostName;
  final bool verifiedHost;
  final double lat;
  final double lng;
  final int total;
  final List<String> memberUids;
  /// uid → görünen ad. Map olduğu için aynı isimli üyeler çakışmaz.
  final Map<String, String> memberNames;
  final DateTime? createdAt;
  final DateTime? expiresAt;

  const FlockDoc({
    required this.id,
    required this.vibeId,
    required this.venue,
    required this.area,
    required this.hostUid,
    required this.hostName,
    required this.lat,
    required this.lng,
    required this.total,
    required this.memberUids,
    required this.memberNames,
    this.verifiedHost = false,
    this.createdAt,
    this.expiresAt,
  });

  LatLng get point => LatLng(lat, lng);

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  bool get isFull => memberUids.length >= total;

  /// expiresAt'a göre kalan dakika (negatifse 0).
  int get minutesLeft {
    if (expiresAt == null) return 0;
    final m = expiresAt!.difference(DateTime.now()).inMinutes;
    return m < 0 ? 0 : m;
  }

  Map<String, dynamic> toMap() => {
        'vibeId': vibeId,
        'venue': venue,
        'area': area,
        'hostUid': hostUid,
        'hostName': hostName,
        'verifiedHost': verifiedHost,
        'lat': lat,
        'lng': lng,
        'total': total,
        'memberUids': memberUids,
        'memberNames': memberNames,
      };

  factory FlockDoc.fromMap(String id, Map<String, dynamic> m) {
    final memberUids = List<String>.from((m['memberUids'] as List? ?? const []).whereType<String>());
    return FlockDoc(
      id: id,
      vibeId: (m['vibeId'] ?? 'coffee') as String,
      venue: (m['venue'] ?? '') as String,
      area: (m['area'] ?? '') as String,
      hostUid: (m['hostUid'] ?? '') as String,
      hostName: (m['hostName'] ?? '') as String,
      verifiedHost: (m['verifiedHost'] ?? false) as bool,
      lat: ((m['lat'] ?? 0) as num).toDouble(),
      lng: ((m['lng'] ?? 0) as num).toDouble(),
      total: ((m['total'] ?? 5) as num).toInt(),
      memberUids: memberUids,
      memberNames: _parseNames(m['memberNames'], memberUids),
      createdAt: (m['createdAt'] as Timestamp?)?.toDate(),
      expiresAt: (m['expiresAt'] as Timestamp?)?.toDate(),
    );
  }

  /// memberNames'i uid→ad map'i olarak okur. Eski şemada paralel dizi olarak
  /// yazılmış belgelerle uyumlu kalmak için diziyi memberUids ile eşleştirir.
  static Map<String, String> _parseNames(dynamic raw, List<String> uids) {
    if (raw is Map) {
      return raw.map((k, v) => MapEntry('$k', '${v ?? ''}'));
    }
    if (raw is List) {
      return {
        for (var i = 0; i < uids.length && i < raw.length; i++)
          uids[i]: '${raw[i] ?? ''}',
      };
    }
    return const {};
  }

  /// UI render modeli. Üyelerin ilki host (doğrulanmış olabilir).
  Flock toFlock() => Flock(
        id: id,
        vibeId: vibeId,
        venue: venue,
        area: area,
        host: hostName,
        verifiedHost: verifiedHost,
        minutesLeft: minutesLeft,
        total: total,
        members: [
          for (final uid in memberUids)
            Person(memberNames[uid] ?? '', verified: uid == hostUid && verifiedHost),
        ],
        lat: lat,
        lng: lng,
      );
}
