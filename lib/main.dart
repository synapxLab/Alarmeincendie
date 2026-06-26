import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/home/home_screen.dart';
import 'features/ring/ring_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Alarm.init();
  runApp(const ProviderScope(child: AlertApp()));
}

class AlertApp extends StatefulWidget {
  const AlertApp({super.key});

  @override
  State<AlertApp> createState() => _AlertAppState();
}

class _AlertAppState extends State<AlertApp> {
  // Évite d'empiler plusieurs RingScreen : le stream `Alarm.ringing`
  // peut émettre plusieurs fois pour une même sonnerie.
  bool _ringScreenOpen = false;

  @override
  void initState() {
    super.initState();
    // Quand l'alarme sonne, on bascule sur l'écran plein écran.
    Alarm.ringing.listen((alarmSet) {
      if (alarmSet.alarms.isEmpty) {
        _ringScreenOpen = false;
        return;
      }
      if (_ringScreenOpen) return; // déjà affiché
      _ringScreenOpen = true;
      navigatorKey.currentState
          ?.push(
            MaterialPageRoute<void>(
              builder: (_) => const RingScreen(),
              fullscreenDialog: true,
            ),
          )
          .whenComplete(() => _ringScreenOpen = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alert incendie',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD32F2F)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
