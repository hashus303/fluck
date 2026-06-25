import 'package:flutter/material.dart';

import '../services/geo.dart';
import '../theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

/// Flock "vibe" (kategori) tanımı — emoji + renk.
class Vibe {
  final String id;
  final String label;
  final String emoji;
  final Color color;
  const Vibe(this.id, this.label, this.emoji, this.color);
}

const kVibes = <Vibe>[
  Vibe('coffee', 'Coffee', '☕', AppColors.vibeCoffee),
  Vibe('bar', 'Bar', '🍸', AppColors.vibeBar),
  Vibe('walk', 'Walk', '🚶', AppColors.vibeWalk),
  Vibe('games', 'Games', '🎮', AppColors.vibeGames),
  Vibe('food', 'Food', '🍜', AppColors.vibeFood),
  Vibe('music', 'Music', '🎶', AppColors.vibeMusic),
];

Vibe vibeById(String id) =>
    kVibes.firstWhere((v) => v.id == id, orElse: () => kVibes.first);

/// Vibe id'sine göre yerelleştirilmiş etiket.
String vibeLabel(AppL10n t, String id) {
  switch (id) {
    case 'coffee':
      return t.vibeCoffee;
    case 'bar':
      return t.vibeBar;
    case 'walk':
      return t.vibeWalk;
    case 'games':
      return t.vibeGames;
    case 'food':
      return t.vibeFood;
    case 'music':
      return t.vibeMusic;
    default:
      return vibeById(id).label;
  }
}

/// Bir buluşmaya katılan kişi.
class Person {
  final String name;
  final bool verified;
  const Person(this.name, {this.verified = false});
}

/// Süresi dolan bir grup daveti ("flock").
class Flock {
  final String id;
  final String vibeId;
  final String venue;
  final String area;
  final String host;
  final bool verifiedHost;
  final int minutesLeft;
  final int total;
  final List<Person> members;
  final double lat;
  final double lng;

  const Flock({
    required this.id,
    required this.vibeId,
    required this.venue,
    required this.area,
    required this.host,
    required this.minutesLeft,
    required this.total,
    required this.members,
    required this.lat,
    required this.lng,
    this.verifiedHost = true,
  });

  Vibe get vibe => vibeById(vibeId);
  bool get full => members.length >= total;
  LatLng get point => LatLng(lat, lng);
}

/// Örnek veri (Firestore bağlanana kadar). Koordinatlar gerçek — mesafe
/// filtresini denemek için: İstanbul'da 4 yakın flock + Ankara/İzmir'de 2 uzak.
const kFlocks = <Flock>[
  // — İstanbul (varsayılan konuma yakın) —
  Flock(
    id: 'f1',
    vibeId: 'bar',
    venue: 'Karga Bar',
    area: 'Kadıköy',
    host: 'Mara',
    minutesLeft: 96,
    total: 5,
    members: [Person('Mara', verified: true), Person('Deniz'), Person('Lee')],
    lat: 40.9895, lng: 29.0270, // ~0.2 km
  ),
  Flock(
    id: 'f2',
    vibeId: 'coffee',
    venue: 'Moda Sahil',
    area: 'Moda',
    host: 'Theo',
    minutesLeft: 84,
    total: 6,
    members: [Person('Theo', verified: true), Person('Ada'), Person('Sam'), Person('Noa')],
    lat: 40.9785, lng: 29.0250, // ~1.3 km
  ),
  Flock(
    id: 'f3',
    vibeId: 'walk',
    venue: 'Caddebostan Sahil',
    area: 'Caddebostan',
    host: 'Jin',
    minutesLeft: 41,
    total: 5,
    members: [Person('Jin'), Person('Rey'), Person('Eda')],
    lat: 40.9630, lng: 29.0660, // ~4 km
  ),
  Flock(
    id: 'f4',
    vibeId: 'games',
    venue: 'Pasaj',
    area: 'Beşiktaş',
    host: 'Cleo',
    minutesLeft: 112,
    total: 6,
    members: [Person('Cleo', verified: true), Person('Max'), Person('Ivy'), Person('Tom')],
    lat: 41.0420, lng: 29.0080, // ~6 km
  ),
  // — Uzak şehirler (varsayılan yarıçap dışında kalır) —
  Flock(
    id: 'f5',
    vibeId: 'food',
    venue: 'Kızılay Meydanı',
    area: 'Ankara',
    host: 'Burak',
    minutesLeft: 73,
    total: 5,
    members: [Person('Burak', verified: true), Person('Sena'), Person('Kaan')],
    lat: 39.9208, lng: 32.8541, // ~350 km
  ),
  Flock(
    id: 'f6',
    vibeId: 'music',
    venue: 'Alsancak',
    area: 'İzmir',
    host: 'Derya',
    minutesLeft: 58,
    total: 6,
    members: [Person('Derya', verified: true), Person('Efe'), Person('Lara')],
    lat: 38.4370, lng: 27.1428, // ~330 km
  ),
];
