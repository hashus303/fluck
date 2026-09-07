import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/app_locale.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/fcm_service.dart';
import 'core/services/firebase_service.dart';
import 'core/services/location_controller.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/models/flock.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/auth/presentation/intro_screen.dart';
import 'features/flock/presentation/flock_detail_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/profile/data/user_profile.dart';
import 'features/profile/data/user_profile_repository.dart';
import 'features/premium/data/premium_service.dart';
import 'features/profile/presentation/onboarding_screen.dart';
import 'features/profile/presentation/verification_gate_screen.dart';
import 'features/home/presentation/map_screen.dart';
import 'features/invite/presentation/invite_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/chat/data/chat_repository.dart';
import 'features/date/data/likes_repository.dart';
import 'features/date/presentation/date_screen.dart';
import 'features/date/presentation/plus_sheet.dart';
import 'l10n/app_localizations.dart';

final localeController = LocaleController();
final themeController = ThemeController();
final locationController = LocationController();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Şemayı ilk kareden önce çöz — açılışta beyaz parlama olmasın.
  themeController.start();
  await FirebaseService.instance.init();
  // Uygulamayı hemen başlat — ilk kareyi hiçbir async işe bağlama.
  runApp(FluckApp(localeController: localeController, locationController: locationController));
  // Tercihleri arka planda yükle; controller değişimi bildirir, UI yenilenir.
  localeController.load();
  locationController.load();
  themeController.load();
  // Push bildirim: izin + token. Arka planda kur (akışı bloklamaz).
  FcmService.instance.init();
  // Bağlantı izleme — çevrimdışı şeridi buradan beslenir.
  ConnectivityService.instance.init();
}

class FluckApp extends StatelessWidget {
  final LocaleController localeController;
  final LocationController locationController;
  const FluckApp({super.key, required this.localeController, required this.locationController});

  @override
  Widget build(BuildContext context) {
    return LocationScope(
      controller: locationController,
      child: LocaleScope(
      controller: localeController,
      child: AnimatedBuilder(
        animation: Listenable.merge([localeController, themeController]),
        builder: (context, _) {
          return MaterialApp(
            title: 'Flock',
            debugShowCheckedModeBanner: false,
            scaffoldMessengerKey: FcmService.messengerKey,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeController.mode,
            locale: localeController.locale,
            supportedLocales: AppL10n.supportedLocales,
            localizationsDelegates: const [
              AppL10n.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) => _ResponsiveShell(child: child!),
            // AppColors token'ları statik okunduğundan const alt ağaçlar şema
            // değişiminde kendiliğinden yeniden çizilmez; anahtar bunu zorlar.
            home: KeyedSubtree(
              key: ValueKey(themeController.generation),
              child: const AuthGate(),
            ),
          );
        },
      ),
    ),
    );
  }
}

/// Geniş ekranlarda (web/tablet/masaüstü) içeriği telefon genişliğinde ortalar;
/// dar ekranlarda tam genişlik kullanır. "Her yer responsive" için tek kabuk.
class _ResponsiveShell extends StatelessWidget {
  final Widget child;
  const _ResponsiveShell({required this.child});

  /// Dar ekranda tam genişlik. Geniş ekranda içerik ortalanır ama artık
  /// telefon şeridi kadar dar değil: yan ray zaten yapıyı taşıyor, içerik de
  /// nefes alsın. Üstteki sınır yalnızca çok geniş masaüstü içindir.
  static const double _maxWidth = 1100;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final shell = width <= _maxWidth ? child : _centered();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlay(
          AppColors.isDark ? Brightness.dark : Brightness.light),
      // Şerit her ekranın üstünde: auth, onboarding ve uygulama içi hepsi
      // aynı uyarıyı görür.
      child: Column(children: [
        const _OfflineBar(),
        Expanded(child: shell),
      ]),
    );
  }

  Widget _centered() {
    return ColoredBox(
      color: AppColors.surfaceSunken,
      child: Center(
        child: ClipRect(
          child: SizedBox(
            width: _maxWidth,
            child: Material(color: AppColors.bgPage, child: child),
          ),
        ),
      ),
    );
  }
}

/// Çevrimdışıyken görünen ince şerit.
///
/// Hata değil DURUM bildirir: kırmızı değil uyarı tonunda, kapatılamaz (durum
/// geçince kendi kaybolur) ve içeriği kapatmaz — üstüne binmek yerine iter.
class _OfflineBar extends StatelessWidget {
  const _OfflineBar();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ConnectivityService.instance.online,
      builder: (context, online, _) {
        if (online) return const SizedBox.shrink();
        final t = AppL10n.of(context);
        return Material(
          color: AppColors.warning,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 6, 8),
              child: Row(children: [
                Icon(Icons.cloud_off_rounded,
                    size: 17, color: AppColors.onBrand),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(t.offlineBanner,
                      style: AppText.body(12.5,
                          weight: FontWeight.w700, color: AppColors.onBrand)),
                ),
                TextButton(
                  onPressed: ConnectivityService.instance.refresh,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.onBrand,
                    minimumSize: const Size(48, 40),
                  ),
                  child: Text(t.offlineRetry,
                      style: AppText.body(12.5,
                          weight: FontWeight.w800, color: AppColors.onBrand)),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }
}

/// Oturum kapısı — Firebase başlatıldıysa giriş durumuna göre AuthScreen ya da
/// uygulamayı gösterir. Firebase yoksa (yapılandırma eksik) doğrudan uygulamayı
/// açar, böylece backend olmadan da çalışır.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    if (!FirebaseService.instance.isInitialized) {
      return const RootScreen();
    }
    return StreamBuilder<User?>(
      stream: AuthRepository.instance.authState(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _GateLoading();
        }
        final user = snapshot.data;
        if (user == null) return const _IntroOrAuth();
        // Giriş yapılmış — profil tamamlandı mı kontrol et.
        return _ProfileGate(uid: user.uid, email: user.email);
      },
    );
  }
}

/// Giriş yapan kullanıcının profilini izler; onboarding bitmemişse onboarding,
/// bittiyse uygulamayı gösterir.
class _ProfileGate extends StatelessWidget {
  final String uid;
  final String? email;
  const _ProfileGate({required this.uid, this.email});

  @override
  Widget build(BuildContext context) {
    // Kullanıcı belli — FCM token'ını onun kaydına yaz (idempotent).
    FcmService.instance.registerFor(uid);
    // Flock+ yetkisini tazele (sunucu yazar, istemci yalnizca okur).
    PremiumService.instance.fetch();
    return StreamBuilder<UserProfile?>(
      stream: UserProfileRepository.instance.watch(uid),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _GateLoading();
        }
        final profile = snap.data;
        if (profile == null || !profile.onboardingComplete) {
          return OnboardingScreen(uid: uid, email: email);
        }
        // Doğrulama kapısı: selfie onaylanmadan uygulama açılmaz.
        // (Geliştirici muafiyeti YALNIZCA debug build'de — release'de arka
        // kapı yok; statü canlı izlendiğinden admin onayı gelince açılır.)
        final isDev = kDebugMode && email == 'haskartal303@gmail.com';
        if (!profile.isVerified && !isDev) {
          return VerificationGateScreen(profile: profile);
        }
        return const RootScreen();
      },
    );
  }
}

/// İlk açılışta karşılama carousel'ı, sonra (ya da tekrar açılışlarda) auth ekranı.
/// 'seen_intro' bayrağı SharedPreferences'ta tutulur.
class _IntroOrAuth extends StatefulWidget {
  const _IntroOrAuth();
  @override
  State<_IntroOrAuth> createState() => _IntroOrAuthState();
}

class _IntroOrAuthState extends State<_IntroOrAuth> {
  bool? _seen; // null = yükleniyor

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      if (mounted) setState(() => _seen = p.getBool('seen_intro') ?? false);
    } catch (_) {
      if (mounted) setState(() => _seen = true); // pref yoksa intro'yu atla
    }
  }

  Future<void> _finish() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool('seen_intro', true);
    } catch (_) {/* yine de geç */}
    if (mounted) setState(() => _seen = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_seen == null) return const _GateLoading();
    if (_seen!) return const AuthScreen();
    return IntroScreen(onDone: _finish);
  }
}

class _GateLoading extends StatelessWidget {
  const _GateLoading();
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.bgPage,
        body: Center(child: CircularProgressIndicator(color: AppColors.brand)),
      );
}

/// İki sayaç akışını toplayan küçük birleştirici.
///
/// rxdart eklemeye değmeyecek kadar küçük bir iş. Yayın (broadcast) akışı
/// döner: geniş ekranda alt bar ile yan ray birbirinin yerini alırken abone
/// gidip geliyor, tek abonelikli akış ikinci dinleyicide patlardı.
Stream<int> _sumStreams(Stream<int> a, Stream<int> b) {
  var x = 0, y = 0;
  StreamSubscription<int>? sa, sb;
  late final StreamController<int> c;
  c = StreamController<int>.broadcast(
    onListen: () {
      sa = a.listen((v) {
        x = v;
        c.add(x + y);
      }, onError: (_) {/* sayaç kritik değil */});
      sb = b.listen((v) {
        y = v;
        c.add(x + y);
      }, onError: (_) {});
    },
    onCancel: () async {
      await sa?.cancel();
      await sb?.cancel();
      sa = null;
      sb = null;
      x = 0;
      y = 0;
    },
  );
  return c.stream;
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

/// Alt bardan yan raya geçiş eşiği (Material'ın "medium" pencere sınıfı).
const double _railBreakpoint = 600;

class _RootScreenState extends State<RootScreen> {
  int _tab = 0;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// Date kalbindeki rozet: "Date'te seni bekleyen bir şey var" — gelen
  /// beğeniler + okunmamış sohbetler. İkisini ayrı ayrı göstermek alt barda
  /// yer bulamaz; ayrıntı zaten uzun basınca açılan panelde duruyor.
  ///
  /// Akış BİR KEZ kurulur: build içinde üretilirse her yeniden çizimde
  /// StreamBuilder yeni akışa abone olur ve Firestore dinleyicisi baştan
  /// kurulur.
  Stream<int>? _badge;

  Stream<int>? get badgeStream {
    final uid = _uid;
    if (uid == null) return null;
    return _badge ??= _sumStreams(
      LikesRepository.instance.incomingCount(uid),
      ChatRepository.instance.unreadCount(uid),
    );
  }

  void _openCreate() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => InviteScreen(onBack: () => Navigator.pop(context)),
      fullscreenDialog: true,
    ));
  }

  void _openDetail(Flock flock) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => FlockDetailScreen(flockId: flock.id, fallback: flock),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onOpenInvite: _openDetail),
      MapScreen(onOpenInvite: _openDetail),
      const DateScreen(),
      const ProfileScreen(),
    ];

    final stack = IndexedStack(index: _tab, children: screens);
    // Material'ın pencere boyut sınıfı: compact altında alt bar, medium ve
    // üstünde yan ray. Cihaz modeline değil GENİŞLİĞE bakılır — yatay
    // telefon ve bölünmüş ekran da doğru düzeni alır.
    final expanded = MediaQuery.sizeOf(context).width >= _railBreakpoint;

    if (expanded) {
      return Scaffold(
        backgroundColor: AppColors.bgPage,
        body: SafeArea(
          child: Row(children: [
            _FlockRail(
              active: _tab,
              onTap: (i) => setState(() => _tab = i),
              onCreate: _openCreate,
            ),
            Expanded(child: stack),
          ]),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: stack,
      bottomNavigationBar: _FlockNav(
        active: _tab,
        onTap: (i) => setState(() => _tab = i),
        onCreate: _openCreate,
        likesStream: badgeStream,
        onOpenPlus:
            _uid == null ? null : () => PlusSheet.show(context, _uid!),
      ),
    );
  }
}

/// Geniş ekran navigasyonu — Material'ın NavigationRail'i. Alt barın telefon
/// düzenini tablette/yatayda esnetmek yerine yapıyı değiştirir; "+" burada
/// rayın başındaki FAB olur, Material'ın kendi kalıbı.
class _FlockRail extends StatelessWidget {
  final int active;
  final ValueChanged<int> onTap;
  final VoidCallback onCreate;
  const _FlockRail({required this.active, required this.onTap, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    return NavigationRail(
      backgroundColor: AppColors.surfaceCard,
      indicatorColor: AppColors.brandSoft,
      selectedIndex: active,
      onDestinationSelected: onTap,
      labelType: NavigationRailLabelType.all,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: FloatingActionButton(
          onPressed: onCreate,
          backgroundColor: AppColors.brand,
          foregroundColor: AppColors.onBrand,
          tooltip: t.startAFlock,
          child: const Icon(Icons.add, size: 28),
        ),
      ),
      selectedIconTheme: IconThemeData(color: AppColors.brand, size: 24),
      unselectedIconTheme: IconThemeData(color: AppColors.textFaint, size: 24),
      selectedLabelTextStyle:
          AppText.body(11, weight: FontWeight.w700, color: AppColors.brand),
      unselectedLabelTextStyle:
          AppText.body(11, weight: FontWeight.w700, color: AppColors.textFaint),
      destinations: [
        NavigationRailDestination(
            icon: const Icon(Icons.home_rounded), label: Text(t.navHome)),
        NavigationRailDestination(
            icon: const Icon(Icons.map_rounded), label: Text(t.navMap)),
        NavigationRailDestination(
            icon: const Icon(Icons.favorite_rounded), label: Text(t.navDate)),
        NavigationRailDestination(
            icon: const Icon(Icons.person_rounded), label: Text(t.navProfile)),
      ],
    );
  }
}

/// Flock alt navigasyon barı — ortada coral "+" oluştur butonu.
class _FlockNav extends StatelessWidget {
  final int active;
  final ValueChanged<int> onTap;
  final VoidCallback onCreate;

  /// Gelen beğeni sayısı — Date kalbindeki rozet. Oturum yoksa null.
  final Stream<int>? likesStream;

  /// Date kalbine basılı tutunca açılan Flock+ paneli.
  final VoidCallback? onOpenPlus;

  const _FlockNav({
    required this.active,
    required this.onTap,
    required this.onCreate,
    this.likesStream,
    this.onOpenPlus,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            // stretch olmazsa cocuklar icerige gore boylanir ve dokunma
            // hedefi 64dp barda 33dp'de kalir.
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            _NavItem(icon: Icons.home_rounded, label: t.navHome, active: active == 0, onTap: () => onTap(0)),
            _NavItem(icon: Icons.map_rounded, label: t.navMap, active: active == 1, onTap: () => onTap(1)),
            Expanded(child: Center(child: _CreateButton(onTap: onCreate))),
            // Date kalbi: gelen beğeni rozeti + basılı tutunca Flock+ paneli.
            // Rozet Tinder'daki "seni beğenenler" göstergesinin işini görür ve
            // uzun basmayı keşfedilebilir kılar.
            _NavItem(
              icon: Icons.favorite_rounded,
              label: t.navDate,
              active: active == 2,
              onTap: () => onTap(2),
              onLongPress: onOpenPlus,
              badgeStream: likesStream,
              longPressHint: t.plusOpenHint,
            ),
            _NavItem(icon: Icons.person_rounded, label: t.navProfile, active: active == 3, onTap: () => onTap(3)),
          ]),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Stream<int>? badgeStream;
  final String? longPressHint;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.onLongPress,
    this.badgeStream,
    this.longPressHint,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.brand : AppColors.textFaint;
    return Expanded(
      child: Semantics(
        hint: longPressHint,
        child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        // Container barın tamamını kaplar: hem dokunma alanı hem de
        // ERİŞİLEBİLİRLİK DÜĞÜMÜ 64 dp olur. Yalnız Column bırakılırsa düğüm
        // içeriğe (33 dp) küçülür ve TalkBack'te hedef küçülür.
        child: Container(
          alignment: Alignment.center,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
          _icon(color),
          const SizedBox(height: 3),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.body(11, weight: FontWeight.w700, color: color)),
          ]),
        ),
      ),
      ),
    );
  }

  /// İkon + (varsa) gelen beğeni rozeti.
  Widget _icon(Color color) {
    final base = Icon(icon, size: 24, color: color);
    final stream = badgeStream;
    if (stream == null) return base;
    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snap) {
        final n = snap.data ?? 0;
        if (n <= 0) return base;
        return Stack(clipBehavior: Clip.none, children: [
          base,
          Positioned(
            right: -7,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(3),
              constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
              decoration: BoxDecoration(
                color: AppColors.brand,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surfaceCard, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(n > 9 ? '9+' : '$n',
                  style: AppText.body(9.5,
                      weight: FontWeight.w800, color: AppColors.onBrand)),
            ),
          ),
        ]);
      },
    );
  }
}

class _CreateButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CreateButton({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      label: AppL10n.of(context).startAFlock,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppColors.glowCoral,
        ),
        child: Material(
          color: AppColors.brand,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 52,
              height: 52,
              child: Icon(Icons.add, color: AppColors.onBrand, size: 28),
            ),
          ),
        ),
      ),
    );
  }
}
