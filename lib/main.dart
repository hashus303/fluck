import 'package:flutter/material.dart';

import 'core/services/firebase_service.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/invite/presentation/invite_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/safety/presentation/safety_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.instance.init();
  runApp(const FluckApp());
}

class FluckApp extends StatelessWidget {
  const FluckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fluck',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const RootScreen(),
    );
  }
}

/// Feature ekranları arasında geçiş için basit bir alt menü iskeleti.
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;

  static const _screens = <Widget>[
    HomeScreen(),
    InviteScreen(),
    SafetyScreen(),
    ProfileScreen(),
    AuthScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.mail), label: 'Invite'),
          NavigationDestination(icon: Icon(Icons.shield), label: 'Safety'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          NavigationDestination(icon: Icon(Icons.login), label: 'Auth'),
        ],
      ),
    );
  }
}
