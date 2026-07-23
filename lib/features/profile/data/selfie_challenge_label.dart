import '../../../core/services/image_util.dart';
import '../../../l10n/app_localizations.dart';

/// Rastgele selfie pozunun yerelleştirilmiş talimatı (onboarding + kapı ortak).
String selfieChallengeLabel(AppL10n t, SelfieChallenge c) => switch (c) {
      SelfieChallenge.smile => t.obSelfieChSmile,
      SelfieChallenge.turnHead => t.obSelfieChTurn,
      SelfieChallenge.tiltHead => t.obSelfieChTilt,
    };
