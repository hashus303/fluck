import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @navSafety.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get navSafety;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @flocksLiveNearYou.
  ///
  /// In en, this message translates to:
  /// **'{count} flocks live near you'**
  String flocksLiveNearYou(int count);

  /// No description provided for @findYourFlock.
  ///
  /// In en, this message translates to:
  /// **'Find your flock'**
  String get findYourFlock;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Skip the planning — pick a vibe, join, go.'**
  String get homeSubtitle;

  /// No description provided for @allVibes.
  ///
  /// In en, this message translates to:
  /// **'All vibes'**
  String get allVibes;

  /// No description provided for @surpriseMe.
  ///
  /// In en, this message translates to:
  /// **'Surprise me'**
  String get surpriseMe;

  /// No description provided for @surpriseTitle.
  ///
  /// In en, this message translates to:
  /// **'Your fate flock'**
  String get surpriseTitle;

  /// No description provided for @surpriseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The dice picked this one — the rest is on you.'**
  String get surpriseSubtitle;

  /// No description provided for @spinAgain.
  ///
  /// In en, this message translates to:
  /// **'Roll again'**
  String get spinAgain;

  /// No description provided for @surpriseNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing to roll right now — start one ✦'**
  String get surpriseNone;

  /// No description provided for @vibeCoffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get vibeCoffee;

  /// No description provided for @vibeBar.
  ///
  /// In en, this message translates to:
  /// **'Bar'**
  String get vibeBar;

  /// No description provided for @vibeWalk.
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get vibeWalk;

  /// No description provided for @vibeGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get vibeGames;

  /// No description provided for @vibeFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get vibeFood;

  /// No description provided for @vibeMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get vibeMusic;

  /// No description provided for @isHosting.
  ///
  /// In en, this message translates to:
  /// **'{host} is hosting'**
  String isHosting(String host);

  /// No description provided for @joinedCount.
  ///
  /// In en, this message translates to:
  /// **'{joined}/{total} joined'**
  String joinedCount(int joined, int total);

  /// No description provided for @timeLeft.
  ///
  /// In en, this message translates to:
  /// **'{label} left'**
  String timeLeft(String label);

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @joinedBadge.
  ///
  /// In en, this message translates to:
  /// **'Joined ✓'**
  String get joinedBadge;

  /// No description provided for @flockFull.
  ///
  /// In en, this message translates to:
  /// **'Flock full'**
  String get flockFull;

  /// No description provided for @noFlocksForVibe.
  ///
  /// In en, this message translates to:
  /// **'No flocks for this vibe yet — start one ✦'**
  String get noFlocksForVibe;

  /// No description provided for @safetyTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re covered'**
  String get safetyTitle;

  /// No description provided for @safetySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Trust runs quietly in the background so going out feels easy.'**
  String get safetySubtitle;

  /// No description provided for @identityVerified.
  ///
  /// In en, this message translates to:
  /// **'Identity verified'**
  String get identityVerified;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @idConfirmed.
  ///
  /// In en, this message translates to:
  /// **'ID + selfie confirmed · Mar 2026'**
  String get idConfirmed;

  /// No description provided for @yourTrustScore.
  ///
  /// In en, this message translates to:
  /// **'YOUR TRUST SCORE'**
  String get yourTrustScore;

  /// No description provided for @trusted.
  ///
  /// In en, this message translates to:
  /// **'Trusted'**
  String get trusted;

  /// No description provided for @trustScoreNote.
  ///
  /// In en, this message translates to:
  /// **'Built from verified ID, on-time flocks, and good ratings.'**
  String get trustScoreNote;

  /// No description provided for @featGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Group-only meetups'**
  String get featGroupTitle;

  /// No description provided for @featGroupDesc.
  ///
  /// In en, this message translates to:
  /// **'You always meet 3+ people — never one-on-one.'**
  String get featGroupDesc;

  /// No description provided for @featLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Live location sharing'**
  String get featLocationTitle;

  /// No description provided for @featLocationDesc.
  ///
  /// In en, this message translates to:
  /// **'Shared with your flock only, for the 2h window.'**
  String get featLocationDesc;

  /// No description provided for @featRatingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Two-way ratings'**
  String get featRatingsTitle;

  /// No description provided for @featRatingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Everyone rates after — low scores get filtered out.'**
  String get featRatingsDesc;

  /// No description provided for @statTrust.
  ///
  /// In en, this message translates to:
  /// **'Trust'**
  String get statTrust;

  /// No description provided for @statFlocks.
  ///
  /// In en, this message translates to:
  /// **'Flocks'**
  String get statFlocks;

  /// No description provided for @statRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get statRating;

  /// No description provided for @pastFlocks.
  ///
  /// In en, this message translates to:
  /// **'PAST FLOCKS'**
  String get pastFlocks;

  /// No description provided for @profileHandle.
  ///
  /// In en, this message translates to:
  /// **'@jvale · joined Mar 2026'**
  String get profileHandle;

  /// No description provided for @regularFlocker.
  ///
  /// In en, this message translates to:
  /// **'Regular flocker'**
  String get regularFlocker;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'Your profile and notifications are permanently deleted. This cannot be undone.'**
  String get deleteAccountBody;

  /// No description provided for @deleteAccountReauth.
  ///
  /// In en, this message translates to:
  /// **'For security you must have signed in recently — sign out, sign in again, then retry.'**
  String get deleteAccountReauth;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @peopleCount.
  ///
  /// In en, this message translates to:
  /// **'{count} people'**
  String peopleCount(int count);

  /// No description provided for @whenYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get whenYesterday;

  /// No description provided for @whenLastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last week'**
  String get whenLastWeek;

  /// No description provided for @whenTwoWeeks.
  ///
  /// In en, this message translates to:
  /// **'2 weeks ago'**
  String get whenTwoWeeks;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @startAFlock.
  ///
  /// In en, this message translates to:
  /// **'Start a flock'**
  String get startAFlock;

  /// No description provided for @pickAVibe.
  ///
  /// In en, this message translates to:
  /// **'PICK A VIBE'**
  String get pickAVibe;

  /// No description provided for @where.
  ///
  /// In en, this message translates to:
  /// **'WHERE'**
  String get where;

  /// No description provided for @groupSize.
  ///
  /// In en, this message translates to:
  /// **'GROUP SIZE'**
  String get groupSize;

  /// No description provided for @minThree.
  ///
  /// In en, this message translates to:
  /// **'Minimum 3 people — Flock is group-only.'**
  String get minThree;

  /// No description provided for @howLong.
  ///
  /// In en, this message translates to:
  /// **'HOW LONG IS IT LIVE?'**
  String get howLong;

  /// No description provided for @duration30m.
  ///
  /// In en, this message translates to:
  /// **'30 min'**
  String get duration30m;

  /// No description provided for @duration1h.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get duration1h;

  /// No description provided for @duration2h.
  ///
  /// In en, this message translates to:
  /// **'2 hours'**
  String get duration2h;

  /// No description provided for @expiryNoteFor.
  ///
  /// In en, this message translates to:
  /// **'Your invite goes live instantly and expires in {label}.'**
  String expiryNoteFor(String label);

  /// No description provided for @pickVenueFirst.
  ///
  /// In en, this message translates to:
  /// **'Pick a venue to continue'**
  String get pickVenueFirst;

  /// No description provided for @venueNameHint.
  ///
  /// In en, this message translates to:
  /// **'Venue name (e.g. Moda Pier)'**
  String get venueNameHint;

  /// No description provided for @venueSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search a place…'**
  String get venueSearchHint;

  /// No description provided for @venuePinHint.
  ///
  /// In en, this message translates to:
  /// **'Pan the map so the pin sits on your venue'**
  String get venuePinHint;

  /// No description provided for @venueNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a venue name'**
  String get venueNameRequired;

  /// No description provided for @postInviteFor.
  ///
  /// In en, this message translates to:
  /// **'Post invite · live for {label}'**
  String postInviteFor(String label);

  /// No description provided for @inviteLiveFor.
  ///
  /// In en, this message translates to:
  /// **'Your invite is live for {label} 🎉'**
  String inviteLiveFor(String label);

  /// No description provided for @locWithin.
  ///
  /// In en, this message translates to:
  /// **'within {km} km'**
  String locWithin(Object km);

  /// No description provided for @locAnywhere.
  ///
  /// In en, this message translates to:
  /// **'Anywhere'**
  String get locAnywhere;

  /// No description provided for @locNoneInRange.
  ///
  /// In en, this message translates to:
  /// **'No flocks in range — widen the radius.'**
  String get locNoneInRange;

  /// No description provided for @locChangeHint.
  ///
  /// In en, this message translates to:
  /// **'Location (GPS soon)'**
  String get locChangeHint;

  /// No description provided for @locMyLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get locMyLocation;

  /// No description provided for @locUseGps.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get locUseGps;

  /// No description provided for @locGpsFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t get location — try again.'**
  String get locGpsFailed;

  /// No description provided for @locServiceOff.
  ///
  /// In en, this message translates to:
  /// **'Location is off — turn on your phone\'s location.'**
  String get locServiceOff;

  /// No description provided for @locPermDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied.'**
  String get locPermDenied;

  /// No description provided for @locPermDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location permission is off — enable it in Settings.'**
  String get locPermDeniedForever;

  /// No description provided for @locOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get locOpenSettings;

  /// No description provided for @authTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop wandering alone.'**
  String get authTitle;

  /// No description provided for @authSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a vibe, join a flock nearby, and go. Three people minimum, real venues, two-hour window — safety built into every step.'**
  String get authSubtitle;

  /// No description provided for @continuePhone.
  ///
  /// In en, this message translates to:
  /// **'Continue with phone'**
  String get continuePhone;

  /// No description provided for @continueEmail.
  ///
  /// In en, this message translates to:
  /// **'Continue with email'**
  String get continueEmail;

  /// No description provided for @authFootnote.
  ///
  /// In en, this message translates to:
  /// **'Verified identity & trust scores keep flocks safe.'**
  String get authFootnote;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get passwordHint;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to find your flock.'**
  String get signInSubtitle;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join Flock — it only takes a second.'**
  String get signUpSubtitle;

  /// No description provided for @noAccountSignUp.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get noAccountSignUp;

  /// No description provided for @haveAccountSignIn.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get haveAccountSignIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @errEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get errEmailRequired;

  /// No description provided for @errEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get errEmailInvalid;

  /// No description provided for @errPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get errPasswordRequired;

  /// No description provided for @errPasswordShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get errPasswordShort;

  /// No description provided for @errInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Wrong email or password'**
  String get errInvalidCredentials;

  /// No description provided for @errEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered'**
  String get errEmailInUse;

  /// No description provided for @errWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak'**
  String get errWeakPassword;

  /// No description provided for @errNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error — check your connection'**
  String get errNetwork;

  /// No description provided for @errGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get errGeneric;

  /// No description provided for @obStep.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String obStep(int step, int total);

  /// No description provided for @obNameTitle.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get obNameTitle;

  /// No description provided for @obNameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use your real name — it builds trust.'**
  String get obNameSubtitle;

  /// No description provided for @obNameHint.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get obNameHint;

  /// No description provided for @obAgeTitle.
  ///
  /// In en, this message translates to:
  /// **'How old are you?'**
  String get obAgeTitle;

  /// No description provided for @obAgeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You must be 18 or older to use Flock.'**
  String get obAgeSubtitle;

  /// No description provided for @obAgeHint.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get obAgeHint;

  /// No description provided for @obAgeError.
  ///
  /// In en, this message translates to:
  /// **'You must be at least 18'**
  String get obAgeError;

  /// No description provided for @obInterestsTitle.
  ///
  /// In en, this message translates to:
  /// **'What are you into?'**
  String get obInterestsTitle;

  /// No description provided for @obInterestsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick at least 3 — we\'ll match you with the right flocks.'**
  String get obInterestsSubtitle;

  /// No description provided for @obPhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a profile photo'**
  String get obPhotoTitle;

  /// No description provided for @obPhotoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This is how your flock sees you.'**
  String get obPhotoSubtitle;

  /// No description provided for @obPhotoPick.
  ///
  /// In en, this message translates to:
  /// **'Choose a photo'**
  String get obPhotoPick;

  /// No description provided for @obPhotoChange.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get obPhotoChange;

  /// No description provided for @obPhotoGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get obPhotoGallery;

  /// No description provided for @obPhotoTake.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get obPhotoTake;

  /// No description provided for @obPickFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t get the photo — check camera/gallery permission.'**
  String get obPickFailed;

  /// No description provided for @obSelfieTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify it\'s really you'**
  String get obSelfieTitle;

  /// No description provided for @obSelfieSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a quick selfie. We match it to your photo so every flock stays safe.'**
  String get obSelfieSubtitle;

  /// No description provided for @obSelfieTake.
  ///
  /// In en, this message translates to:
  /// **'Take a selfie'**
  String get obSelfieTake;

  /// No description provided for @obSelfieRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake selfie'**
  String get obSelfieRetake;

  /// No description provided for @obSelfieDone.
  ///
  /// In en, this message translates to:
  /// **'Selfie captured ✓'**
  String get obSelfieDone;

  /// No description provided for @obContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get obContinue;

  /// No description provided for @obFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish & enter Flock'**
  String get obFinish;

  /// No description provided for @obSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get obSkip;

  /// No description provided for @obSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set!'**
  String get obSavedTitle;

  /// No description provided for @obVerificationPending.
  ///
  /// In en, this message translates to:
  /// **'Selfie verification is pending review.'**
  String get obVerificationPending;

  /// No description provided for @obNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Not verified'**
  String get obNotVerified;

  /// No description provided for @devSeed.
  ///
  /// In en, this message translates to:
  /// **'Seed test flocks'**
  String get devSeed;

  /// No description provided for @devSeedDone.
  ///
  /// In en, this message translates to:
  /// **'{n} test flocks created ✓'**
  String devSeedDone(Object n);

  /// No description provided for @flockDetails.
  ///
  /// In en, this message translates to:
  /// **'Flock details'**
  String get flockDetails;

  /// No description provided for @flockClosed.
  ///
  /// In en, this message translates to:
  /// **'This flock has closed.'**
  String get flockClosed;

  /// No description provided for @membersTitle.
  ///
  /// In en, this message translates to:
  /// **'WHO\'S IN'**
  String get membersTitle;

  /// No description provided for @leaveFlock.
  ///
  /// In en, this message translates to:
  /// **'Leave flock'**
  String get leaveFlock;

  /// No description provided for @cancelFlock.
  ///
  /// In en, this message translates to:
  /// **'Cancel flock'**
  String get cancelFlock;

  /// No description provided for @notifTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifTitle;

  /// No description provided for @notifEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get notifEmpty;

  /// No description provided for @notifJoined.
  ///
  /// In en, this message translates to:
  /// **'{name} joined your flock'**
  String notifJoined(Object name);

  /// No description provided for @agoNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get agoNow;

  /// No description provided for @agoMin.
  ///
  /// In en, this message translates to:
  /// **'{n}m ago'**
  String agoMin(Object n);

  /// No description provided for @agoHour.
  ///
  /// In en, this message translates to:
  /// **'{n}h ago'**
  String agoHour(Object n);

  /// No description provided for @agoDay.
  ///
  /// In en, this message translates to:
  /// **'{n}d ago'**
  String agoDay(Object n);

  /// No description provided for @intCoffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get intCoffee;

  /// No description provided for @intMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get intMusic;

  /// No description provided for @intSports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get intSports;

  /// No description provided for @intArt.
  ///
  /// In en, this message translates to:
  /// **'Art'**
  String get intArt;

  /// No description provided for @intTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get intTravel;

  /// No description provided for @intFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get intFood;

  /// No description provided for @intGaming.
  ///
  /// In en, this message translates to:
  /// **'Gaming'**
  String get intGaming;

  /// No description provided for @intMovies.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get intMovies;

  /// No description provided for @intBooks.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get intBooks;

  /// No description provided for @intFitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get intFitness;

  /// No description provided for @intNightlife.
  ///
  /// In en, this message translates to:
  /// **'Nightlife'**
  String get intNightlife;

  /// No description provided for @intNature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get intNature;

  /// No description provided for @intTech.
  ///
  /// In en, this message translates to:
  /// **'Tech'**
  String get intTech;

  /// No description provided for @intPhotography.
  ///
  /// In en, this message translates to:
  /// **'Photography'**
  String get intPhotography;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
    case 'tr':
      return AppL10nTr();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
