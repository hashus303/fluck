// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navMap => 'Map';

  @override
  String get navSafety => 'Safety';

  @override
  String get navProfile => 'Profile';

  @override
  String flocksLiveNearYou(int count) {
    return '$count flocks live near you';
  }

  @override
  String get findYourFlock => 'Find your flock';

  @override
  String get homeSubtitle => 'Skip the planning — pick a vibe, join, go.';

  @override
  String get allVibes => 'All vibes';

  @override
  String get surpriseMe => 'Surprise me';

  @override
  String get surpriseTitle => 'Your fate flock';

  @override
  String get surpriseSubtitle =>
      'The dice picked this one — the rest is on you.';

  @override
  String get spinAgain => 'Roll again';

  @override
  String get surpriseNone => 'Nothing to roll right now — start one ✦';

  @override
  String get vibeCoffee => 'Coffee';

  @override
  String get vibeBar => 'Bar';

  @override
  String get vibeWalk => 'Walk';

  @override
  String get vibeGames => 'Games';

  @override
  String get vibeFood => 'Food';

  @override
  String get vibeMusic => 'Music';

  @override
  String isHosting(String host) {
    return '$host is hosting';
  }

  @override
  String joinedCount(int joined, int total) {
    return '$joined/$total joined';
  }

  @override
  String timeLeft(String label) {
    return '$label left';
  }

  @override
  String get join => 'Join';

  @override
  String get joinedBadge => 'Joined ✓';

  @override
  String get flockFull => 'Flock full';

  @override
  String get noFlocksForVibe => 'No flocks for this vibe yet — start one ✦';

  @override
  String get safetyTitle => 'You\'re covered';

  @override
  String get safetySubtitle =>
      'Trust runs quietly in the background so going out feels easy.';

  @override
  String get safetyLede =>
      'Your verification status and the people you\'ve blocked.';

  @override
  String get blockedTitle => 'Blocked people';

  @override
  String blockedCount(int n) {
    return '$n blocked';
  }

  @override
  String get blockedEmpty => 'You haven\'t blocked anyone.';

  @override
  String get blockedEmptyHint =>
      'You can block someone from their flock — they\'ll disappear from your feed.';

  @override
  String get unblock => 'Unblock';

  @override
  String get unblockDone => 'Unblocked.';

  @override
  String get identityVerified => 'Identity verified';

  @override
  String get verified => 'Verified';

  @override
  String get idConfirmed => 'ID + selfie confirmed · Mar 2026';

  @override
  String get yourTrustScore => 'YOUR TRUST SCORE';

  @override
  String get trusted => 'Trusted';

  @override
  String get trustScoreNote =>
      'Built from verified ID, on-time flocks, and good ratings.';

  @override
  String get featGroupTitle => 'Group-only meetups';

  @override
  String get featGroupDesc => 'You always meet 3+ people — never one-on-one.';

  @override
  String get featLocationTitle => 'Live location sharing';

  @override
  String get featLocationDesc =>
      'Shared with your flock only, for the 2h window.';

  @override
  String get featRatingsTitle => 'Two-way ratings';

  @override
  String get featRatingsDesc =>
      'Everyone rates after — low scores get filtered out.';

  @override
  String get statTrust => 'Trust';

  @override
  String get statFlocks => 'Flocks';

  @override
  String get statRating => 'Rating';

  @override
  String get pastFlocks => 'PAST FLOCKS';

  @override
  String get profileHandle => '@jvale · joined Mar 2026';

  @override
  String get regularFlocker => 'Regular flocker';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountTitle => 'Delete your account?';

  @override
  String get deleteAccountBody =>
      'Your profile and notifications are permanently deleted. This cannot be undone.';

  @override
  String get deleteAccountReauth =>
      'For security you must have signed in recently — sign out, sign in again, then retry.';

  @override
  String get cancel => 'Cancel';

  @override
  String peopleCount(int count) {
    return '$count people';
  }

  @override
  String get whenYesterday => 'Yesterday';

  @override
  String get whenLastWeek => 'Last week';

  @override
  String get whenTwoWeeks => '2 weeks ago';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get startAFlock => 'Start a flock';

  @override
  String get pickAVibe => 'PICK A VIBE';

  @override
  String get where => 'WHERE';

  @override
  String get groupSize => 'GROUP SIZE';

  @override
  String get minThree => 'Minimum 3 people — Flock is group-only.';

  @override
  String get howLong => 'HOW LONG IS IT LIVE?';

  @override
  String get duration30m => '30 min';

  @override
  String get duration1h => '1 hour';

  @override
  String get duration2h => '2 hours';

  @override
  String expiryNoteFor(String label) {
    return 'Your invite goes live instantly and expires in $label.';
  }

  @override
  String get pickVenueFirst => 'Pick a venue to continue';

  @override
  String get venueNameHint => 'Venue name (e.g. Moda Pier)';

  @override
  String get venueSearchHint => 'Search a place…';

  @override
  String get venuePinHint => 'Pan the map so the pin sits on your venue';

  @override
  String get venueNameRequired => 'Enter a venue name';

  @override
  String postInviteFor(String label) {
    return 'Post invite · live for $label';
  }

  @override
  String inviteLiveFor(String label) {
    return 'Your invite is live for $label 🎉';
  }

  @override
  String locWithin(Object km) {
    return 'within $km km';
  }

  @override
  String get locAnywhere => 'Anywhere';

  @override
  String get locNoneInRange => 'No flocks in range — widen the radius.';

  @override
  String get locChangeHint => 'Location (GPS soon)';

  @override
  String get locMyLocation => 'My location';

  @override
  String get locUseGps => 'Use my location';

  @override
  String get locGpsFailed => 'Couldn\'t get location — try again.';

  @override
  String get locServiceOff =>
      'Location is off — turn on your phone\'s location.';

  @override
  String get locPermDenied => 'Location permission denied.';

  @override
  String get locPermDeniedForever =>
      'Location permission is off — enable it in Settings.';

  @override
  String get locOpenSettings => 'Open Settings';

  @override
  String get introSlide1Title => 'Skip the planning.';

  @override
  String get introSlide1Body =>
      'Open Flock, see live invites nearby, join a group in one tap — coffee, a walk, a game.';

  @override
  String get introSlide2Title => 'Can\'t decide? Roll.';

  @override
  String get introSlide2Body =>
      'The dice picks a random flock near you. Zero overthinking — just show up.';

  @override
  String get introSlide3Title => 'Always a group. Verified people.';

  @override
  String get introSlide3Body =>
      'Never one-on-one — every flock is 3+ people. Everyone\'s confirmed with a selfie.';

  @override
  String get introSkip => 'Skip';

  @override
  String get introNext => 'Next';

  @override
  String get introStart => 'Get started';

  @override
  String get navDiscover => 'Discover';

  @override
  String get discoverTitle => 'Discover';

  @override
  String get discoverLede => 'What is happening around you right now.';

  @override
  String get discoverRollTitle => 'Roll the dice';

  @override
  String get discoverRollBody =>
      'Let fate pick a flock near you — one tap to join.';

  @override
  String get discoverDateTitle => 'Date mode';

  @override
  String get discoverDateBody =>
      'Swipe through verified people nearby who want to meet.';

  @override
  String get discoverNearbyTitle => 'People nearby';

  @override
  String get discoverNearbyBody =>
      'See verified people around you and invite them to your flock.';

  @override
  String get discoverByVibe => 'Browse by vibe';

  @override
  String discoverPulseLive(int n) {
    return '$n flocks live near you';
  }

  @override
  String get discoverPulseNone =>
      'Nothing live yet — be the first to start one.';

  @override
  String get discoverStartOne => 'Start a flock';

  @override
  String get plusBadge => 'Flock+';

  @override
  String get navDate => 'Date';

  @override
  String get dateTitle => 'Date mode';

  @override
  String get dateLede => 'Verified people nearby — invite them to your flock.';

  @override
  String get dateLockedTitle => 'Discover people, not just flocks';

  @override
  String get dateLockedBody =>
      'Browse verified people around you and invite the ones you like to your flock. Every meetup stays a group — 3 people minimum.';

  @override
  String get dateUnlockCta => 'Unlock with Flock+';

  @override
  String get dateSoonTitle => 'Your deck is being built';

  @override
  String get dateSoonBody =>
      'Browsing opens shortly — as a Flock+ member you get it first.';

  @override
  String get plusTitle => 'Flock+';

  @override
  String get plusTagline => 'Meet more people, more often.';

  @override
  String get plusTrialBadge => 'First 14 days free';

  @override
  String get plusPriceLine => 'Then ₺99/month. Cancel anytime.';

  @override
  String get plusFeatureNearbyTitle => 'See who liked you';

  @override
  String get plusFeatureNearbyBody =>
      'Find out who wants to flock with you — and invite them back.';

  @override
  String get plusFeatureDateTitle => 'Date mode';

  @override
  String get plusFeatureDateBody =>
      'Browse verified people nearby and invite the ones you like to your flock.';

  @override
  String get plusFeatureUnlimitedTitle => 'Unlimited flocks + boost';

  @override
  String get plusFeatureUnlimitedBody =>
      'Create as many as you like and push yours to the top.';

  @override
  String get plusFeatureFiltersTitle => 'Advanced filters';

  @override
  String get plusFeatureFiltersBody =>
      'Verified-only mode, vibe and distance filters.';

  @override
  String get plusCta => 'Start free trial';

  @override
  String get plusHonestNote =>
      'We remind you 24h before the trial ends — by push and email. One tap to cancel.';

  @override
  String get plusRestore => 'Restore purchase';

  @override
  String get plusActiveTitle => 'Flock+ is active';

  @override
  String plusTrialActiveTitle(int days) {
    return 'Flock+ trial — $days days left';
  }

  @override
  String get plusManage => 'Manage subscription';

  @override
  String get plusLockedTitle => 'Flock+ feature';

  @override
  String get plusLockedBody => 'Unlock this with Flock+ — first 14 days free.';

  @override
  String get plusSoon => 'Subscriptions open soon — you will be first to know.';

  @override
  String get authTitle => 'Stop wandering alone.';

  @override
  String get authSubtitle =>
      'Pick a vibe, join a flock nearby, and go. Three people minimum, real venues, two-hour window — safety built into every step.';

  @override
  String get continuePhone => 'Continue with phone';

  @override
  String get continueEmail => 'Continue with email';

  @override
  String get authFootnote =>
      'Verified identity & trust scores keep flocks safe.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get passwordConfirm => 'Confirm password';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get passwordHint => 'At least 6 characters';

  @override
  String get passwordConfirmHint => 'Re-enter your password';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Sign up';

  @override
  String get createAccount => 'Create account';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInSubtitle => 'Sign in to find your flock.';

  @override
  String get signUpSubtitle => 'Join Flock — it only takes a second.';

  @override
  String get noAccountSignUp => 'Don\'t have an account? Sign up';

  @override
  String get haveAccountSignIn => 'Already have an account? Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get orDivider => 'or';

  @override
  String get errEmailRequired => 'Enter your email';

  @override
  String get errEmailInvalid => 'Enter a valid email';

  @override
  String get errPasswordRequired => 'Enter your password';

  @override
  String get errPasswordShort => 'Password must be at least 6 characters';

  @override
  String get errPasswordConfirmRequired => 'Re-enter your password';

  @override
  String get errPasswordMismatch => 'Passwords don\'t match';

  @override
  String get errInvalidCredentials => 'Wrong email or password';

  @override
  String get errEmailInUse => 'This email is already registered';

  @override
  String get errWeakPassword => 'Password is too weak';

  @override
  String get errNetwork => 'Network error — check your connection';

  @override
  String get errGoogleReauth =>
      'Your Google account couldn’t approve this sign-in. You can sign in with email for now.';

  @override
  String get errGoogleNoAccount =>
      'No Google account on this phone. Add one in Settings, or sign in with email.';

  @override
  String get errGoogleConfig =>
      'Google sign-in isn\'t available in this build. You can sign in with email for now.';

  @override
  String get errGoogleInterrupted =>
      'Google sign-in was interrupted. Check your connection and try again.';

  @override
  String get errGoogleGeneric =>
      'Couldn\'t sign in with Google. Try again, or sign in with email.';

  @override
  String get a11yBack => 'Back';

  @override
  String get a11yClose => 'Close';

  @override
  String get a11yShowPassword => 'Show password';

  @override
  String get a11yHidePassword => 'Hide password';

  @override
  String get a11yNotifications => 'Notifications';

  @override
  String a11yUnreadCount(int count) {
    return '$count unread notifications';
  }

  @override
  String get a11yMyLocation => 'Go to my location';

  @override
  String get a11ySearchPlace => 'Search for a place';

  @override
  String a11yRateStars(int count) {
    return 'Rate $count stars';
  }

  @override
  String get a11yChangePhoto => 'Change profile photo';

  @override
  String get a11yPickPhoto => 'Pick a photo';

  @override
  String a11yAvatarOf(String name) {
    return '$name\'s profile photo';
  }

  @override
  String get a11yAppLogo => 'Flock logo';

  @override
  String get offlineBanner => 'No internet — check your connection';

  @override
  String get offlineRetry => 'Retry';

  @override
  String get notifSection => 'Notifications';

  @override
  String get notifJoins => 'Flock activity';

  @override
  String get notifJoinsBody => 'When someone joins your flock';

  @override
  String get notifMessages => 'Messages';

  @override
  String get notifMessagesBody => 'When someone messages you';

  @override
  String get notifAnnouncements => 'Announcements';

  @override
  String get notifAnnouncementsBody => 'News from the Flock team';

  @override
  String get notifVerification => 'Verification result';

  @override
  String get notifVerificationBody => 'When your selfie check is decided';

  @override
  String get notifAllOffHint =>
      'Turn everything off and you\'ll still see it in the app.';

  @override
  String get dateOptInTitle => 'Turn on Date mode';

  @override
  String get dateOptInBody =>
      'Turn it on and you appear in the deck too — no browsing without being browsed. Only verified accounts see each other.';

  @override
  String get dateOptInPrivacy =>
      'Your location is rounded to about 1 km; your exact address is never shared. Turn it off and your location is deleted.';

  @override
  String get dateOptInCta => 'Show me too';

  @override
  String get dateOptOut => 'Leave Date mode';

  @override
  String get datePass => 'Pass';

  @override
  String get dateLike => 'Like';

  @override
  String get dateSwipeHint => 'Swipe right to like, left to pass';

  @override
  String get dateUnder1Km => 'under 1 km';

  @override
  String get dateEmptyTitle => 'That\'s everyone for now';

  @override
  String get dateEmptyBody =>
      'No one new around you right now. More people join every day — check back soon.';

  @override
  String get dateDeckRefresh => 'Refresh';

  @override
  String get dateDeckRetry => 'Couldn\'t load the deck.';

  @override
  String dateMutual(String name) {
    return '$name liked you back — you can message each other now.';
  }

  @override
  String get dateMutualCta => 'Message';

  @override
  String get plusSheetLede => 'Who liked you, and your subscription.';

  @override
  String get plusAdmirersTitle => 'Liked you';

  @override
  String get plusAdmirersEmpty =>
      'No one yet. Keep browsing the deck — anyone who likes you shows up here.';

  @override
  String get plusAdmirersError =>
      'Couldn\'t load the list. Check your connection and reopen.';

  @override
  String get plusLikedYouHint => 'Liked you';

  @override
  String get plusMutualHint =>
      'You both liked each other — you can message now.';

  @override
  String get plusMutualBadge => 'Mutual';

  @override
  String get plusLikeBack => 'Like back';

  @override
  String get plusStatusTitle => 'Your subscription';

  @override
  String get plusMessagesRow => 'Messages';

  @override
  String get plusMessagesRowHint => 'Chat with your mutual likes';

  @override
  String get plusOpenHint => 'Hold the heart';

  @override
  String get chatInboxTitle => 'Messages';

  @override
  String get chatOpen => 'Messages';

  @override
  String get chatNewMatches => 'NEW MATCHES';

  @override
  String get chatConversations => 'CONVERSATIONS';

  @override
  String get chatNoConversations =>
      'No chats yet. Say the first word to someone above.';

  @override
  String get chatNoMatches =>
      'No matches yet. Like people in the deck — when it\'s mutual, you meet here.';

  @override
  String get chatEmptyThread => 'Nothing here yet. Say the first word.';

  @override
  String get chatComposerHint => 'Write a message…';

  @override
  String get chatSend => 'Send';

  @override
  String get chatSendFailed => 'Message not sent. Check your connection.';

  @override
  String get chatLoadFailed =>
      'Couldn\'t load the chat. Check your connection and reopen.';

  @override
  String get chatToday => 'Today';

  @override
  String get chatYesterday => 'Yesterday';

  @override
  String get chatYou => 'You';

  @override
  String get chatCopy => 'Copy';

  @override
  String get chatDelete => 'Delete message';

  @override
  String get chatMore => 'Options';

  @override
  String get chatMutualSubtitle => 'You liked each other';

  @override
  String get chatFlockCta => 'Chat';

  @override
  String get chatFlockJoinFirst => 'Join the flock to chat';

  @override
  String get chatFlockClosed =>
      'This flock has ended — the chat is closed. You can still read it.';

  @override
  String chatFlockSubtitle(int count) {
    return '$count people';
  }

  @override
  String get errGeneric => 'Something went wrong. Try again.';

  @override
  String obStep(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get obNameTitle => 'What should we call you?';

  @override
  String get obNameSubtitle => 'Use your real name — it builds trust.';

  @override
  String get obNameHint => 'Full name';

  @override
  String get obAgeTitle => 'How old are you?';

  @override
  String get obAgeSubtitle => 'You must be 18 or older to use Flock.';

  @override
  String get obAgeHint => 'Age';

  @override
  String get obAgeError => 'You must be at least 18';

  @override
  String get obInterestsTitle => 'What are you into?';

  @override
  String get obInterestsSubtitle =>
      'Pick at least 3 — we\'ll match you with the right flocks.';

  @override
  String get obPhotoTitle => 'Add a profile photo';

  @override
  String get obPhotoSubtitle => 'This is how your flock sees you.';

  @override
  String get obPhotoPick => 'Choose a photo';

  @override
  String get obPhotoChange => 'Change photo';

  @override
  String get obPhotoGallery => 'Choose from gallery';

  @override
  String get obPhotoTake => 'Take a photo';

  @override
  String get obPickFailed =>
      'Couldn\'t get the photo — check camera/gallery permission.';

  @override
  String get obSelfieNoFace =>
      'No face detected in the selfie — retake it with your face clearly visible.';

  @override
  String get obSelfieChallengeLabel => 'For verification:';

  @override
  String get obSelfieChSmile => 'smile 😊';

  @override
  String get obSelfieChTurn => 'turn your head slightly to the side ↩️';

  @override
  String get obSelfieChTilt => 'tilt your head slightly 🙂↕️';

  @override
  String obSelfieWrongPose(String pose) {
    return 'We couldn\'t see the requested move. Try again: $pose';
  }

  @override
  String get verifPendingTitle => 'Your selfie is under review';

  @override
  String get verifPendingBody =>
      'For safety, every profile is approved by a real person. It\'s usually quick — the app opens automatically once you\'re approved.';

  @override
  String get verifRejectedTitle => 'We couldn\'t verify your selfie';

  @override
  String get verifRejectedBody =>
      'Take a new selfie with your face clearly visible — it goes straight back into review.';

  @override
  String get verifRetake => 'Retake selfie';

  @override
  String get verifNeedTitle => 'One last step: verification';

  @override
  String get verifNeedBody =>
      'Take a selfie clearly showing your face to continue. The app opens once it\'s reviewed and approved.';

  @override
  String get verifResend => 'Resend selfie';

  @override
  String get notifVerifApproved => 'Your profile is verified 🎉';

  @override
  String get notifVerifRejected => 'Selfie couldn\'t be verified — try again';

  @override
  String get ratePromptTitle => 'How was it?';

  @override
  String ratePromptBody(String venue) {
    return 'Your \'$venue\' flock has ended — rate the members.';
  }

  @override
  String get rateAction => 'Rate';

  @override
  String get rateSkip => 'Not now';

  @override
  String get rateThanks => 'Thanks! Your ratings were saved.';

  @override
  String get rateAlready => 'You already rated this member.';

  @override
  String get rateDone => 'Done';

  @override
  String get reportUser => 'Report';

  @override
  String get blockUser => 'Block';

  @override
  String get blockConfirmTitle => 'Block this member?';

  @override
  String get blockConfirmBody =>
      'You won\'t see this person\'s flocks anymore. This can\'t be undone for now.';

  @override
  String get blockDone => 'Blocked.';

  @override
  String get reportTitle => 'What do you want to report?';

  @override
  String get reportReasonHarassment => 'Harassment';

  @override
  String get reportReasonFake => 'Fake profile';

  @override
  String get reportReasonNoShow => 'Didn\'t show up';

  @override
  String get reportReasonSafety => 'Safety concern';

  @override
  String get reportReasonOther => 'Other';

  @override
  String get reportNoteHint => 'Add a short note (optional)';

  @override
  String get reportSend => 'Send';

  @override
  String get reportThanks => 'Report received — we\'ll review it.';

  @override
  String get statRatingReal => 'Avg rating';

  @override
  String get obSelfieTitle => 'Verify it\'s really you';

  @override
  String get obSelfieSubtitle =>
      'Take a quick selfie. We match it to your photo so every flock stays safe.';

  @override
  String get obSelfieTake => 'Take a selfie';

  @override
  String get obSelfieRetake => 'Retake selfie';

  @override
  String get obSelfieDone => 'Selfie captured ✓';

  @override
  String get obContinue => 'Continue';

  @override
  String get obFinish => 'Finish & enter Flock';

  @override
  String get obSkip => 'Skip for now';

  @override
  String get obSavedTitle => 'You\'re all set!';

  @override
  String get obVerificationPending => 'Selfie verification is pending review.';

  @override
  String get obNotVerified => 'Not verified';

  @override
  String get devSeed => 'Seed test flocks';

  @override
  String devSeedDone(Object n) {
    return '$n test flocks created ✓';
  }

  @override
  String get flockDetails => 'Flock details';

  @override
  String get flockClosed => 'This flock has closed.';

  @override
  String get membersTitle => 'WHO\'S IN';

  @override
  String get leaveFlock => 'Leave flock';

  @override
  String get cancelFlock => 'Cancel flock';

  @override
  String get notifTitle => 'Notifications';

  @override
  String get notifEmpty => 'No notifications yet.';

  @override
  String get notifAnnouncement => 'Announcement';

  @override
  String get notifWarning => 'Warning';

  @override
  String notifJoined(Object name) {
    return '$name joined your flock';
  }

  @override
  String get agoNow => 'just now';

  @override
  String agoMin(Object n) {
    return '${n}m ago';
  }

  @override
  String agoHour(Object n) {
    return '${n}h ago';
  }

  @override
  String agoDay(Object n) {
    return '${n}d ago';
  }

  @override
  String get intCoffee => 'Coffee';

  @override
  String get intMusic => 'Music';

  @override
  String get intSports => 'Sports';

  @override
  String get intArt => 'Art';

  @override
  String get intTravel => 'Travel';

  @override
  String get intFood => 'Food';

  @override
  String get intGaming => 'Gaming';

  @override
  String get intMovies => 'Movies';

  @override
  String get intBooks => 'Books';

  @override
  String get intFitness => 'Fitness';

  @override
  String get intNightlife => 'Nightlife';

  @override
  String get intNature => 'Nature';

  @override
  String get intTech => 'Tech';

  @override
  String get intPhotography => 'Photography';
}
