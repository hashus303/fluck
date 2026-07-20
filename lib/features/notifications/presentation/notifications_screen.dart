import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/flock_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../flock/presentation/flock_detail_screen.dart';
import '../data/notification_repository.dart';

/// Uygulama-içi bildirim akışı — açılınca hepsi okundu işaretlenir.
class NotificationsScreen extends StatefulWidget {
  final String uid;
  const NotificationsScreen({super.key, required this.uid});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    NotificationRepository.instance.markAllRead(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgPage,
        elevation: 0,
        leading: const BackButton(color: AppColors.textStrong),
        title: Text(t.notifTitle, style: AppText.display(20)),
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: NotificationRepository.instance.watch(widget.uid),
        builder: (context, snap) {
          final items = snap.data ?? const <AppNotification>[];
          if (items.isEmpty) {
            return Center(
              child: Text(t.notifEmpty, style: AppText.body(14, color: AppColors.textMuted)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: items.length,
            separatorBuilder: (_, i) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _NotifRow(n: items[i]),
          );
        },
      ),
    );
  }
}

class _NotifRow extends StatelessWidget {
  final AppNotification n;
  const _NotifRow({required this.n});

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    final isVerification = n.type == 'verification';
    final approved = n.status == 'approved';
    return GestureDetector(
      // Doğrulama bildirimi bir flock'a gitmez.
      onTap: isVerification
          ? null
          : () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => FlockDetailScreen(flockId: n.flockId),
              )),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(children: [
          if (isVerification)
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: approved ? const Color(0xFFE8F7EF) : const Color(0xFFFDECEC),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(approved ? Icons.verified : Icons.error_outline,
                  size: 22, color: approved ? AppColors.success : AppColors.danger),
            )
          else
            FlockAvatar(name: n.actorName, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                  isVerification
                      ? (approved ? t.notifVerifApproved : t.notifVerifRejected)
                      : t.notifJoined(n.actorName),
                  style: AppText.body(14, weight: FontWeight.w700, color: AppColors.textStrong)),
              const SizedBox(height: 2),
              Text(
                  isVerification
                      ? _ago(t, n.createdAt)
                      : '${n.venue} · ${_ago(t, n.createdAt)}',
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: AppText.body(12.5, color: AppColors.textMuted)),
            ]),
          ),
          if (!isVerification) const Icon(Icons.chevron_right, color: AppColors.textFaint),
        ]),
      ),
    );
  }

  String _ago(AppL10n t, DateTime? time) {
    if (time == null) return t.agoNow;
    final d = DateTime.now().difference(time);
    if (d.inMinutes < 1) return t.agoNow;
    if (d.inMinutes < 60) return t.agoMin(d.inMinutes);
    if (d.inHours < 24) return t.agoHour(d.inHours);
    return t.agoDay(d.inDays);
  }
}
