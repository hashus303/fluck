import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluck/features/flock/data/flock_doc.dart';

/// Temel, geçerli bir flock belgesi (map tabanlı memberNames ile).
Map<String, dynamic> baseDoc({
  Map<String, String>? memberNames,
  List<String>? memberUids,
  dynamic rawNames, // eski şema (List) testleri için
  int total = 5,
  String hostUid = 'u1',
  bool verifiedHost = true,
  DateTime? expiresAt,
}) {
  return {
    'vibeId': 'coffee',
    'venue': 'Moda Sahil',
    'area': 'Moda',
    'hostUid': hostUid,
    'hostName': 'Ada',
    'verifiedHost': verifiedHost,
    'lat': 40.9785,
    'lng': 29.0250,
    'total': total,
    'memberUids': memberUids ?? const ['u1', 'u2'],
    'memberNames': rawNames ?? memberNames ?? const {'u1': 'Ada', 'u2': 'Bo'},
    if (expiresAt != null) 'expiresAt': Timestamp.fromDate(expiresAt),
  };
}

void main() {
  group('FlockDoc.fromMap — memberNames map şeması', () {
    test('map olarak okur, uid ile isim eşler', () {
      final d = FlockDoc.fromMap('f1', baseDoc());
      expect(d.memberNames, {'u1': 'Ada', 'u2': 'Bo'});
      expect(d.memberUids, ['u1', 'u2']);
    });

    test('aynı isimli iki üye çakışmaz (asıl düzeltilen bug)', () {
      final d = FlockDoc.fromMap(
        'f1',
        baseDoc(memberNames: const {'u1': 'Sam', 'u2': 'Sam'}),
      );
      // İki ayrı uid, iki ayrı kayıt — sayı 2 olmalı (eskiden 1'e düşüyordu).
      expect(d.memberUids.length, 2);
      expect(d.memberNames.length, 2);
      final flock = d.toFlock();
      expect(flock.members.length, 2);
      expect(flock.members.map((m) => m.name), ['Sam', 'Sam']);
    });
  });

  group('FlockDoc.fromMap — eski dizi şemasıyla geriye uyum', () {
    test('paralel dizi memberNames, memberUids ile eşleştirilir', () {
      final d = FlockDoc.fromMap(
        'f1',
        baseDoc(rawNames: const ['Ada', 'Bo']),
      );
      expect(d.memberNames, {'u1': 'Ada', 'u2': 'Bo'});
    });

    test('memberNames hiç yoksa boş map', () {
      final m = baseDoc()..remove('memberNames');
      final d = FlockDoc.fromMap('f1', m);
      expect(d.memberNames, isEmpty);
    });
  });

  group('FlockDoc türetilmiş alanlar', () {
    test('isFull — üye sayısı total\'a ulaşınca true', () {
      final full = FlockDoc.fromMap('f1', baseDoc(total: 2));
      expect(full.isFull, isTrue);
      final notFull = FlockDoc.fromMap('f1', baseDoc(total: 5));
      expect(notFull.isFull, isFalse);
    });

    test('isExpired — geçmiş expiresAt için true', () {
      final past = FlockDoc.fromMap(
        'f1',
        baseDoc(expiresAt: DateTime.now().subtract(const Duration(minutes: 5))),
      );
      expect(past.isExpired, isTrue);
    });

    test('minutesLeft — gelecekteki expiresAt için pozitif', () {
      final d = FlockDoc.fromMap(
        'f1',
        baseDoc(expiresAt: DateTime.now().add(const Duration(minutes: 90))),
      );
      expect(d.minutesLeft, greaterThan(80));
      expect(d.minutesLeft, lessThanOrEqualTo(90));
    });
  });

  group('FlockDoc.toFlock — UI modeli', () {
    test('üyeler memberUids sırasında, host uid ile işaretlenir', () {
      final d = FlockDoc.fromMap('f1', baseDoc());
      final flock = d.toFlock();
      expect(flock.members.length, 2);
      expect(flock.members[0].name, 'Ada');
      expect(flock.members[0].verified, isTrue); // host (u1) + verifiedHost
      expect(flock.members[1].name, 'Bo');
      expect(flock.members[1].verified, isFalse);
    });

    test('verifiedHost false ise host işaretlenmez', () {
      final d = FlockDoc.fromMap('f1', baseDoc(verifiedHost: false));
      final flock = d.toFlock();
      expect(flock.members[0].verified, isFalse);
    });
  });
}
