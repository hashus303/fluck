import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/app_locale.dart';
import 'core/services/firebase_service.dart';
import 'core/services/location_controller.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/models/flock.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/flock/presentation/flock_detail_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/profile/data/user_profile.dart';
import 'features/profile/data/user_profile_repository.dart';
import 'features/profile/presentation/onboarding_screen.dart';
import 'features/home/presentation/map_screen.dart';
import 'features/invite/presentation/invite_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/safety/presentation/safety_screen.dart';
import 'l10n/app_localizations.dart';

final localeController = LocaleController();
final locationController = LocationController();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.instance.init();
  // Uygulamayı hemen başlat — ilk kareyi hiçbir async işe bağlama.
  runApp(FluckApp(localeController: localeController, locationController: locationController));
  // Tercihleri arka planda yükle; controller değişimi bildirir, UI yenilenir.
  localeController.load();
  locationController.load();
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
        animation: localeController,
        builder: (context, _) {
          return MaterialApp(
            title: 'Flock',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            locale: localeController.locale,
            supportedLocales: AppL10n.supportedLocales,
            localizationsDelegates: const [
              AppL10n.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) => _ResponsiveShell(child: child!),
            home: const AuthGate(),
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

  static const double _maxWidth = 480;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width <= _maxWidth) return child;
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
        if (user == null) return const AuthScreen();
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
        return const RootScreen();
      },
    );
  }
}

class _GateLoading extends StatelessWidget {
  const _GateLoading();
  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: AppColors.bgPage,
        body: Center(child: CircularProgressIndicator(color: AppColors.brand)),
      );
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _tab = 0;

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
      const SafetyScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: IndexedStack(index: _tab, children: screens),
      bottomNavigationBar: _FlockNav(
        active: _tab,
        onTap: (i) => setState(() => _tab = i),
        onCreate: _openCreate,
      ),
    );
  }
}

/// Flock alt navigasyon barı — ortada coral "+" oluştur butonu.
class _FlockNav extends StatelessWidget {
  final int active;
  final ValueChanged<int> onTap;
  final VoidCallback onCreate;
  const _FlockNav({required this.active, required this.onTap, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(children: [
            _NavItem(icon: Icons.home_rounded, label: t.navHome, active: active == 0, onTap: () => onTap(0)),
            _NavItem(icon: Icons.map_rounded, label: t.navMap, active: active == 1, onTap: () => onTap(1)),
            Expanded(child: Center(child: _CreateButton(onTap: onCreate))),
            _NavItem(icon: Icons.shield_rounded, label: t.navSafety, active: active == 2, onTap: () => onTap(2)),
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
  const _NavItem({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.brand : AppColors.textFaint;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 3),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.body(11, weight: FontWeight.w700, color: color)),
        ]),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CreateButton({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          color: AppColors.brand,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppColors.glowCoral,
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
