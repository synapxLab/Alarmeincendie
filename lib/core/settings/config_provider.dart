import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../alarm/alarm_scheduler.dart';
import '../alarm/permissions.dart';
import 'alarm_config.dart';
import 'settings_repository.dart';

final configProvider =
    AsyncNotifierProvider<ConfigNotifier, AlarmConfig>(ConfigNotifier.new);

class ConfigNotifier extends AsyncNotifier<AlarmConfig> {
  final _repo = SettingsRepository();
  final _scheduler = AlarmScheduler();

  @override
  Future<AlarmConfig> build() => _repo.load();

  AlarmConfig get _current => state.value ?? const AlarmConfig();

  /// Active/désactive l'entraînement.
  Future<void> setEnabled(bool enabled) async {
    if (enabled) {
      await requestAlarmPermissions();
      await _applyAndReschedule(_current.copyWith(enabled: true));
    } else {
      await _scheduler.cancel();
      await _persist(_current.copyWith(enabled: false, clearNextRing: true));
    }
  }

  Future<void> setFrequency(int perYear) async {
    final cfg = _current.copyWith(frequencyPerYear: perYear.clamp(1, 4));
    if (cfg.enabled) {
      await _applyAndReschedule(cfg);
    } else {
      await _persist(cfg);
    }
  }

  Future<void> setWindow({TimeOfDay? start, TimeOfDay? end}) async {
    final cfg = _current.copyWith(start: start, end: end);
    if (cfg.enabled) {
      await _applyAndReschedule(cfg);
    } else {
      await _persist(cfg);
    }
  }

  /// Déclenche une sonnerie de test dans [delay].
  Future<DateTime> triggerTest({
    Duration delay = const Duration(seconds: 10),
  }) async {
    await requestAlarmPermissions();
    return _scheduler.scheduleTest(delay: delay);
  }

  /// Modifie la fréquence de vérification des mises à jour.
  Future<void> setUpdateFrequency(int hours) =>
      _persist(_current.copyWith(updateCheckHours: hours));

  /// Mémorise l'instant de la dernière vérification de mise à jour.
  Future<void> markUpdateChecked() =>
      _persist(_current.copyWith(lastUpdateCheck: DateTime.now()));

  /// Coupe le son de l'alarme en cours (le chrono d'exercice continue).
  Future<void> muteAlarm() => _scheduler.stopRinging();

  /// Appelé après une sonnerie : on programme la suivante.
  Future<void> rescheduleAfterRing() async {
    if (!_current.enabled) return;
    await _applyAndReschedule(_current);
  }

  /// Tire une nouvelle date, pose l'alarme et persiste.
  Future<void> _applyAndReschedule(AlarmConfig cfg) async {
    final next = _scheduler.computeNextRing(cfg, DateTime.now());
    await _scheduler.schedule(next);
    await _persist(cfg.copyWith(nextRing: next));
  }

  Future<void> _persist(AlarmConfig cfg) async {
    await _repo.save(cfg);
    state = AsyncData(cfg);
  }
}
