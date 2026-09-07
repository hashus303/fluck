import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/flock_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../profile/data/user_profile_repository.dart';
import '../../safety/data/moderation_repository.dart';
import '../data/chat_repository.dart';

/// Bir sohbet. DM ve flock sohbeti aynı ekranı kullanır; fark yalnızca
/// başlıkta, gönderen adının gösterilip gösterilmemesinde ve DM'e özel
/// şikayet/engelle menüsünde.
class ChatScreen extends StatefulWidget {
  final String threadId;
  final String meUid;
  final String title;
  final String? subtitle;

  /// Sohbet belgesi ilk mesajda bu tohumla açılır.
  final Map<String, dynamic> seed;

  /// DM'de karşı taraf — şikayet/engelle için. Flock sohbetinde null.
  final String? peerUid;

  /// Flock sohbetinde uid → ad; balonun üstündeki gönderen adı buradan gelir.
  final Map<String, String> names;

  /// Süresi dolmuş flock: geçmiş okunur ama yeni mesaj yazılmaz.
  final bool closed;

  const ChatScreen({
    super.key,
    required this.threadId,
    required this.meUid,
    required this.title,
    required this.seed,
    this.subtitle,
    this.peerUid,
    this.names = const {},
    this.closed = false,
  });

  static Future<void> openDm(
    BuildContext context, {
    required String meUid,
    required String peerUid,
    required String peerName,
    String? subtitle,
  }) {
    return Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ChatScreen(
        threadId: ChatRepository.dmId(meUid, peerUid),
        meUid: meUid,
        title: peerName,
        subtitle: subtitle,
        peerUid: peerUid,
        seed: ChatRepository.dmSeed(meUid, peerUid),
      ),
    ));
  }

  static Future<void> openFlock(
    BuildContext context, {
    required String meUid,
    required String flockId,
    required String title,
    String? subtitle,
    Map<String, String> names = const {},
    bool closed = false,
  }) {
    return Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ChatScreen(
        threadId: ChatRepository.flockThreadId(flockId),
        meUid: meUid,
        title: title,
        subtitle: subtitle,
        names: names,
        closed: closed,
        seed: ChatRepository.flockSeed(flockId),
      ),
    ));
  }

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  bool _sending = false;
  bool _seen = false;

  /// Ekranı açmak "okudum" demektir; rozet hemen düşsün.
  ///
  /// Ama İLK mesajdan önce değil: sohbet belgesi henüz yokken okundu damgası
  /// yazmaya çalışmak kuralca reddedilir — zararsız ama her açılışta boşa bir
  /// yazma ve kayıtlarda sahte bir "PERMISSION_DENIED" demek.
  void _markSeenOnce() {
    if (_seen) return;
    _seen = true;
    ChatRepository.instance.markSeen(widget.threadId, widget.meUid);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _sending) return;
    final t = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _sending = true);
    // Alanı hemen boşalt: yerel önbellek mesajı zaten anında listeye koyar,
    // bekleyen bir metin kutusu "gitmedi mi?" hissi verir.
    _ctrl.clear();
    try {
      await ChatRepository.instance.send(
        threadId: widget.threadId,
        from: widget.meUid,
        text: text,
        seed: widget.seed,
      );
    } catch (_) {
      if (mounted) {
        _ctrl.text = text; // kaybolmasın, tekrar denesin
        messenger.showSnackBar(SnackBar(content: Text(t.chatSendFailed)));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgPage,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        titleSpacing: 0,
        title: Row(children: [
          if (widget.peerUid != null)
            FutureBuilder<String?>(
              initialData:
                  UserProfileRepository.instance.cachedPhoto(widget.peerUid!),
              future:
                  UserProfileRepository.instance.fetchPhotoB64(widget.peerUid!),
              builder: (_, snap) =>
                  FlockAvatar(name: widget.title, size: 34, photoB64: snap.data),
            )
          else
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                  color: AppColors.brandSoft, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Icon(Icons.groups_rounded,
                  size: 19, color: AppColors.brandHover),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(15.5,
                        weight: FontWeight.w800, color: AppColors.textStrong)),
                if (widget.subtitle != null)
                  Text(widget.subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.body(11.5, color: AppColors.textFaint)),
              ],
            ),
          ),
        ]),
        actions: [
          if (widget.peerUid != null)
            IconButton(
              icon: Icon(Icons.more_vert_rounded, color: AppColors.textMuted),
              tooltip: t.chatMore,
              onPressed: _peerActions,
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: ChatRepository.instance.watchMessages(widget.threadId),
              builder: (context, snap) {
                if (snap.hasError) return _center(t.chatLoadFailed);
                final msgs = snap.data;
                if (msgs == null) {
                  return Center(
                      child: CircularProgressIndicator(color: AppColors.brand));
                }
                if (msgs.isEmpty) return _center(t.chatEmptyThread);
                // Mesaj varsa sohbet belgesi de vardır: okundu damgası artık
                // yazılabilir. Çizim sırasında yazmamak için kare sonrasına
                // bırakılıyor.
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _markSeenOnce());
                return ListView.builder(
                  // Ters liste: yeni mesaj gelince kendiliğinden alta yapışır,
                  // ayrıca kaydırma denetleyicisiyle konum kovalamak gerekmez.
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                  itemCount: msgs.length,
                  itemBuilder: (context, i) {
                    final m = msgs[i];
                    // Ters listede "bir önceki mesaj" bir sonraki indekstir.
                    final older = i + 1 < msgs.length ? msgs[i + 1] : null;
                    final newer = i > 0 ? msgs[i - 1] : null;
                    return _Bubble(
                      msg: m,
                      mine: m.from == widget.meUid,
                      // Ad ve boşluk yalnızca konuşmacı DEĞİŞTİĞİNDE: arka
                      // arkaya mesajlar tek bir söz gibi okunsun.
                      startsGroup: older == null || older.from != m.from,
                      endsGroup: newer == null || newer.from != m.from,
                      showName: widget.peerUid == null && m.from != widget.meUid,
                      name: widget.names[m.from] ?? '',
                      daySeparator: _dayLabel(context, m.at, older?.at),
                      onDelete: m.from == widget.meUid
                          ? () => ChatRepository.instance
                              .deleteMessage(widget.threadId, m.id)
                          : null,
                    );
                  },
                );
              },
            ),
          ),
          if (widget.closed)
            _ClosedNote(text: t.chatFlockClosed)
          else
            _Composer(
              controller: _ctrl,
              focusNode: _focus,
              sending: _sending,
              onSend: _send,
            ),
        ]),
      ),
    );
  }

  Widget _center(String text) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(text,
              textAlign: TextAlign.center,
              style: AppText.body(13.5, color: AppColors.textFaint)),
        ),
      );

  /// Gün ayracı — mesaj bir öncekinden farklı bir güne aitse.
  String? _dayLabel(BuildContext context, DateTime? at, DateTime? prev) {
    if (at == null) return null;
    if (prev != null && _sameDay(at, prev)) return null;
    final t = AppL10n.of(context);
    final now = DateTime.now();
    if (_sameDay(at, now)) return t.chatToday;
    if (_sameDay(at, now.subtract(const Duration(days: 1)))) {
      return t.chatYesterday;
    }
    return '${_two(at.day)}.${_two(at.month)}.${at.year}';
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
  static String _two(int n) => n < 10 ? '0$n' : '$n';

  /// DM'de şikayet / engelle — Play'in UGC şartı sohbette de karşılanmalı:
  /// taciz en çok burada olur.
  Future<void> _peerActions() async {
    final peer = widget.peerUid;
    if (peer == null) return;
    final t = AppL10n.of(context);
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          Text(widget.title, style: AppText.body(15, weight: FontWeight.w800)),
          const SizedBox(height: 4),
          ListTile(
            leading: Icon(Icons.flag_outlined, color: AppColors.warning),
            title: Text(t.reportUser,
                style: AppText.body(15, weight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(ctx);
              _report(peer);
            },
          ),
          ListTile(
            leading: Icon(Icons.block, color: AppColors.danger),
            title: Text(t.blockUser,
                style: AppText.body(15, weight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(ctx);
              _block(peer);
            },
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  Future<void> _report(String peer) async {
    final t = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    const reasons = ['harassment', 'fake', 'safety', 'other'];
    String label(String r) => switch (r) {
          'harassment' => t.reportReasonHarassment,
          'fake' => t.reportReasonFake,
          'safety' => t.reportReasonSafety,
          _ => t.reportReasonOther,
        };
    final reason = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 12),
          Text(t.reportTitle, style: AppText.body(15, weight: FontWeight.w800)),
          const SizedBox(height: 4),
          for (final r in reasons)
            ListTile(
              dense: true,
              title: Text(label(r),
                  style: AppText.body(14.5, weight: FontWeight.w600)),
              onTap: () => Navigator.pop(ctx, r),
            ),
          const SizedBox(height: 8),
        ]),
      ),
    );
    if (reason == null || !mounted) return;
    try {
      await ModerationRepository.instance.report(
        reporterUid: widget.meUid,
        reportedUid: peer,
        reason: reason,
      );
      messenger.showSnackBar(SnackBar(content: Text(t.reportThanks)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(t.errGeneric)));
    }
  }

  Future<void> _block(String peer) async {
    final t = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.blockConfirmTitle),
        content: Text(t.blockConfirmBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false), child: Text(t.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child:
                  Text(t.blockUser, style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (ok != true) return;
    await ModerationRepository.instance.block(widget.meUid, peer);
    messenger.showSnackBar(SnackBar(content: Text(t.blockDone)));
    // Engellediğin kişinin sohbetinde kalmak anlamsız.
    navigator.pop();
  }
}

/// Tek mesaj balonu.
class _Bubble extends StatelessWidget {
  final ChatMessage msg;
  final bool mine;
  final bool startsGroup;
  final bool endsGroup;
  final bool showName;
  final String name;
  final String? daySeparator;
  final VoidCallback? onDelete;

  const _Bubble({
    required this.msg,
    required this.mine,
    required this.startsGroup,
    required this.endsGroup,
    required this.showName,
    required this.name,
    this.daySeparator,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    const r = Radius.circular(18);
    const tight = Radius.circular(6);
    // Grubun İÇ köşeleri sivri kalır: art arda balonlar tek blok gibi okunur,
    // mesajın kime ait olduğu renge bakmadan şekilden anlaşılır.
    final shape = BorderRadius.only(
      topLeft: mine || startsGroup ? r : tight,
      topRight: !mine || startsGroup ? r : tight,
      bottomLeft: mine || endsGroup ? r : tight,
      bottomRight: !mine || endsGroup ? r : tight,
    );

    final bubble = Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.76),
      padding: const EdgeInsets.fromLTRB(13, 9, 13, 9),
      decoration: BoxDecoration(
        color: mine ? AppColors.brand : AppColors.surfaceCard,
        borderRadius: shape,
        border: mine ? null : Border.all(color: AppColors.borderSubtle),
      ),
      child: Text(
        msg.text,
        style: AppText.body(14.5,
            color: mine ? AppColors.onBrand : AppColors.textBody),
      ),
    );

    return Column(
      crossAxisAlignment:
          mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (daySeparator != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SizedBox(
              width: double.infinity,
              child: Text(daySeparator!,
                  textAlign: TextAlign.center,
                  style: AppText.body(11.5, color: AppColors.textFaint)),
            ),
          ),
        if (showName && startsGroup && name.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 3, top: 4),
            child: Text(name,
                style: AppText.body(11.5,
                    weight: FontWeight.w700, color: AppColors.textMuted)),
          ),
        Padding(
          padding: EdgeInsets.only(bottom: endsGroup ? 4 : 2),
          child: Semantics(
            label: mine ? '${t.chatYou}: ${msg.text}' : '$name ${msg.text}',
            child: GestureDetector(
              onLongPress: onDelete == null
                  ? null
                  : () => _messageActions(context, msg.text, onDelete!),
              child: bubble,
            ),
          ),
        ),
        // Saat yalnızca grubun sonunda: her balona koyunca gürültü oluyor.
        if (endsGroup && msg.at != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 6, right: 6),
            child: Text(_clock(msg.at!),
                style: AppText.body(10.5, color: AppColors.textFaint)),
          ),
      ],
    );
  }

  static String _clock(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  Future<void> _messageActions(
      BuildContext context, String text, VoidCallback onDelete) async {
    final t = AppL10n.of(context);
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          ListTile(
            leading: Icon(Icons.copy_rounded, color: AppColors.textMuted),
            title: Text(t.chatCopy,
                style: AppText.body(15, weight: FontWeight.w600)),
            onTap: () {
              Clipboard.setData(ClipboardData(text: text));
              Navigator.pop(ctx);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_outline_rounded, color: AppColors.danger),
            title: Text(t.chatDelete,
                style: AppText.body(15, weight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(ctx);
              onDelete();
            },
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}

/// Yazma çubuğu.
class _Composer extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool sending;
  final VoidCallback onSend;
  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.sending,
    required this.onSend,
  });

  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  @override
  void initState() {
    super.initState();
    // Gönder düğmesinin etkinliği metne bağlı; her tuşta yeniden çizilsin.
    widget.controller.addListener(_onText);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onText);
    super.dispose();
  }

  void _onText() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    final canSend = widget.controller.text.trim().isNotEmpty && !widget.sending;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.bgPage,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              minLines: 1,
              maxLines: 5,
              maxLength: ChatRepository.maxLength,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.newline,
              style: AppText.body(14.5, color: AppColors.textBody),
              decoration: InputDecoration(
                // Yüzen etiket DEĞİL ipucu: alan tek satır yüksekliğinde,
                // etiket yüzünce kutu zıplar. Erişilebilirlik adını dıştaki
                // Semantics veriyor.
                hintText: t.chatComposerHint,
                hintStyle: AppText.body(14.5, color: AppColors.textFaint),
                border: InputBorder.none,
                counterText: '',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 11),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Semantics(
          button: true,
          label: t.chatSend,
          child: Material(
            color: canSend ? AppColors.brand : AppColors.surfaceSunken,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: canSend ? widget.onSend : null,
              child: SizedBox(
                width: 46,
                height: 46,
                child: Icon(Icons.arrow_upward_rounded,
                    size: 21,
                    color: canSend ? AppColors.onBrand : AppColors.textFaint),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

/// Süresi dolmuş flock: yazma çubuğu yerine açıklama.
class _ClosedNote extends StatelessWidget {
  final String text;
  const _ClosedNote({required this.text});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
        decoration: BoxDecoration(
          color: AppColors.surfaceSunken,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: Text(text,
            textAlign: TextAlign.center,
            style: AppText.body(12.5, color: AppColors.textMuted)),
      );
}
