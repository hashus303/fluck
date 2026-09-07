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

  /// No description provided for @safetyLede.
  ///
  /// In en, this message translates to:
  /// **'Your verification status and the people you\'ve blocked.'**
  String get safetyLede;

  /// No description provided for @blockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Blocked people'**
  String get blockedTitle;

  /// No description provided for @blockedCount.
  ///
  /// In en, this message translates to:
  /// **'{n} blocked'**
  String blockedCount(int n);

  /// No description provided for @blockedEmpty.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t blocked anyone.'**
  String get blockedEmpty;

  /// No description provided for @blockedEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'You can block someone from their flock — they\'ll disappear from your feed.'**
  String get blockedEmptyHint;

  /// No description provided for @unblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get unblock;

  /// No description provided for @unblockDone.
  ///
  /// In en, this message translates to:
  /// **'Unblocked.'**
  String get unblockDone;

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

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

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

  /// No description provided for @introSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'Skip the planning.'**
  String get introSlide1Title;

  /// No description provided for @introSlide1Body.
  ///
  /// In en, this message translates to:
  /// **'Open Flock, see live invites nearby, join a group in one tap — coffee, a walk, a game.'**
  String get introSlide1Body;

  /// No description provided for @introSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'Can\'t decide? Roll.'**
  String get introSlide2Title;

  /// No description provided for @introSlide2Body.
  ///
  /// In en, this message translates to:
  /// **'The dice picks a random flock near you. Zero overthinking — just show up.'**
  String get introSlide2Body;

  /// No description provided for @introSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'Always a group. Verified people.'**
  String get introSlide3Title;

  /// No description provided for @introSlide3Body.
  ///
  /// In en, this message translates to:
  /// **'Never one-on-one — every flock is 3+ people. Everyone\'s confirmed with a selfie.'**
  String get introSlide3Body;

  /// No description provided for @introSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get introSkip;

  /// No description provided for @introNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get introNext;

  /// No description provided for @introStart.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get introStart;

  /// No description provided for @navDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get navDiscover;

  /// No description provided for @discoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discoverTitle;

  /// No description provided for @discoverLede.
  ///
  /// In en, this message translates to:
  /// **'What is happening around you right now.'**
  String get discoverLede;

  /// No description provided for @discoverRollTitle.
  ///
  /// In en, this message translates to:
  /// **'Roll the dice'**
  String get discoverRollTitle;

  /// No description provided for @discoverRollBody.
  ///
  /// In en, this message translates to:
  /// **'Let fate pick a flock near you — one tap to join.'**
  String get discoverRollBody;

  /// No description provided for @discoverDateTitle.
  ///
  /// In en, this message translates to:
  /// **'Date mode'**
  String get discoverDateTitle;

  /// No description provided for @discoverDateBody.
  ///
  /// In en, this message translates to:
  /// **'Swipe through verified people nearby who want to meet.'**
  String get discoverDateBody;

  /// No description provided for @discoverNearbyTitle.
  ///
  /// In en, this message translates to:
  /// **'People nearby'**
  String get discoverNearbyTitle;

  /// No description provided for @discoverNearbyBody.
  ///
  /// In en, this message translates to:
  /// **'See verified people around you and invite them to your flock.'**
  String get discoverNearbyBody;

  /// No description provided for @discoverByVibe.
  ///
  /// In en, this message translates to:
  /// **'Browse by vibe'**
  String get discoverByVibe;

  /// No description provided for @discoverPulseLive.
  ///
  /// In en, this message translates to:
  /// **'{n} flocks live near you'**
  String discoverPulseLive(int n);

  /// No description provided for @discoverPulseNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing live yet — be the first to start one.'**
  String get discoverPulseNone;

  /// No description provided for @discoverStartOne.
  ///
  /// In en, this message translates to:
  /// **'Start a flock'**
  String get discoverStartOne;

  /// No description provided for @plusBadge.
  ///
  /// In en, this message translates to:
  /// **'Flock+'**
  String get plusBadge;

  /// No description provided for @navDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get navDate;

  /// No description provided for @dateTitle.
  ///
  /// In en, this message translates to:
  /// **'Date mode'**
  String get dateTitle;

  /// No description provided for @dateLede.
  ///
  /// In en, this message translates to:
  /// **'Verified people nearby — invite them to your flock.'**
  String get dateLede;

  /// No description provided for @dateLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover people, not just flocks'**
  String get dateLockedTitle;

  /// No description provided for @dateLockedBody.
  ///
  /// In en, this message translates to:
  /// **'Browse verified people around you and invite the ones you like to your flock. Every meetup stays a group — 3 people minimum.'**
  String get dateLockedBody;

  /// No description provided for @dateUnlockCta.
  ///
  /// In en, this message translates to:
  /// **'Unlock with Flock+'**
  String get dateUnlockCta;

  /// No description provided for @dateSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Your deck is being built'**
  String get dateSoonTitle;

  /// No description provided for @dateSoonBody.
  ///
  /// In en, this message translates to:
  /// **'Browsing opens shortly — as a Flock+ member you get it first.'**
  String get dateSoonBody;

  /// No description provided for @plusTitle.
  ///
  /// In en, this message translates to:
  /// **'Flock+'**
  String get plusTitle;

  /// No description provided for @plusTagline.
  ///
  /// In en, this message translates to:
  /// **'Meet more people, more often.'**
  String get plusTagline;

  /// No description provided for @plusTrialBadge.
  ///
  /// In en, this message translates to:
  /// **'First 14 days free'**
  String get plusTrialBadge;

  /// No description provided for @plusPriceLine.
  ///
  /// In en, this message translates to:
  /// **'Then ₺99/month. Cancel anytime.'**
  String get plusPriceLine;

  /// No description provided for @plusFeatureNearbyTitle.
  ///
  /// In en, this message translates to:
  /// **'See who liked you'**
  String get plusFeatureNearbyTitle;

  /// No description provided for @plusFeatureNearbyBody.
  ///
  /// In en, this message translates to:
  /// **'Find out who wants to flock with you — and invite them back.'**
  String get plusFeatureNearbyBody;

  /// No description provided for @plusFeatureDateTitle.
  ///
  /// In en, this message translates to:
  /// **'Date mode'**
  String get plusFeatureDateTitle;

  /// No description provided for @plusFeatureDateBody.
  ///
  /// In en, this message translates to:
  /// **'Browse verified people nearby and invite the ones you like to your flock.'**
  String get plusFeatureDateBody;

  /// No description provided for @plusFeatureUnlimitedTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlimited flocks + boost'**
  String get plusFeatureUnlimitedTitle;

  /// No description provided for @plusFeatureUnlimitedBody.
  ///
  /// In en, this message translates to:
  /// **'Create as many as you like and push yours to the top.'**
  String get plusFeatureUnlimitedBody;

  /// No description provided for @plusFeatureFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Advanced filters'**
  String get plusFeatureFiltersTitle;

  /// No description provided for @plusFeatureFiltersBody.
  ///
  /// In en, this message translates to:
  /// **'Verified-only mode, vibe and distance filters.'**
  String get plusFeatureFiltersBody;

  /// No description provided for @plusCta.
  ///
  /// In en, this message translates to:
  /// **'Start free trial'**
  String get plusCta;

  /// No description provided for @plusHonestNote.
  ///
  /// In en, this message translates to:
  /// **'We remind you 24h before the trial ends — by push and email. One tap to cancel.'**
  String get plusHonestNote;

  /// No description provided for @plusRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore purchase'**
  String get plusRestore;

  /// No description provided for @plusActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Flock+ is active'**
  String get plusActiveTitle;

  /// No description provided for @plusTrialActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Flock+ trial — {days} days left'**
  String plusTrialActiveTitle(int days);

  /// No description provided for @plusManage.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get plusManage;

  /// No description provided for @plusLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Flock+ feature'**
  String get plusLockedTitle;

  /// No description provided for @plusLockedBody.
  ///
  /// In en, this message translates to:
  /// **'Unlock this with Flock+ — first 14 days free.'**
  String get plusLockedBody;

  /// No description provided for @plusSoon.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions open soon — you will be first to know.'**
  String get plusSoon;

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

  /// No description provided for @passwordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get passwordConfirm;

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

  /// No description provided for @passwordConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get passwordConfirmHint;

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

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orDivider;

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

  /// No description provided for @errPasswordConfirmRequired.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get errPasswordConfirmRequired;

  /// No description provided for @errPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get errPasswordMismatch;

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

  /// No description provided for @errGoogleReauth.
  ///
  /// In en, this message translates to:
  /// **'Your Google account couldn’t approve this sign-in. You can sign in with email for now.'**
  String get errGoogleReauth;

  /// No description provided for @errGoogleNoAccount.
  ///
  /// In en, this message translates to:
  /// **'No Google account on this phone. Add one in Settings, or sign in with email.'**
  String get errGoogleNoAccount;

  /// No description provided for @errGoogleConfig.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in isn\'t available in this build. You can sign in with email for now.'**
  String get errGoogleConfig;

  /// No description provided for @errGoogleInterrupted.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in was interrupted. Check your connection and try again.'**
  String get errGoogleInterrupted;

  /// No description provided for @errGoogleGeneric.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sign in with Google. Try again, or sign in with email.'**
  String get errGoogleGeneric;

  /// No description provided for @a11yBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get a11yBack;

  /// No description provided for @a11yClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get a11yClose;

  /// No description provided for @a11yShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get a11yShowPassword;

  /// No description provided for @a11yHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get a11yHidePassword;

  /// No description provided for @a11yNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get a11yNotifications;

  /// No description provided for @a11yUnreadCount.
  ///
  /// In en, this message translates to:
  /// **'{count} unread notifications'**
  String a11yUnreadCount(int count);

  /// No description provided for @a11yMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Go to my location'**
  String get a11yMyLocation;

  /// No description provided for @a11ySearchPlace.
  ///
  /// In en, this message translates to:
  /// **'Search for a place'**
  String get a11ySearchPlace;

  /// No description provided for @a11yRateStars.
  ///
  /// In en, this message translates to:
  /// **'Rate {count} stars'**
  String a11yRateStars(int count);

  /// No description provided for @a11yChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get a11yChangePhoto;

  /// No description provided for @a11yPickPhoto.
  ///
  /// In en, this message translates to:
  /// **'Pick a photo'**
  String get a11yPickPhoto;

  /// No description provided for @a11yAvatarOf.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s profile photo'**
  String a11yAvatarOf(String name);

  /// No description provided for @a11yAppLogo.
  ///
  /// In en, this message translates to:
  /// **'Flock logo'**
  String get a11yAppLogo;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'No internet — check your connection'**
  String get offlineBanner;

  /// No description provided for @offlineRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get offlineRetry;

  /// No description provided for @notifSection.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifSection;

  /// No description provided for @notifJoins.
  ///
  /// In en, this message translates to:
  /// **'Flock activity'**
  String get notifJoins;

  /// No description provided for @notifJoinsBody.
  ///
  /// In en, this message translates to:
  /// **'When someone joins your flock'**
  String get notifJoinsBody;

  /// No description provided for @notifMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get notifMessages;

  /// No description provided for @notifMessagesBody.
  ///
  /// In en, this message translates to:
  /// **'When someone messages you'**
  String get notifMessagesBody;

  /// No description provided for @notifAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get notifAnnouncements;

  /// No description provided for @notifAnnouncementsBody.
  ///
  /// In en, this message translates to:
  /// **'News from the Flock team'**
  String get notifAnnouncementsBody;

  /// No description provided for @notifVerification.
  ///
  /// In en, this message translates to:
  /// **'Verification result'**
  String get notifVerification;

  /// No description provided for @notifVerificationBody.
  ///
  /// In en, this message translates to:
  /// **'When your selfie check is decided'**
  String get notifVerificationBody;

  /// No description provided for @notifAllOffHint.
  ///
  /// In en, this message translates to:
  /// **'Turn everything off and you\'ll still see it in the app.'**
  String get notifAllOffHint;

  /// No description provided for @dateOptInTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn on Date mode'**
  String get dateOptInTitle;

  /// No description provided for @dateOptInBody.
  ///
  /// In en, this message translates to:
  /// **'Turn it on and you appear in the deck too — no browsing without being browsed. Only verified accounts see each other.'**
  String get dateOptInBody;

  /// No description provided for @dateOptInPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Your location is rounded to about 1 km; your exact address is never shared. Turn it off and your location is deleted.'**
  String get dateOptInPrivacy;

  /// No description provided for @dateOptInCta.
  ///
  /// In en, this message translates to:
  /// **'Show me too'**
  String get dateOptInCta;

  /// No description provided for @dateOptOut.
  ///
  /// In en, this message translates to:
  /// **'Leave Date mode'**
  String get dateOptOut;

  /// No description provided for @datePass.
  ///
  /// In en, this message translates to:
  /// **'Pass'**
  String get datePass;

  /// No description provided for @dateLike.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get dateLike;

  /// No description provided for @dateSwipeHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe right to like, left to pass'**
  String get dateSwipeHint;

  /// No description provided for @dateUnder1Km.
  ///
  /// In en, this message translates to:
  /// **'under 1 km'**
  String get dateUnder1Km;

  /// No description provided for @dateEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'That\'s everyone for now'**
  String get dateEmptyTitle;

  /// No description provided for @dateEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No one new around you right now. More people join every day — check back soon.'**
  String get dateEmptyBody;

  /// No description provided for @dateDeckRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get dateDeckRefresh;

  /// No description provided for @dateDeckRetry.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the deck.'**
  String get dateDeckRetry;

  /// No description provided for @dateMutual.
  ///
  /// In en, this message translates to:
  /// **'{name} liked you back — you can message each other now.'**
  String dateMutual(String name);

  /// No description provided for @dateMutualCta.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get dateMutualCta;

  /// No description provided for @plusSheetLede.
  ///
  /// In en, this message translates to:
  /// **'Who liked you, and your subscription.'**
  String get plusSheetLede;

  /// No description provided for @plusAdmirersTitle.
  ///
  /// In en, this message translates to:
  /// **'Liked you'**
  String get plusAdmirersTitle;

  /// No description provided for @plusAdmirersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No one yet. Keep browsing the deck — anyone who likes you shows up here.'**
  String get plusAdmirersEmpty;

  /// No description provided for @plusAdmirersError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the list. Check your connection and reopen.'**
  String get plusAdmirersError;

  /// No description provided for @plusLikedYouHint.
  ///
  /// In en, this message translates to:
  /// **'Liked you'**
  String get plusLikedYouHint;

  /// No description provided for @plusMutualHint.
  ///
  /// In en, this message translates to:
  /// **'You both liked each other — you can message now.'**
  String get plusMutualHint;

  /// No description provided for @plusMutualBadge.
  ///
  /// In en, this message translates to:
  /// **'Mutual'**
  String get plusMutualBadge;

  /// No description provided for @plusLikeBack.
  ///
  /// In en, this message translates to:
  /// **'Like back'**
  String get plusLikeBack;

  /// No description provided for @plusStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Your subscription'**
  String get plusStatusTitle;

  /// No description provided for @plusMessagesRow.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get plusMessagesRow;

  /// No description provided for @plusMessagesRowHint.
  ///
  /// In en, this message translates to:
  /// **'Chat with your mutual likes'**
  String get plusMessagesRowHint;

  /// No description provided for @plusOpenHint.
  ///
  /// In en, this message translates to:
  /// **'Hold the heart'**
  String get plusOpenHint;

  /// No description provided for @chatInboxTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get chatInboxTitle;

  /// No description provided for @chatOpen.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get chatOpen;

  /// No description provided for @chatNewMatches.
  ///
  /// In en, this message translates to:
  /// **'NEW MATCHES'**
  String get chatNewMatches;

  /// No description provided for @chatConversations.
  ///
  /// In en, this message translates to:
  /// **'CONVERSATIONS'**
  String get chatConversations;

  /// No description provided for @chatNoConversations.
  ///
  /// In en, this message translates to:
  /// **'No chats yet. Say the first word to someone above.'**
  String get chatNoConversations;

  /// No description provided for @chatNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches yet. Like people in the deck — when it\'s mutual, you meet here.'**
  String get chatNoMatches;

  /// No description provided for @chatEmptyThread.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet. Say the first word.'**
  String get chatEmptyThread;

  /// No description provided for @chatComposerHint.
  ///
  /// In en, this message translates to:
  /// **'Write a message…'**
  String get chatComposerHint;

  /// No description provided for @chatSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get chatSend;

  /// No description provided for @chatSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Message not sent. Check your connection.'**
  String get chatSendFailed;

  /// No description provided for @chatLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the chat. Check your connection and reopen.'**
  String get chatLoadFailed;

  /// No description provided for @chatToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get chatToday;

  /// No description provided for @chatYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get chatYesterday;

  /// No description provided for @chatYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get chatYou;

  /// No description provided for @chatCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get chatCopy;

  /// No description provided for @chatDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete message'**
  String get chatDelete;

  /// No description provided for @chatMore.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get chatMore;

  /// No description provided for @chatMutualSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You liked each other'**
  String get chatMutualSubtitle;

  /// No description provided for @chatFlockCta.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatFlockCta;

  /// No description provided for @chatFlockJoinFirst.
  ///
  /// In en, this message translates to:
  /// **'Join the flock to chat'**
  String get chatFlockJoinFirst;

  /// No description provided for @chatFlockClosed.
  ///
  /// In en, this message translates to:
  /// **'This flock has ended — the chat is closed. You can still read it.'**
  String get chatFlockClosed;

  /// No description provided for @chatFlockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} people'**
  String chatFlockSubtitle(int count);

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

  /// No description provided for @obSelfieNoFace.
  ///
  /// In en, this message translates to:
  /// **'No face detected in the selfie — retake it with your face clearly visible.'**
  String get obSelfieNoFace;

  /// No description provided for @obSelfieChallengeLabel.
  ///
  /// In en, this message translates to:
  /// **'For verification:'**
  String get obSelfieChallengeLabel;

  /// No description provided for @obSelfieChSmile.
  ///
  /// In en, this message translates to:
  /// **'smile 😊'**
  String get obSelfieChSmile;

  /// No description provided for @obSelfieChTurn.
  ///
  /// In en, this message translates to:
  /// **'turn your head slightly to the side ↩️'**
  String get obSelfieChTurn;

  /// No description provided for @obSelfieChTilt.
  ///
  /// In en, this message translates to:
  /// **'tilt your head slightly 🙂↕️'**
  String get obSelfieChTilt;

  /// No description provided for @obSelfieWrongPose.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t see the requested move. Try again: {pose}'**
  String obSelfieWrongPose(String pose);

  /// No description provided for @verifPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Your selfie is under review'**
  String get verifPendingTitle;

  /// No description provided for @verifPendingBody.
  ///
  /// In en, this message translates to:
  /// **'For safety, every profile is approved by a real person. It\'s usually quick — the app opens automatically once you\'re approved.'**
  String get verifPendingBody;

  /// No description provided for @verifRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t verify your selfie'**
  String get verifRejectedTitle;

  /// No description provided for @verifRejectedBody.
  ///
  /// In en, this message translates to:
  /// **'Take a new selfie with your face clearly visible — it goes straight back into review.'**
  String get verifRejectedBody;

  /// No description provided for @verifRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake selfie'**
  String get verifRetake;

  /// No description provided for @verifNeedTitle.
  ///
  /// In en, this message translates to:
  /// **'One last step: verification'**
  String get verifNeedTitle;

  /// No description provided for @verifNeedBody.
  ///
  /// In en, this message translates to:
  /// **'Take a selfie clearly showing your face to continue. The app opens once it\'s reviewed and approved.'**
  String get verifNeedBody;

  /// No description provided for @verifResend.
  ///
  /// In en, this message translates to:
  /// **'Resend selfie'**
  String get verifResend;

  /// No description provided for @notifVerifApproved.
  ///
  /// In en, this message translates to:
  /// **'Your profile is verified 🎉'**
  String get notifVerifApproved;

  /// No description provided for @notifVerifRejected.
  ///
  /// In en, this message translates to:
  /// **'Selfie couldn\'t be verified — try again'**
  String get notifVerifRejected;

  /// No description provided for @ratePromptTitle.
  ///
  /// In en, this message translates to:
  /// **'How was it?'**
  String get ratePromptTitle;

  /// No description provided for @ratePromptBody.
  ///
  /// In en, this message translates to:
  /// **'Your \'{venue}\' flock has ended — rate the members.'**
  String ratePromptBody(String venue);

  /// No description provided for @rateAction.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rateAction;

  /// No description provided for @rateSkip.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get rateSkip;

  /// No description provided for @rateThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks! Your ratings were saved.'**
  String get rateThanks;

  /// No description provided for @rateAlready.
  ///
  /// In en, this message translates to:
  /// **'You already rated this member.'**
  String get rateAlready;

  /// No description provided for @rateDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get rateDone;

  /// No description provided for @reportUser.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportUser;

  /// No description provided for @blockUser.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get blockUser;

  /// No description provided for @blockConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Block this member?'**
  String get blockConfirmTitle;

  /// No description provided for @blockConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You won\'t see this person\'s flocks anymore. This can\'t be undone for now.'**
  String get blockConfirmBody;

  /// No description provided for @blockDone.
  ///
  /// In en, this message translates to:
  /// **'Blocked.'**
  String get blockDone;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'What do you want to report?'**
  String get reportTitle;

  /// No description provided for @reportReasonHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get reportReasonHarassment;

  /// No description provided for @reportReasonFake.
  ///
  /// In en, this message translates to:
  /// **'Fake profile'**
  String get reportReasonFake;

  /// No description provided for @reportReasonNoShow.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t show up'**
  String get reportReasonNoShow;

  /// No description provided for @reportReasonSafety.
  ///
  /// In en, this message translates to:
  /// **'Safety concern'**
  String get reportReasonSafety;

  /// No description provided for @reportReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reportReasonOther;

  /// No description provided for @reportNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Add a short note (optional)'**
  String get reportNoteHint;

  /// No description provided for @reportSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get reportSend;

  /// No description provided for @reportThanks.
  ///
  /// In en, this message translates to:
  /// **'Report received — we\'ll review it.'**
  String get reportThanks;

  /// No description provided for @statRatingReal.
  ///
  /// In en, this message translates to:
  /// **'Avg rating'**
  String get statRatingReal;

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

  /// No description provided for @notifAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Announcement'**
  String get notifAnnouncement;

  /// No description provided for @notifWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get notifWarning;

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
