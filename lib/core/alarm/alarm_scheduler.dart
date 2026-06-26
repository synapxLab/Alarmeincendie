import 'dart:math';

import 'package:alarm/alarm.dart';

import '../settings/alarm_config.dart';

/// Programme l'alarme d'entraînement incendie via le plugin `alarm`.
///
/// Une seule alarme est posée à la fois (id [_alarmId]). À chaque
/// (ré)activation ou après une sonnerie, on tire la prochaine date.
class AlarmScheduler {
  AlarmScheduler({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const int _alarmId = 1;

  /// Calcule la date de la prochaine sonnerie à partir de [from].
  ///
  /// Espacement moyen = 365 / fréquence jours, avec un facteur aléatoire
  /// entre 0,4 et 1,6 pour répartir les déclenchements sur l'année. L'heure
  /// est tirée au hasard dans la plage de nuit configurée.
  DateTime computeNextRing(AlarmConfig config, DateTime from) {
    final meanDays = 365.0 / config.frequencyPerYear;
    final factor = 0.4 + _random.nextDouble() * 1.2;
    final offsetDays = (meanDays * factor).round().clamp(1, 730);

    final targetDay = DateTime(from.year, from.month, from.day)
        .add(Duration(days: offsetDays));

    // Début de la plage ce jour-là, puis décalage aléatoire dans la fenêtre.
    final windowStart = DateTime(
      targetDay.year,
      targetDay.month,
      targetDay.day,
      config.start.hour,
      config.start.minute,
    );
    final minutesInto = _random.nextInt(config.windowMinutes);
    var ring = windowStart.add(Duration(minutes: minutesInto));

    // Filet de sécurité : jamais dans le passé.
    final earliest = from.add(const Duration(minutes: 2));
    if (ring.isBefore(earliest)) {
      ring = earliest;
    }
    return ring;
  }

  /// Déclenche une sonnerie de test après [delay] (pour vérifier le rendu).
  Future<DateTime> scheduleTest({
    Duration delay = const Duration(seconds: 10),
  }) async {
    final ring = DateTime.now().add(delay);
    await schedule(ring);
    return ring;
  }

  /// Pose l'alarme dans le système pour la date [ring].
  Future<void> schedule(DateTime ring) async {
    final settings = AlarmSettings(
      id: _alarmId,
      dateTime: ring,
      // Le plugin ne joue qu'un silence : il sert au réveil / full-screen
      // intent / service background. Tout le son audible (sirène + voix) est
      // géré par `just_audio` dans RingScreen, pour pouvoir piloter le volume.
      // Le volume du flux alarme est forcé à fond pour que just_audio le soit.
      assetAudioPath: 'assets/silence.wav',
      loopAudio: true,
      vibrate: true,
      warningNotificationOnKill: false,
      androidFullScreenIntent: true,
      volumeSettings: VolumeSettings.fixed(
        volume: 1.0,
        volumeEnforced: true,
      ),
      notificationSettings: const NotificationSettings(
        title: '🔥 Exercice d\'évacuation incendie',
        body: 'Évacuez calmement. Appuyez pour arrêter l\'alarme.',
        stopButton: 'J\'ai évacué',
      ),
    );
    await Alarm.set(alarmSettings: settings);
  }

  /// Annule l'alarme programmée.
  Future<void> cancel() => Alarm.stop(_alarmId);

  /// Arrête la sonnerie en cours.
  Future<void> stopRinging() => Alarm.stop(_alarmId);
}
