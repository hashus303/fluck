import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../auth/data/auth_repository.dart';
import '../../../core/services/firebase_service.dart';

/// Flock+ abonelik durumu. Firestore `subscriptions/{uid}` belgesinden okunur.
///
/// GÜVENLİK: Bu belgeyi istemci YAZAMAZ (firestore.rules: write:false).
/// Yalnızca sunucu, Play `purchaseToken`'ını doğruladıktan sonra yazar —
/// böylece sahte premium imkânsız. (Meetup da doğrulamayı sunucuda yapıyor.)
enum PremiumStatus { none, trial, active, expired, canceled }

@immutable
class PremiumState {
  final PremiumStatus status;
  final DateTime? trialEndsAt;
  final DateTime? currentPeriodEnd;
  final String? productId;

  const PremiumState({
    this.status = PremiumStatus.none,
    this.trialEndsAt,
    this.currentPeriodEnd,
    this.productId,
  });

  /// Premium özelliklere erişimi var mı? (deneme süresi de erişim sayılır)
  bool get isPlus =>
      status == PremiumStatus.trial || status == PremiumStatus.active;

  /// Deneme süresinde mi ve kaç gün kaldı?
  bool get inTrial => status == PremiumStatus.trial;

  int? get trialDaysLeft {
    final end = trialEndsAt;
    if (end == null || !inTrial) return null;
    final d = end.difference(DateTime.now()).inDays;
    return d < 0 ? 0 : d;
  }

  static PremiumStatus _parse(String? s) => switch (s) {
        'trial' => PremiumStatus.trial,
        'active' => PremiumStatus.active,
        'expired' => PremiumStatus.expired,
        'canceled' => PremiumStatus.canceled,
        _ => PremiumStatus.none,
      };

  factory PremiumState.fromMap(Map<String, dynamic> m) {
    final state = PremiumState(
      status: _parse(m['status'] as String?),
      trialEndsAt: (m['trialEndsAt'] as Timestamp?)?.toDate(),
      currentPeriodEnd: (m['currentPeriodEnd'] as Timestamp?)?.toDate(),
      productId: m['productId'] as String?,
    );
    // Sunucu henüz güncellememişse süresi geçmiş kaydı premium sayma.
    final end = state.currentPeriodEnd ?? state.trialEndsAt;
    if (state.isPlus && end != null && end.isBefore(DateTime.now())) {
      return PremiumState(
        status: PremiumStatus.expired,
        trialEndsAt: state.trialEndsAt,
        currentPeriodEnd: state.currentPeriodEnd,
        productId: state.productId,
      );
    }
    return state;
  }
}

class PremiumService {
  PremiumService._();
  static final PremiumService instance = PremiumService._();

  /// Play Console'da oluşturulacak abonelik ürün kimliği.
  static const productId = 'flock_plus_monthly';

  /// Aylık fiyat ve deneme süresi (paywall metinlerinde gösterilir).
  static const priceLabel = '₺99';
  static const trialDays = 14;

  /// UI'ın senkron okuyabilmesi için son bilinen durum.
  final ValueNotifier<PremiumState> state =
      ValueNotifier(const PremiumState());

  bool get isPlus => state.value.isPlus;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      FirebaseFirestore.instance.collection('subscriptions').doc(uid);

  /// Giriş yapan kullanıcının aboneliğini canlı dinler.
  Stream<PremiumState> watch(String uid) => _doc(uid).snapshots().map((s) {
        final data = s.data();
        final next = (!s.exists || data == null)
            ? const PremiumState()
            : PremiumState.fromMap(data);
        state.value = next;
        return next;
      });

  /// Tek seferlik okuma (gate kontrolleri için).
  Future<PremiumState> fetch() async {
    if (!FirebaseService.instance.isInitialized) return const PremiumState();
    final uid = AuthRepository.instance.currentUser?.uid;
    if (uid == null) return const PremiumState();
    try {
      final snap = await _doc(uid).get();
      final data = snap.data();
      final next = (!snap.exists || data == null)
          ? const PremiumState()
          : PremiumState.fromMap(data);
      state.value = next;
      return next;
    } catch (_) {
      return state.value; // çevrimdışı — son bilineni koru
    }
  }
}
