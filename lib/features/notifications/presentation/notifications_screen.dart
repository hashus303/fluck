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
    final isAnnouncement = n.type == 'announcement';
    final isWarning = n.type == 'warning';
    final isJoin = !isVerification && !isAnnouncement && !isWarning;
    final approved = n.status == 'approved';

    final String title = isVerification
        ? (approved ? t.notifVerifApproved : t.notifVerifRejected)
        : (isAnnouncement || isWarning)
            ? n.text
            : t.notifJoined(n.actorName);
    final String subtitle = isJoin
        ? '${n.venue} · ${_ago(t, n.createdAt)}'
        : isAnnouncement
            ? '${t.notifAnnouncement} · ${_ago(t, n.createdAt)}'
            : isWarning
                ? '${t.notifWarning} · ${_ago(t, n.createdAt)}'
                : _ago(t, n.createdAt);

    return GestureDetector(
      // Yalnızca 'join' bir flock'a gider; diğerlerinin hedefi yok.
      onTap: isJoin
          ? () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => FlockDetailScreen(flockId: n.flockId),
              ))
          : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          _leading(isVerification, isAnnouncement, isWarning, approved),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  maxLines: (isAnnouncement || isWarning) ? 4 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(14, weight: FontWeight.w700, color: AppColors.textStrong)),
              const SizedBox(height: 2),
              Text(subtitle,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: AppText.body(12.5, color: AppColors.textMuted)),
            ]),
          ),
          if (isJoin) const Icon(Icons.chevron_right, color: AppColors.textFaint),
        ]),
      ),
    );
  }

  Widget _leading(bool isVerification, bool isAnnouncement, bool isWarning, bool approved) {
    if (isJoinAvatar(isVerification, isAnnouncement, isWarning)) {
      return FlockAvatar(name: n.actorName, size: 42);
    }
    late final Color bg;
    late final Color fg;
    late final IconData icon;
    if (isVerification) {
      bg = approved ? const Color(0xFFE8F7EF) : const Color(0xFFFDECEC);
      fg = approved ? AppColors.success : AppColors.danger;
      icon = approved ? Icons.verified : Icons.error_outline;
    } else if (isAnnouncement) {
      bg = AppColors.coral50;
      fg = AppColors.brand;
      icon = Icons.campaign_rounded;
    } else {
      bg = const Color(0xFFFFF4E0); // amber soft
      fg = AppColors.warning;
      icon = Icons.warning_amber_rounded;
    }
    return Container(
      width: 42, height: 42,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Icon(icon, size: 22, color: fg),
    );
  }

  bool isJoinAvatar(bool v, bool a, bool w) => !v && !a && !w;

  String _ago(AppL10n t, DateTime? time) {
    if (time == null) return t.agoNow;
    final d = DateTime.now().difference(time);
    if (d.inMinutes < 1) return t.agoNow;
    if (d.inMinutes < 60) return t.agoMin(d.inMinutes);
    if (d.inHours < 24) return t.agoHour(d.inHours);
    return t.agoDay(d.inDays);
  }
}
