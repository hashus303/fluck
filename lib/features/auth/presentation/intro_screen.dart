import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/flock_widgets.dart';
import '../../../l10n/app_localizations.dart';

/// Kayıt öncesi karşılama — konsepti 3 slaytta satar, sonra auth ekranına geçer.
/// Yalnızca ilk açılışta gösterilir (main.dart 'seen_intro' bayrağını tutar).
class IntroScreen extends StatefulWidget {
  final VoidCallback onDone;
  const IntroScreen({super.key, required this.onDone});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final _pc = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _next() {
    if (_page >= 2) {
      widget.onDone();
    } else {
      _pc.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    final slides = [
      ('👋', t.introSlide1Title, t.introSlide1Body),
      ('🎲', t.introSlide2Title, t.introSlide2Body),
      ('🛡️', t.introSlide3Title, t.introSlide3Body),
    ];
    final last = _page == slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Column(children: [
          // Atla — son slaytta gizle.
          SizedBox(
            height: 48,
            child: Align(
              alignment: Alignment.centerRight,
              child: AnimatedOpacity(
                opacity: last ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: TextButton(
                  onPressed: last ? null : widget.onDone,
                  child: Text(t.introSkip,
                      style: AppText.body(14, weight: FontWeight.w700, color: AppColors.textMuted)),
                ),
              ),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pc,
              itemCount: slides.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (_, i) {
                final (emoji, title, body) = slides[i];
                return _Slide(emoji: emoji, title: title, body: body);
              },
            ),
          ),
          // Nokta göstergesi
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (var i = 0; i < slides.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _page ? 22 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: i == _page ? AppColors.brand : AppColors.borderStrong,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
            child: FlockButton(
              label: last ? t.introStart : t.introNext,
              full: true,
              onPressed: _next,
            ),
          ),
        ]),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  final String emoji, title, body;
  const _Slide({required this.emoji, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 128,
          height: 128,
          decoration: BoxDecoration(
            color: AppColors.brandSoft,
            shape: BoxShape.circle,
            boxShadow: AppColors.glowCoral,
          ),
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 60)),
        ),
        const SizedBox(height: 40),
        Text(title,
            textAlign: TextAlign.center,
            style: AppText.display(30)),
        const SizedBox(height: 14),
        Text(body,
            textAlign: TextAlign.center,
            style: AppText.body(15.5, color: AppColors.textMuted)),
      ]),
    );
  }
}
