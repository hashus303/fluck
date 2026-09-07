import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/flock_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../date/data/likes_repository.dart';
import '../../profile/data/user_profile_repository.dart';
import '../../safety/data/moderation_repository.dart';
import '../data/chat_repository.dart';
import 'chat_screen.dart';

/// Mesaj kutusu — Date destesinin ürettiği konuşmalar.
///
/// İki bölüm var ve ayrı durmaları önemli:
///  * "Yeni eşleşmeler" — karşılıklı beğeni var ama HENÜZ kimse yazmamış.
///    Bunlar konuşma değil; listeye karışsalar kutu boş satırlarla dolar.
///  * "Konuşmalar" — en az bir mesaj geçmiş sohbetler, yenisi üstte.
///
/// Flock sohbetleri buraya GİRMEZ: onlara flock'un kendi ekranından girilir,
/// çünkü bir flock birkaç saatte söner — kalıcı bir kutuda durması yanıltır.
class MessagesScreen extends StatelessWidget {
  final String uid;
  const MessagesScreen({super.key, required this.uid});

  static Future<void> show(BuildContext context, String uid) =>
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => MessagesScreen(uid: uid)));

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgPage,
        elevation: 0,
        title: Text(t.chatInboxTitle, style: AppText.display(20)),
      ),
      body: SafeArea(
        top: false,
        child: ValueListenableBuilder<Set<String>>(
          valueListenable: ModerationRepository.instance.blocked,
          builder: (context, blocked, _) =>
              _Body(uid: uid, blocked: blocked),
        ),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  final String uid;
  final Set<String> blocked;
  const _Body({required this.uid, required this.blocked});

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  List<Admirer>? _matches;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    try {
      final rows = await LikesRepository.instance.incoming(widget.uid);
      if (mounted) {
        setState(() => _matches = rows.where((a) => a.mutual).toList());
      }
    } catch (_) {
      if (mounted) setState(() => _matches = const []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    return StreamBuilder<List<ChatThread>>(
      stream: ChatRepository.instance.watchDms(widget.uid),
      builder: (context, snap) {
        if (snap.hasError) return _empty(t.chatLoadFailed, '⚠️');
        final threads = (snap.data ?? const <ChatThread>[])
            .where((th) => !widget.blocked.contains(th.otherUid(widget.uid)))
            .where((th) => th.lastAt != null)
            .toList();
        final matches = _matches;

        if (matches == null && !snap.hasData) {
          return Center(child: CircularProgressIndicator(color: AppColors.brand));
        }

        // Konuşması başlamış eşleşme şeritte tekrarlanmaz.
        final started = threads.map((th) => th.otherUid(widget.uid)).toSet();
        final fresh = (matches ?? const <Admirer>[])
            .where((a) => !started.contains(a.uid))
            .where((a) => !widget.blocked.contains(a.uid))
            .toList();

        if (threads.isEmpty && fresh.isEmpty) {
          return _empty(t.chatNoMatches, '💬');
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(0, 4, 0, 24),
          children: [
            if (fresh.isNotEmpty) ...[
              _sectionTitle(t.chatNewMatches),
              _MatchStrip(meUid: widget.uid, matches: fresh),
              const SizedBox(height: 8),
            ],
            if (threads.isNotEmpty) ...[
              _sectionTitle(t.chatConversations),
              for (final th in threads)
                _ThreadRow(meUid: widget.uid, thread: th),
            ] else
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Text(t.chatNoConversations,
                    style: AppText.body(13, color: AppColors.textFaint)),
              ),
          ],
        );
      },
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
        child: Text(text,
            style: AppText.body(12,
                weight: FontWeight.w800, color: AppColors.textMuted)),
      );

  Widget _empty(String text, String emoji) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 42),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(emoji, style: const TextStyle(fontSize: 34)),
            const SizedBox(height: 12),
            Text(text,
                textAlign: TextAlign.center,
                style: AppText.body(14, color: AppColors.textMuted)),
          ]),
        ),
      );
}

/// Henüz yazışılmamış eşleşmeler — yatay şerit.
class _MatchStrip extends StatelessWidget {
  final String meUid;
  final List<Admirer> matches;
  const _MatchStrip({required this.meUid, required this.matches});

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    return SizedBox(
      height: 106,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: matches.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final a = matches[i];
          return TapTarget(
            onTap: () => ChatScreen.openDm(
              context,
              meUid: meUid,
              peerUid: a.uid,
              peerName: a.name,
              subtitle: t.chatMutualSubtitle,
            ),
            child: SizedBox(
              width: 66,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Marka halkası: "yeni" olduğunu renkle söyler, ekstra rozet
                // koymadan.
                Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.brand, width: 2),
                  ),
                  child: FutureBuilder<String?>(
                    initialData:
                        UserProfileRepository.instance.cachedPhoto(a.uid),
                    future:
                        UserProfileRepository.instance.fetchPhotoB64(a.uid),
                    builder: (_, snap) => FlockAvatar(
                        name: a.name, size: 56, photoB64: snap.data),
                  ),
                ),
                const SizedBox(height: 6),
                Text(a.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(11.5,
                        weight: FontWeight.w600, color: AppColors.textMuted)),
              ]),
            ),
          );
        },
      ),
    );
  }
}

/// Tek konuşma satırı.
class _ThreadRow extends StatelessWidget {
  final String meUid;
  final ChatThread thread;
  const _ThreadRow({required this.meUid, required this.thread});

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    final other = thread.otherUid(meUid);
    final unread = thread.unreadFor(meUid);

    return FutureBuilder<String>(
      initialData: UserProfileRepository.instance.cachedName(other),
      future: UserProfileRepository.instance.fetchName(other),
      builder: (context, snap) {
        final name = snap.data ?? '';
        return InkWell(
          onTap: () => ChatScreen.openDm(
            context,
            meUid: meUid,
            peerUid: other,
            peerName: name,
            subtitle: t.chatMutualSubtitle,
            // Okunmuş sohbete girmek okundu damgasını yeniden yazmayı hak
            // etmiyor; durumu burada zaten biliyoruz.
            alreadySeen: !unread,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
            child: Row(children: [
              FutureBuilder<String?>(
                initialData: UserProfileRepository.instance.cachedPhoto(other),
                future: UserProfileRepository.instance.fetchPhotoB64(other),
                builder: (_, p) =>
                    FlockAvatar(name: name, size: 50, photoB64: p.data),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          child: Text(name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.body(15,
                                  weight: unread
                                      ? FontWeight.w800
                                      : FontWeight.w700,
                                  color: AppColors.textStrong)),
                        ),
                        if (thread.lastAt != null)
                          Text(_stamp(context, thread.lastAt!),
                              style: AppText.body(11,
                                  color: unread
                                      ? AppColors.brand
                                      : AppColors.textFaint)),
                      ]),
                      const SizedBox(height: 3),
                      Row(children: [
                        Expanded(
                          child: Text(
                            // Kendi mesajını "Sen:" ile işaretlemek, sıranın
                            // kimde olduğunu bir bakışta söyler.
                            thread.lastFrom == meUid
                                ? '${t.chatYou}: ${thread.lastText}'
                                : thread.lastText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.body(13,
                                weight: unread
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: unread
                                    ? AppColors.textBody
                                    : AppColors.textFaint),
                          ),
                        ),
                        if (unread) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                                color: AppColors.brand, shape: BoxShape.circle),
                          ),
                        ],
                      ]),
                    ]),
              ),
            ]),
          ),
        );
      },
    );
  }

  /// Bugünse saat, dünse "Dün", eskiyse tarih.
  static String _stamp(BuildContext context, DateTime d) {
    final t = AppL10n.of(context);
    final now = DateTime.now();
    bool same(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;
    if (same(d, now)) {
      return '${d.hour.toString().padLeft(2, '0')}:'
          '${d.minute.toString().padLeft(2, '0')}';
    }
    if (same(d, now.subtract(const Duration(days: 1)))) return t.chatYesterday;
    return '${d.day.toString().padLeft(2, '0')}.'
        '${d.month.toString().padLeft(2, '0')}';
  }
}
