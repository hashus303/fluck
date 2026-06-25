// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppL10nTr extends AppL10n {
  AppL10nTr([String locale = 'tr']) : super(locale);

  @override
  String get navHome => 'Ana Sayfa';

  @override
  String get navMap => 'Harita';

  @override
  String get navSafety => 'Güvenlik';

  @override
  String get navProfile => 'Profil';

  @override
  String flocksLiveNearYou(int count) {
    return 'Yakınında $count flock aktif';
  }

  @override
  String get findYourFlock => 'Flock\'unu bul';

  @override
  String get homeSubtitle => 'Bir vibe seç, gruba katıl, hemen çık.';

  @override
  String get allVibes => 'Tüm vibe\'lar';

  @override
  String get vibeCoffee => 'Kahve';

  @override
  String get vibeBar => 'Bar';

  @override
  String get vibeWalk => 'Yürüyüş';

  @override
  String get vibeGames => 'Oyun';

  @override
  String get vibeFood => 'Yemek';

  @override
  String get vibeMusic => 'Müzik';

  @override
  String isHosting(String host) {
    return '$host davet ediyor';
  }

  @override
  String joinedCount(int joined, int total) {
    return '$joined/$total katıldı';
  }

  @override
  String timeLeft(String label) {
    return '$label kaldı';
  }

  @override
  String get join => 'Katıl';

  @override
  String get joinedBadge => 'Katıldın ✓';

  @override
  String get flockFull => 'Flock dolu';

  @override
  String get noFlocksForVibe =>
      'Bu vibe için henüz flock yok — ilkini sen başlat ✦';

  @override
  String get safetyTitle => 'Güvendesin';

  @override
  String get safetySubtitle =>
      'Güven arka planda sessizce çalışır, çıkmak kolay olsun diye.';

  @override
  String get identityVerified => 'Kimlik doğrulandı';

  @override
  String get verified => 'Doğrulandı';

  @override
  String get idConfirmed => 'Kimlik + selfie onaylandı · Mar 2026';

  @override
  String get yourTrustScore => 'GÜVEN SKORUN';

  @override
  String get trusted => 'Güvenilir';

  @override
  String get trustScoreNote =>
      'Doğrulanmış kimlik, zamanında flock\'lar ve iyi puanlardan oluşur.';

  @override
  String get featGroupTitle => 'Sadece grup buluşması';

  @override
  String get featGroupDesc =>
      'Her zaman 3+ kişiyle buluşursun — asla baş başa değil.';

  @override
  String get featLocationTitle => 'Canlı konum paylaşımı';

  @override
  String get featLocationDesc =>
      'Sadece flock\'unla, 2 saatlik pencere boyunca paylaşılır.';

  @override
  String get featRatingsTitle => 'Çift taraflı puanlama';

  @override
  String get featRatingsDesc =>
      'Herkes sonradan puan verir — düşük skorlar elenir.';

  @override
  String get emergency => 'Acil durum';

  @override
  String get emergencyDesc =>
      'Kişilerine + Flock güvenliğine canlı konumunla anında haber verir.';

  @override
  String get sos => 'SOS';

  @override
  String get pressHold => 'Etkinleştirmek için basılı tut';

  @override
  String get sosActivated => 'SOS etkinleştirildi — flock\'una haber veriliyor';

  @override
  String get statTrust => 'Güven';

  @override
  String get statFlocks => 'Flock';

  @override
  String get statRating => 'Puan';

  @override
  String get pastFlocks => 'GEÇMİŞ FLOCK\'LAR';

  @override
  String get profileHandle => '@jvale · Mar 2026\'da katıldı';

  @override
  String get regularFlocker => 'Düzenli flocker';

  @override
  String get editProfile => 'Profili düzenle';

  @override
  String peopleCount(int count) {
    return '$count kişi';
  }

  @override
  String get whenYesterday => 'Dün';

  @override
  String get whenLastWeek => 'Geçen hafta';

  @override
  String get whenTwoWeeks => '2 hafta önce';

  @override
  String get language => 'Dil';

  @override
  String get startAFlock => 'Flock başlat';

  @override
  String get pickAVibe => 'BİR VIBE SEÇ';

  @override
  String get where => 'NEREDE';

  @override
  String get groupSize => 'GRUP BOYUTU';

  @override
  String get minThree => 'En az 3 kişi — Flock sadece gruba özel.';

  @override
  String get expiryNote =>
      'Davetin anında yayına girer ve 2 saat sonra sona erer.';

  @override
  String get pickVenueFirst => 'Devam için bir mekan seç';

  @override
  String get venueNameHint => 'Mekan adı (ör. Moda Sahil)';

  @override
  String get venueSearchHint => 'Yer ara…';

  @override
  String get venuePinHint => 'Haritayı kaydır, pin mekanın üstünde dursun';

  @override
  String get venueNameRequired => 'Mekan adı gir';

  @override
  String get postInvite => 'Daveti yayınla · 2 saat aktif';

  @override
  String get inviteLive => 'Davetin 2 saat boyunca aktif 🎉';

  @override
  String get searchThisArea => 'Bu bölgede ara';

  @override
  String locWithin(Object km) {
    return '$km km içinde';
  }

  @override
  String get locAnywhere => 'Her yer';

  @override
  String get locNoneInRange => 'Bu mesafede flock yok — yarıçapı genişlet.';

  @override
  String get locChangeHint => 'Konum (yakında GPS)';

  @override
  String get locMyLocation => 'Konumum';

  @override
  String get locUseGps => 'Konumumu kullan';

  @override
  String get locGpsFailed =>
      'Konum alınamadı — izni aç (web\'de HTTPS gerekir).';

  @override
  String get authTitle => 'Tek başına dolaşmayı bırak.';

  @override
  String get authSubtitle =>
      'Bir vibe seç, yakındaki bir flock\'a katıl ve çık. En az üç kişi, gerçek mekanlar, iki saatlik pencere — her adımda güvenlik.';

  @override
  String get continuePhone => 'Telefonla devam et';

  @override
  String get continueEmail => 'E-posta ile devam et';

  @override
  String get authFootnote =>
      'Doğrulanmış kimlik ve güven skorları flock\'ları güvende tutar.';

  @override
  String get email => 'E-posta';

  @override
  String get password => 'Şifre';

  @override
  String get emailHint => 'sen@ornek.com';

  @override
  String get passwordHint => 'En az 6 karakter';

  @override
  String get signIn => 'Giriş yap';

  @override
  String get signUp => 'Kayıt ol';

  @override
  String get createAccount => 'Hesap oluştur';

  @override
  String get welcomeBack => 'Tekrar hoş geldin';

  @override
  String get signInSubtitle => 'Flock\'unu bulmak için giriş yap.';

  @override
  String get signUpSubtitle => 'Flock\'a katıl — bir saniye sürer.';

  @override
  String get noAccountSignUp => 'Hesabın yok mu? Kayıt ol';

  @override
  String get haveAccountSignIn => 'Zaten hesabın var mı? Giriş yap';

  @override
  String get signOut => 'Çıkış yap';

  @override
  String get errEmailRequired => 'E-postanı gir';

  @override
  String get errEmailInvalid => 'Geçerli bir e-posta gir';

  @override
  String get errPasswordRequired => 'Şifreni gir';

  @override
  String get errPasswordShort => 'Şifre en az 6 karakter olmalı';

  @override
  String get errInvalidCredentials => 'E-posta veya şifre hatalı';

  @override
  String get errEmailInUse => 'Bu e-posta zaten kayıtlı';

  @override
  String get errWeakPassword => 'Şifre çok zayıf';

  @override
  String get errNetwork => 'Ağ hatası — bağlantını kontrol et';

  @override
  String get errGeneric => 'Bir şeyler ters gitti. Tekrar dene.';

  @override
  String obStep(int step, int total) {
    return 'Adım $step / $total';
  }

  @override
  String get obNameTitle => 'Sana ne diyelim?';

  @override
  String get obNameSubtitle => 'Gerçek adını kullan — güven oluşturur.';

  @override
  String get obNameHint => 'Ad soyad';

  @override
  String get obAgeTitle => 'Kaç yaşındasın?';

  @override
  String get obAgeSubtitle =>
      'Flock\'u kullanmak için 18 yaşından büyük olmalısın.';

  @override
  String get obAgeHint => 'Yaş';

  @override
  String get obAgeError => 'En az 18 yaşında olmalısın';

  @override
  String get obInterestsTitle => 'Neye ilgi duyuyorsun?';

  @override
  String get obInterestsSubtitle =>
      'En az 3 tane seç — seni doğru flock\'larla eşleştirelim.';

  @override
  String get obPhotoTitle => 'Profil fotoğrafı ekle';

  @override
  String get obPhotoSubtitle => 'Flock\'un seni böyle görür.';

  @override
  String get obPhotoPick => 'Fotoğraf seç';

  @override
  String get obPhotoChange => 'Fotoğrafı değiştir';

  @override
  String get obPhotoGallery => 'Galeriden seç';

  @override
  String get obPhotoTake => 'Fotoğraf çek';

  @override
  String get obPickFailed =>
      'Fotoğraf alınamadı — kamera/galeri iznini kontrol et.';

  @override
  String get obSelfieTitle => 'Gerçekten sen olduğunu doğrula';

  @override
  String get obSelfieSubtitle =>
      'Hızlı bir selfie çek. Her flock güvende kalsın diye fotoğrafınla eşleştiririz.';

  @override
  String get obSelfieTake => 'Selfie çek';

  @override
  String get obSelfieRetake => 'Yeniden çek';

  @override
  String get obSelfieDone => 'Selfie alındı ✓';

  @override
  String get obContinue => 'Devam';

  @override
  String get obFinish => 'Bitir ve Flock\'a gir';

  @override
  String get obSkip => 'Şimdilik geç';

  @override
  String get obSavedTitle => 'Her şey hazır!';

  @override
  String get obVerificationPending => 'Selfie doğrulaması incelemede.';

  @override
  String get obNotVerified => 'Doğrulanmadı';

  @override
  String get devSeed => 'Test flock\'ları oluştur';

  @override
  String devSeedDone(Object n) {
    return '$n test flock oluşturuldu ✓';
  }

  @override
  String get flockDetails => 'Flock detayı';

  @override
  String get flockClosed => 'Bu flock kapandı.';

  @override
  String get membersTitle => 'KATILANLAR';

  @override
  String get leaveFlock => 'Flock\'tan ayrıl';

  @override
  String get cancelFlock => 'Flock\'u iptal et';

  @override
  String get notifTitle => 'Bildirimler';

  @override
  String get notifEmpty => 'Henüz bildirim yok.';

  @override
  String notifJoined(Object name) {
    return '$name flock\'una katıldı';
  }

  @override
  String get agoNow => 'az önce';

  @override
  String agoMin(Object n) {
    return '$n dk önce';
  }

  @override
  String agoHour(Object n) {
    return '$n sa önce';
  }

  @override
  String agoDay(Object n) {
    return '$n g önce';
  }

  @override
  String get intCoffee => 'Kahve';

  @override
  String get intMusic => 'Müzik';

  @override
  String get intSports => 'Spor';

  @override
  String get intArt => 'Sanat';

  @override
  String get intTravel => 'Seyahat';

  @override
  String get intFood => 'Yemek';

  @override
  String get intGaming => 'Oyun';

  @override
  String get intMovies => 'Film';

  @override
  String get intBooks => 'Kitap';

  @override
  String get intFitness => 'Fitness';

  @override
  String get intNightlife => 'Gece hayatı';

  @override
  String get intNature => 'Doğa';

  @override
  String get intTech => 'Teknoloji';

  @override
  String get intPhotography => 'Fotoğrafçılık';
}
