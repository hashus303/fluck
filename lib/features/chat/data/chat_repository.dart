import 'package:cloud_firestore/cloud_firestore.dart';

/// Bir sohbet başlığı. İki tür aynı belge şeklini paylaşır:
///
///  * `dm`    — birbirini beğenmiş iki kişi. Üyelik belgede sabittir.
///  * `flock` — bir flock'un üyeleri. Üyelik belgede TUTULMAZ; kural flock
///    belgesine canlı bakar, böylece sonradan katılan okur, ayrılan okuyamaz.
///
/// `memberUids` yalnızca DM'de dolu olduğu için "sohbetlerim" sorgusu
/// (array-contains) doğal olarak sadece DM'leri getirir; flock sohbetine
/// zaten flock'un kendi ekranından girilir.
class ChatThread {
  final String id;
  final String kind;
  final List<String> memberUids;
  final String flockId;
  final String lastText;
  final String lastFrom;
  final DateTime? lastAt;

  /// uid → o kişinin sohbeti en son ne zaman açtığı.
  final Map<String, DateTime> seenAt;

  const ChatThread({
    required this.id,
    required this.kind,
    this.memberUids = const [],
    this.flockId = '',
    this.lastText = '',
    this.lastFrom = '',
    this.lastAt,
    this.seenAt = const {},
  });

  bool get isDm => kind == 'dm';

  /// DM'de karşı taraf.
  String otherUid(String me) =>
      memberUids.firstWhere((u) => u != me, orElse: () => '');

  /// Okunmamış var mı? Sayaç yerine damga kullanıyoruz: sayaç iki taraf da
  /// yazdığı için yarışa girer, damga girmez.
  bool unreadFor(String uid) {
    if (lastAt == null || lastFrom.isEmpty || lastFrom == uid) return false;
    final seen = seenAt[uid];
    return seen == null || seen.isBefore(lastAt!);
  }

  factory ChatThread.fromMap(String id, Map<String, dynamic> m) => ChatThread(
        id: id,
        kind: (m['kind'] ?? 'dm') as String,
        memberUids:
            ((m['memberUids'] as List?) ?? const []).whereType<String>().toList(),
        flockId: (m['flockId'] ?? '') as String,
        lastText: (m['lastText'] ?? '') as String,
        lastFrom: (m['lastFrom'] ?? '') as String,
        lastAt: (m['lastAt'] as Timestamp?)?.toDate(),
        seenAt: {
          for (final e in ((m['seenAt'] as Map?) ?? const {}).entries)
            if (e.value is Timestamp) e.key as String: (e.value as Timestamp).toDate(),
        },
      );
}

class ChatMessage {
  final String id;
  final String from;
  final String text;

  /// Sunucu damgası gelene kadar null olur (iyimser gösterim).
  final DateTime? at;

  const ChatMessage({
    required this.id,
    required this.from,
    required this.text,
    this.at,
  });

  factory ChatMessage.fromMap(String id, Map<String, dynamic> m) => ChatMessage(
        id: id,
        from: (m['from'] ?? '') as String,
        text: (m['text'] ?? '') as String,
        at: (m['at'] as Timestamp?)?.toDate(),
      );
}

/// Sohbet verisi — `threads/{id}` ve `threads/{id}/messages`.
class ChatRepository {
  ChatRepository._();
  static final ChatRepository instance = ChatRepository._();

  /// Bir mesajın üst sınırı; kuralda da aynı sayı var.
  static const maxLength = 1000;

  CollectionReference<Map<String, dynamic>> get _threads =>
      FirebaseFirestore.instance.collection('threads');

  /// DM kimliği uid'leri SIRALAYARAK üretilir: iki taraf da aynı kimliği
  /// hesaplar, aynı çift için ikinci bir sohbet doğmaz.
  static String dmId(String a, String b) =>
      a.compareTo(b) < 0 ? 'dm_${a}_$b' : 'dm_${b}_$a';

  static String flockThreadId(String flockId) => 'flock_$flockId';

  /// Sohbetlerim — en yeni üstte. Yalnızca DM'ler döner (bkz. [ChatThread]).
  Stream<List<ChatThread>> watchDms(String uid) => _threads
      .where('memberUids', arrayContains: uid)
      .orderBy('lastAt', descending: true)
      .limit(50)
      .snapshots()
      .map((s) => s.docs.map((d) => ChatThread.fromMap(d.id, d.data())).toList());

  /// Okunmamış sohbet sayısı — rozet için.
  Stream<int> unreadCount(String uid) =>
      watchDms(uid).map((l) => l.where((t) => t.unreadFor(uid)).length);

  Stream<ChatThread?> watchThread(String threadId) =>
      _threads.doc(threadId).snapshots().map(
          (d) => d.exists ? ChatThread.fromMap(d.id, d.data()!) : null);

  /// Mesajlar — en yeni önce (liste ters çizildiği için).
  Stream<List<ChatMessage>> watchMessages(String threadId, {int limit = 100}) =>
      _threads
          .doc(threadId)
          .collection('messages')
          .orderBy('at', descending: true)
          .limit(limit)
          .snapshots()
          .map((s) =>
              s.docs.map((d) => ChatMessage.fromMap(d.id, d.data())).toList());

  /// Mesaj gönderir; sohbet belgesi yoksa İLK MESAJDA açılır.
  ///
  /// Boş sohbet belgesi baştan yaratmıyoruz: eşleşen ama hiç yazmayan
  /// çiftler listeyi kirletmesin, "yeni eşleşme" ile "konuşma" ayrı kalsın.
  Future<void> send({
    required String threadId,
    required String from,
    required String text,
    required Map<String, dynamic> seed,
  }) async {
    final body = text.trim();
    if (body.isEmpty) return;
    final clipped =
        body.length > maxLength ? body.substring(0, maxLength) : body;

    final ref = _threads.doc(threadId);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        ...seed,
        'seenAt': {from: FieldValue.serverTimestamp()},
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await ref.collection('messages').add({
      'from': from,
      'text': clipped,
      'at': FieldValue.serverTimestamp(),
    });

    // Özet + kendi okundu damgam. Gönderen mesajı zaten okumuştur.
    await ref.update({
      'lastText': clipped,
      'lastFrom': from,
      'lastAt': FieldValue.serverTimestamp(),
      'seenAt.$from': FieldValue.serverTimestamp(),
    });
  }

  /// Sohbeti açtım — rozeti düşür. Belge yoksa (henüz yazılmamışsa) sessiz geç.
  Future<void> markSeen(String threadId, String uid) async {
    try {
      await _threads.doc(threadId).update({
        'seenAt.$uid': FieldValue.serverTimestamp(),
      });
    } catch (_) {/* sohbet henüz açılmamış ya da çevrimdışı */}
  }

  /// Kendi mesajını siler (yanlış gönderim). Özet satırı olduğu gibi kalır —
  /// kural özeti yalnız gönderene açtığı için karşı taraf temizleyemez.
  Future<void> deleteMessage(String threadId, String msgId) async {
    await _threads.doc(threadId).collection('messages').doc(msgId).delete();
  }

  /// DM açılışında kullanılacak belge tohumu.
  static Map<String, dynamic> dmSeed(String a, String b) {
    final pair = [a, b]..sort();
    return {'kind': 'dm', 'memberUids': pair};
  }

  /// Flock sohbeti tohumu — üyelik listesi YAZILMAZ, kural flock'a bakar.
  static Map<String, dynamic> flockSeed(String flockId) =>
      {'kind': 'flock', 'flockId': flockId};
}
