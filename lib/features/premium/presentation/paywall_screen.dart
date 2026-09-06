import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/flock_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../data/premium_service.dart';

/// Flock+ satış ekranı.
///
/// Meetup'ın karanlık desenlerinin TERSİ olacak şekilde tasarlandı:
/// fiyat ve deneme süresi net, "istediğin an iptal" görünür, ve deneme
/// bitmeden hatırlatacağımızı açıkça söyleriz. Onboarding'e gömülmez —
/// yalnızca kullanıcı kilitli bir özelliğe dokunduğunda ya da kendi
/// açtığında gösterilir.
class PaywallScreen extends StatelessWidget {
  /// Kilitli özelliği tanıtan opsiyonel başlık (bağlamsal paywall için).
  final String? contextTitle;
  const PaywallScreen({super.key, this.contextTitle});

  static Future<void> show(BuildContext context, {String? contextTitle}) {
    return Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PaywallScreen(contextTitle: contextTitle),
      fullscreenDialog: true,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    final features = [
      ('💘', t.plusFeatureDateTitle, t.plusFeatureDateBody),
      ('👀', t.plusFeatureNearbyTitle, t.plusFeatureNearbyBody),
      ('🚀', t.plusFeatureUnlimitedTitle, t.plusFeatureUnlimitedBody),
      ('🎛️', t.plusFeatureFiltersTitle, t.plusFeatureFiltersBody),
    ];

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Column(children: [
          // Kapat
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: t.a11yClose,
              icon: Icon(Icons.close, color: AppColors.textMuted),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
              children: [
                // Başlık üstü etiket (eyebrow) yok: başlık kendi ağırlığını
                // taşır ve hangi özelliğin kilidi olduğu zaten listenin ilk
                // satırında görünür.
                Text(t.plusTitle, style: AppText.display(38)),
                const SizedBox(height: 6),
                Text(t.plusTagline,
                    style: AppText.body(16, color: AppColors.textMuted)),
                const SizedBox(height: 18),

                // Deneme rozeti + fiyat — hiçbir şey gizli değil.
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: AppColors.brandGradient),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    boxShadow: AppColors.glowCoral,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.plusTrialBadge,
                          style: AppText.display(22, color: AppColors.onBrand)),
                      const SizedBox(height: 4),
                      Text(t.plusPriceLine,
                          style: AppText.body(13.5,
                              weight: FontWeight.w600,
                              color: AppColors.onBrand.withValues(alpha: 0.92))),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                for (final (emoji, title, body) in features) ...[
                  _FeatureRow(emoji: emoji, title: title, body: body),
                  const SizedBox(height: 14),
                ],

                const SizedBox(height: 4),
                // Dürüstlük notu — Meetup'ın en çok şikayet edilen noktası.
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.successSoft,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: const Color(0xFFC6ECDB)),
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.notifications_active_outlined,
                        size: 18, color: AppColors.success),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(t.plusHonestNote,
                          style: AppText.body(12.5, color: AppColors.success)),
                    ),
                  ]),
                ),
              ],
            ),
          ),

          // CTA — billing bağlanana kadar "yakında" bilgisi verir (yanıltmaz).
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 18),
            child: Column(children: [
              FlockButton(
                label: t.plusCta,
                full: true,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t.plusSoon)),
                  );
                },
              ),
              const SizedBox(height: 8),
              Text('${PremiumService.priceLabel} / ${t.plusTrialBadge}',
                  style: AppText.body(11.5, color: AppColors.textFaint)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String emoji, title, body;
  const _FeatureRow({required this.emoji, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.brandSoft,
          borderRadius: BorderRadius.circular(13),
        ),
        alignment: Alignment.center,
        child: Text(emoji, style: const TextStyle(fontSize: 20)),
      ),
      const SizedBox(width: 13),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: AppText.body(15,
                  weight: FontWeight.w800, color: AppColors.textStrong)),
          const SizedBox(height: 2),
          Text(body, style: AppText.body(13, color: AppColors.textMuted)),
        ]),
      ),
    ]);
  }
}
