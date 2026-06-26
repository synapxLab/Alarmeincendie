import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/alarm/exercise_audio.dart';
import '../../core/settings/config_provider.dart';

/// Écran plein écran affiché quand l'alarme d'entraînement sonne.
///
/// Un chronomètre démarre au déclenchement (temps d'évacuation). Deux actions :
/// mettre le son en sourdine (le chrono continue) puis terminer l'exercice.
class RingScreen extends ConsumerStatefulWidget {
  const RingScreen({super.key});

  @override
  ConsumerState<RingScreen> createState() => _RingScreenState();
}

class _RingScreenState extends ConsumerState<RingScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  final ExerciseAudio _audio = ExerciseAudio();
  Timer? _ticker;
  bool _muted = false;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    _startAudio();
  }

  /// Démarre nos deux pistes (sirène + voix) pour piloter les volumes en
  /// direct. Le plugin `alarm` ne joue qu'un silence (il maintient le service
  /// background / full-screen) : pas besoin de le couper ici, sinon le service
  /// s'arrêterait et le son pourrait être tué en arrière-plan.
  Future<void> _startAudio() async {
    await _audio.start();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _stopwatch.stop();
    _audio.dispose();
    super.dispose();
  }

  String get _elapsed {
    final s = _stopwatch.elapsed.inSeconds;
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  Future<void> _mute() async {
    setState(() => _muted = true);
    await _audio.mute(); // sirène à 50 %, plus d'annonces
  }

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    _ticker?.cancel();
    _stopwatch.stop();
    final notifier = ref.read(configProvider.notifier);
    await _audio.playDoneAndStop(); // « Exercice terminé. Merci »
    await Alarm.stopAll(); // coupe le service silence du plugin
    await notifier.rescheduleAfterRing(); // programme le prochain exercice
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD32F2F),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _muted
                      ? Icons.directions_run
                      : Icons.local_fire_department,
                  size: 96,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  _muted ? 'ÉVACUATION\nEN COURS' : 'EXERCICE\nÉVACUATION',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 24),
                // Chronomètre d'évacuation.
                Text(
                  _elapsed,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const Text(
                  'temps écoulé',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    onPressed: _muted ? null : _mute,
                    icon: Icon(_muted ? Icons.volume_down : Icons.volume_mute),
                    label: Text(
                      _muted ? 'Sourdine (50 %)' : 'Mettre en sourdine',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFD32F2F),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    onPressed: _finishing ? null : _finish,
                    icon: const Icon(Icons.check_circle),
                    label: const Text(
                      'Exercice terminé',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
