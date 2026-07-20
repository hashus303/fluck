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
  String get emailHint => 'you@example.com';

  @override
  String get passwordHint => 'At least 6 characters';

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
  String get errInvalidCredentials => 'Wrong email or password';

  @override
  String get errEmailInUse => 'This email is already registered';

  @override
  String get errWeakPassword => 'Password is too weak';

  @override
  String get errNetwork => 'Network error — check your connection';

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
