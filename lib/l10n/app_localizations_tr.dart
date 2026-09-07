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
  String get homeSubtitle => 'Plan yapma — bir vibe seç, katıl, çık.';

  @override
  String get allVibes => 'Tüm vibe\'lar';

  @override
  String get surpriseMe => 'Şansına bırak';

  @override
  String get surpriseTitle => 'Kaderin flock\'u';

  @override
  String get surpriseSubtitle => 'Zar bunu seçti — gerisi sende.';

  @override
  String get spinAgain => 'Tekrar çevir';

  @override
  String get surpriseNone => 'Şu an çevrilecek flock yok — ilkini sen başlat ✦';

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
  String get safetyLede => 'Doğrulama durumun ve engellediğin kişiler.';

  @override
  String get blockedTitle => 'Engellediklerin';

  @override
  String blockedCount(int n) {
    return '$n kişi engelli';
  }

  @override
  String get blockedEmpty => 'Kimseyi engellemedin.';

  @override
  String get blockedEmptyHint =>
      'Rahatsız eden birini flock\'undan engelleyebilirsin — akışından kaybolur.';

  @override
  String get unblock => 'Engeli kaldır';

  @override
  String get unblockDone => 'Engel kaldırıldı.';

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
  String get deleteAccount => 'Hesabı sil';

  @override
  String get deleteAccountTitle => 'Hesabın silinsin mi?';

  @override
  String get deleteAccountBody =>
      'Profilin ve bildirimlerin kalıcı olarak silinir. Bu işlem geri alınamaz.';

  @override
  String get deleteAccountReauth =>
      'Güvenlik için yakın zamanda giriş yapılmış olmalı — çıkış yapıp yeniden giriş yaptıktan sonra tekrar dene.';

  @override
  String get cancel => 'Vazgeç';

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
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeLight => 'Açık';

  @override
  String get themeDark => 'Koyu';

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
  String get howLong => 'NE KADAR SÜRE AKTİF?';

  @override
  String get duration30m => '30 dk';

  @override
  String get duration1h => '1 saat';

  @override
  String get duration2h => '2 saat';

  @override
  String expiryNoteFor(String label) {
    return 'Davetin anında yayına girer ve $label sonra sona erer.';
  }

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
  String postInviteFor(String label) {
    return 'Daveti yayınla · $label aktif';
  }

  @override
  String inviteLiveFor(String label) {
    return 'Davetin $label boyunca aktif 🎉';
  }

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
  String get locGpsFailed => 'Konum alınamadı — tekrar dene.';

  @override
  String get locServiceOff => 'Konum servisi kapalı — telefonunun konumunu aç.';

  @override
  String get locPermDenied => 'Konum izni verilmedi.';

  @override
  String get locPermDeniedForever =>
      'Konum izni kapalı — Ayarlar\'dan açman gerekiyor.';

  @override
  String get locOpenSettings => 'Ayarları aç';

  @override
  String get introSlide1Title => 'Planlama yok.';

  @override
  String get introSlide1Body =>
      'Flock\'u aç, yakınındaki canlı davetleri gör, tek dokunuşla bir gruba katıl — kahve, yürüyüş, oyun.';

  @override
  String get introSlide2Title => 'Seçemiyorsan zar at.';

  @override
  String get introSlide2Body =>
      'Zar sana yakın rastgele bir flock seçer. Sıfır düşünce — sadece git.';

  @override
  String get introSlide3Title => 'Hep grup. Doğrulanmış kişiler.';

  @override
  String get introSlide3Body =>
      'Asla bire bir değil — her flock en az 3 kişi. Herkes selfie ile doğrulanır.';

  @override
  String get introSkip => 'Atla';

  @override
  String get introNext => 'İleri';

  @override
  String get introStart => 'Başla';

  @override
  String get navDiscover => 'Keşfet';

  @override
  String get discoverTitle => 'Keşfet';

  @override
  String get discoverLede => 'Şu an çevrende neler oluyor.';

  @override
  String get discoverRollTitle => 'Şansına bırak';

  @override
  String get discoverRollBody =>
      'Kader sana yakın bir flock seçsin — tek dokunuşla katıl.';

  @override
  String get discoverDateTitle => 'Date modu';

  @override
  String get discoverDateBody =>
      'Yakınındaki tanışmak isteyen doğrulanmış kişileri kaydır.';

  @override
  String get discoverNearbyTitle => 'Yakınındakiler';

  @override
  String get discoverNearbyBody =>
      'Çevrendeki doğrulanmış kişileri gör, flock’una davet et.';

  @override
  String get discoverByVibe => 'Vibe’a göre gez';

  @override
  String discoverPulseLive(int n) {
    return 'Yakınında $n flock aktif';
  }

  @override
  String get discoverPulseNone => 'Henüz aktif flock yok — ilkini sen başlat.';

  @override
  String get discoverStartOne => 'Flock başlat';

  @override
  String get plusBadge => 'Flock+';

  @override
  String get navDate => 'Date';

  @override
  String get dateTitle => 'Date modu';

  @override
  String get dateLede =>
      'Yakınındaki doğrulanmış kişiler — flock\'una davet et.';

  @override
  String get dateLockedTitle => 'Sadece flock değil, insan da keşfet';

  @override
  String get dateLockedBody =>
      'Çevrendeki doğrulanmış kişilere göz at, beğendiğini flock\'una davet et. Buluşma her zaman grupça — en az 3 kişi.';

  @override
  String get dateUnlockCta => 'Flock+ ile aç';

  @override
  String get dateSoonTitle => 'Desten hazırlanıyor';

  @override
  String get dateSoonBody =>
      'Yakındaki kişilere göz atma çok yakında açılıyor — Flock+ üyesi olduğun için ilk sen deneyeceksin.';

  @override
  String get plusTitle => 'Flock+';

  @override
  String get plusTagline => 'Daha çok insanla, daha sık buluş.';

  @override
  String get plusTrialBadge => 'İlk 14 gün ücretsiz';

  @override
  String get plusPriceLine => 'Sonra ₺99/ay. İstediğin an iptal et.';

  @override
  String get plusFeatureNearbyTitle => 'Seni kim beğendi';

  @override
  String get plusFeatureNearbyBody =>
      'Seninle flock kurmak isteyenleri gör — karşılık ver.';

  @override
  String get plusFeatureDateTitle => 'Date modu';

  @override
  String get plusFeatureDateBody =>
      'Yakındaki doğrulanmış kişilere göz at, beğendiğini flock\'una davet et.';

  @override
  String get plusFeatureUnlimitedTitle => 'Sınırsız flock + boost';

  @override
  String get plusFeatureUnlimitedBody =>
      'İstediğin kadar aç, seninkini en üste taşı.';

  @override
  String get plusFeatureFiltersTitle => 'Gelişmiş filtreler';

  @override
  String get plusFeatureFiltersBody =>
      'Sadece-doğrulanmışlar modu, vibe ve mesafe filtreleri.';

  @override
  String get plusCta => 'Ücretsiz denemeyi başlat';

  @override
  String get plusHonestNote =>
      'Deneme bitmeden 24 saat önce push ve e-postayla hatırlatırız. İptal tek dokunuş.';

  @override
  String get plusRestore => 'Satın alımı geri yükle';

  @override
  String get plusActiveTitle => 'Flock+ aktif';

  @override
  String plusTrialActiveTitle(int days) {
    return 'Flock+ deneme — $days gün kaldı';
  }

  @override
  String get plusManage => 'Aboneliği yönet';

  @override
  String get plusLockedTitle => 'Flock+ özelliği';

  @override
  String get plusLockedBody => 'Bunu Flock+ ile aç — ilk 14 gün ücretsiz.';

  @override
  String get plusSoon =>
      'Abonelikler yakında açılıyor — ilk sen haberdar olacaksın.';

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
  String get passwordConfirm => 'Şifre (tekrar)';

  @override
  String get emailHint => 'sen@ornek.com';

  @override
  String get passwordHint => 'En az 6 karakter';

  @override
  String get passwordConfirmHint => 'Şifreni tekrar gir';

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
  String get continueWithGoogle => 'Google ile devam et';

  @override
  String get orDivider => 'veya';

  @override
  String get errEmailRequired => 'E-postanı gir';

  @override
  String get errEmailInvalid => 'Geçerli bir e-posta gir';

  @override
  String get errPasswordRequired => 'Şifreni gir';

  @override
  String get errPasswordShort => 'Şifre en az 6 karakter olmalı';

  @override
  String get errPasswordConfirmRequired => 'Şifreni tekrar gir';

  @override
  String get errPasswordMismatch => 'Şifreler eşleşmiyor';

  @override
  String get errInvalidCredentials => 'E-posta veya şifre hatalı';

  @override
  String get errEmailInUse => 'Bu e-posta zaten kayıtlı';

  @override
  String get errWeakPassword => 'Şifre çok zayıf';

  @override
  String get errNetwork => 'Ağ hatası — bağlantını kontrol et';

  @override
  String get errGoogleReauth =>
      'Google hesabın bu girişi onaylayamadı. Şimdilik e-posta ile giriş yapabilirsin.';

  @override
  String get errGoogleNoAccount =>
      'Telefonunda ekli Google hesabı yok. Ayarlar\'dan bir hesap ekle ya da e-posta ile giriş yap.';

  @override
  String get errGoogleConfig =>
      'Google girişi bu sürümde açılamıyor. Şimdilik e-posta ile giriş yapabilirsin.';

  @override
  String get errGoogleInterrupted =>
      'Google girişi yarıda kesildi. Bağlantını kontrol edip tekrar dene.';

  @override
  String get errGoogleGeneric =>
      'Google ile giriş yapılamadı. Tekrar dene ya da e-posta ile giriş yap.';

  @override
  String get a11yBack => 'Geri';

  @override
  String get a11yClose => 'Kapat';

  @override
  String get a11yShowPassword => 'Şifreyi göster';

  @override
  String get a11yHidePassword => 'Şifreyi gizle';

  @override
  String get a11yNotifications => 'Bildirimler';

  @override
  String a11yUnreadCount(int count) {
    return '$count okunmamış bildirim';
  }

  @override
  String get a11yMyLocation => 'Konumuma git';

  @override
  String get a11ySearchPlace => 'Yeri ara';

  @override
  String a11yRateStars(int count) {
    return '$count yıldız ver';
  }

  @override
  String get a11yChangePhoto => 'Profil fotoğrafını değiştir';

  @override
  String get a11yPickPhoto => 'Fotoğraf seç';

  @override
  String a11yAvatarOf(String name) {
    return '$name profil fotoğrafı';
  }

  @override
  String get a11yAppLogo => 'Flock logosu';

  @override
  String get offlineBanner => 'İnternet yok — bağlantını kontrol et';

  @override
  String get offlineRetry => 'Yeniden dene';

  @override
  String get notifSection => 'Bildirimler';

  @override
  String get notifJoins => 'Flock hareketleri';

  @override
  String get notifJoinsBody => 'Biri flock\'una katıldığında';

  @override
  String get notifMessages => 'Mesajlar';

  @override
  String get notifMessagesBody => 'Sana mesaj geldiğinde';

  @override
  String get notifAnnouncements => 'Duyurular';

  @override
  String get notifAnnouncementsBody => 'Flock ekibinden haberler';

  @override
  String get notifVerification => 'Doğrulama sonucu';

  @override
  String get notifVerificationBody => 'Selfie doğrulaman sonuçlandığında';

  @override
  String get notifAllOffHint =>
      'Hepsini kapatırsan uygulamayı açtığında yine de görürsün.';

  @override
  String get dateOptInTitle => 'Date modunu aç';

  @override
  String get dateOptInBody =>
      'Açtığında sen de destede görünürsün — sadece bakan olmaz, sen de bakılırsın. Yalnızca doğrulanmış hesaplar birbirini görür.';

  @override
  String get dateOptInPrivacy =>
      'Konumun ~1 km yuvarlanarak saklanır, tam adresin asla paylaşılmaz. İstediğin an kapatırsan konumun silinir.';

  @override
  String get dateOptInCta => 'Beni de göster';

  @override
  String get dateOptOut => 'Date modundan çık';

  @override
  String get datePass => 'Geç';

  @override
  String get dateLike => 'Beğen';

  @override
  String get dateSwipeHint => 'Sağa kaydır beğen, sola geç';

  @override
  String get dateUnder1Km => '1 km\'den yakın';

  @override
  String get dateEmptyTitle => 'Şimdilik bu kadar';

  @override
  String get dateEmptyBody =>
      'Çevrende gösterilecek yeni kimse kalmadı. Yakında yeni kişiler katılacak — sonra tekrar bak.';

  @override
  String get dateDeckRefresh => 'Yenile';

  @override
  String get dateDeckRetry => 'Deste yüklenemedi.';

  @override
  String dateMutual(String name) {
    return '$name de seni beğenmiş — artık yazışabilirsiniz.';
  }

  @override
  String get dateMutualCta => 'Mesaj at';

  @override
  String get plusSheetLede => 'Seni beğenenler ve abonelik durumun.';

  @override
  String get plusAdmirersTitle => 'Seni beğenenler';

  @override
  String get plusAdmirersEmpty =>
      'Henüz kimse beğenmedi. Destede dolaşmaya devam et — seni beğenen olunca burada görünür.';

  @override
  String get plusAdmirersError =>
      'Liste yüklenemedi. Bağlantını kontrol edip tekrar aç.';

  @override
  String get plusLikedYouHint => 'Seni beğendi';

  @override
  String get plusMutualHint => 'İkiniz de beğendiniz — yazışabilirsiniz.';

  @override
  String get plusMutualBadge => 'Karşılıklı';

  @override
  String get plusLikeBack => 'Karşılık ver';

  @override
  String get plusStatusTitle => 'Aboneliğin';

  @override
  String get plusMessagesRow => 'Mesajlar';

  @override
  String get plusMessagesRowHint => 'Karşılıklı beğendiklerinle yazış';

  @override
  String get plusOpenHint => 'Kalbe basılı tut';

  @override
  String get chatInboxTitle => 'Mesajlar';

  @override
  String get chatOpen => 'Mesajlar';

  @override
  String get chatNewMatches => 'YENİ EŞLEŞMELER';

  @override
  String get chatConversations => 'KONUŞMALAR';

  @override
  String get chatNoConversations =>
      'Henüz yazışma yok. Yukarıdan birine ilk sözü söyle.';

  @override
  String get chatNoMatches =>
      'Henüz eşleşme yok. Destede beğen — karşılıklı olduğunda burada buluşursunuz.';

  @override
  String get chatEmptyThread => 'Burası boş. İlk sözü sen söyle.';

  @override
  String get chatComposerHint => 'Mesaj yaz…';

  @override
  String get chatSend => 'Gönder';

  @override
  String get chatSendFailed => 'Mesaj gönderilemedi. Bağlantını kontrol et.';

  @override
  String get chatLoadFailed =>
      'Sohbet yüklenemedi. Bağlantını kontrol edip tekrar aç.';

  @override
  String get chatToday => 'Bugün';

  @override
  String get chatYesterday => 'Dün';

  @override
  String get chatYou => 'Sen';

  @override
  String get chatCopy => 'Kopyala';

  @override
  String get chatDelete => 'Mesajı sil';

  @override
  String get chatMore => 'Seçenekler';

  @override
  String get chatMutualSubtitle => 'Karşılıklı beğeni';

  @override
  String get chatFlockCta => 'Sohbet';

  @override
  String get chatFlockJoinFirst => 'Sohbet için önce flock\'a katıl';

  @override
  String get chatFlockClosed =>
      'Bu flock sona erdi — sohbet kapandı. Geçmişi okuyabilirsin.';

  @override
  String chatFlockSubtitle(int count) {
    return '$count kişi';
  }

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
  String get obSelfieNoFace =>
      'Selfie\'de yüz algılanamadı — yüzün net görünecek şekilde tekrar çek.';

  @override
  String get obSelfieChallengeLabel => 'Doğrulama için:';

  @override
  String get obSelfieChSmile => 'gülümse 😊';

  @override
  String get obSelfieChTurn => 'başını hafifçe yana çevir ↩️';

  @override
  String get obSelfieChTilt => 'başını hafifçe yana eğ 🙂↕️';

  @override
  String obSelfieWrongPose(String pose) {
    return 'İstenen hareketi göremedik. Tekrar dene: $pose';
  }

  @override
  String get verifPendingTitle => 'Selfie\'n incelemede';

  @override
  String get verifPendingBody =>
      'Güvenlik için her profili gerçek bir insan onaylıyor. Genellikle kısa sürer — onaylanınca uygulama otomatik açılır.';

  @override
  String get verifRejectedTitle => 'Selfie doğrulanamadı';

  @override
  String get verifRejectedBody =>
      'Yüzünün net göründüğü yeni bir selfie çek — hemen tekrar incelemeye alınır.';

  @override
  String get verifRetake => 'Yeni selfie çek';

  @override
  String get verifNeedTitle => 'Son adım: doğrulama';

  @override
  String get verifNeedBody =>
      'Devam etmek için yüzünü net gösteren bir selfie çek. İncelenip onaylanınca uygulama açılır.';

  @override
  String get verifResend => 'Selfie\'yi yeniden gönder';

  @override
  String get notifVerifApproved => 'Profilin doğrulandı 🎉';

  @override
  String get notifVerifRejected => 'Selfie doğrulanamadı — yeniden dene';

  @override
  String get ratePromptTitle => 'Nasıl geçti?';

  @override
  String ratePromptBody(String venue) {
    return '\'$venue\' buluşması sona erdi — üyeleri puanla.';
  }

  @override
  String get rateAction => 'Puanla';

  @override
  String get rateSkip => 'Şimdi değil';

  @override
  String get rateThanks => 'Teşekkürler! Puanların kaydedildi.';

  @override
  String get rateAlready => 'Bu üyeyi zaten puanladın.';

  @override
  String get rateDone => 'Bitti';

  @override
  String get reportUser => 'Şikayet et';

  @override
  String get blockUser => 'Engelle';

  @override
  String get blockConfirmTitle => 'Engellensin mi?';

  @override
  String get blockConfirmBody =>
      'Engellediğin kişinin flock\'larını artık görmezsin. Bu işlem şimdilik geri alınamaz.';

  @override
  String get blockDone => 'Engellendi.';

  @override
  String get reportTitle => 'Neyi bildirmek istersin?';

  @override
  String get reportReasonHarassment => 'Taciz / rahatsız etme';

  @override
  String get reportReasonFake => 'Sahte profil';

  @override
  String get reportReasonNoShow => 'Buluşmaya gelmedi';

  @override
  String get reportReasonSafety => 'Güvenlik endişesi';

  @override
  String get reportReasonOther => 'Diğer';

  @override
  String get reportNoteHint => 'İstersen kısaca anlat (opsiyonel)';

  @override
  String get reportSend => 'Gönder';

  @override
  String get reportThanks => 'Şikayetin alındı — inceleyeceğiz.';

  @override
  String get statRatingReal => 'Ortalama puan';

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
  String get notifAnnouncement => 'Duyuru';

  @override
  String get notifWarning => 'Uyarı';

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
