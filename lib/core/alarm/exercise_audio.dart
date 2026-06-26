// Ce fichier gère TOUT le son entendu pendant un exercice d'évacuation :
// la sirène (qui tourne en boucle) et les annonces vocales par-dessus.
//
// Petit rappel de Dart pour s'y retrouver :
//   - `Future<void>` = une opération qui se termine « plus tard » (asynchrone).
//   - `async` / `await` = « attends que cette opération soit finie avant de
//     passer à la ligne suivante ».
//   - `unawaited(...)` = au contraire « lance ça mais NE m'attends pas, je
//     continue tout de suite ». C'est crucial ici (voir plus bas).

import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

/// Pilote le son de l'écran d'exercice : sirène en boucle + annonces vocales,
/// avec contrôle du volume en direct.
///
/// Déroulé sonore :
///   - la sirène démarre et tourne en boucle ;
///   - une annonce « Veuillez évacuer… » est jouée dès le début, puis répétée
///     toutes les 30 s ; pendant chaque annonce la sirène baisse à 20 % pour
///     qu'on entende bien la voix, puis elle remonte à 100 % ;
///   - bouton « Mettre en sourdine » : la sirène passe à 50 % et les annonces
///     s'arrêtent ;
///   - bouton « Exercice terminé » : la sirène descend en fondu de 20 % à 0
///     pendant que joue le message « Exercice terminé. Merci ».
class ExerciseAudio {
  ExerciseAudio();

  // Chemins des fichiers son embarqués dans l'application (déclarés dans
  // pubspec.yaml, section `assets`).
  static const _siren = 'assets/alarme.wav';
  static const _voiceEvacuation = 'assets/voice/evacuation.mp3';
  static const _voiceDone = 'assets/voice/exercice_termine.mp3';

  // Les différents niveaux de volume de la sirène (1.0 = 100 %, 0.0 = muet).
  static const double _fullVolume = 1.0; // sirène normale
  static const double _duckedVolume = 0.2; // sirène pendant une annonce (20 %)
  static const double _mutedVolume = 0.5; // sirène en sourdine (50 %)

  // Quand jouer les annonces : la première 6 s après le démarrage de la sirène
  // (la sirène sonne donc seule pendant 6 s), puis une annonce toutes les 30 s.
  static const Duration _firstAnnounce = Duration(seconds: 6);
  static const Duration _announcePeriod = Duration(seconds: 30);

  // Deux lecteurs audio indépendants qui jouent EN MÊME TEMPS : l'un pour la
  // sirène, l'autre pour la voix. C'est ce qui permet de mixer les deux.
  final AudioPlayer _sirenPlayer = AudioPlayer();
  final AudioPlayer _voicePlayer = AudioPlayer();

  // Drapeaux d'état internes.
  bool _disposed = false; // vrai quand l'écran est fermé (on doit tout arrêter)
  bool _muted = false; // vrai après « Mettre en sourdine » ou en fin d'exercice

  // Durée du fichier d'annonce, mesurée au chargement. Sert à savoir combien de
  // temps attendre avant de remonter la sirène. Valeur de secours par défaut.
  Duration _evacDuration = const Duration(milliseconds: 6300);

  /// Démarre la sirène en boucle puis lance le cycle d'annonces.
  /// Appelé une seule fois, à l'ouverture de l'écran d'exercice.
  Future<void> start() async {
    // 1) On configure la « session audio » du téléphone pour que le son sorte
    //    sur le canal ALARME (volume alarme, audible même en mode silencieux).
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback, // iOS
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.sonification,
        usage: AndroidAudioUsage.alarm, // canal « alarme »
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
    ));

    // 2) On charge la sirène, on la met en boucle (LoopMode.one = répète le
    //    même morceau indéfiniment) et à plein volume.
    await _sirenPlayer.setAsset(_siren);
    await _sirenPlayer.setLoopMode(LoopMode.one);
    await _sirenPlayer.setVolume(_fullVolume);

    // 3) On charge l'annonce une première fois pour connaître sa durée.
    //    `setAsset` renvoie la durée du fichier (ou null si inconnue, d'où le
    //    `?? _evacDuration` qui garde la valeur par défaut dans ce cas).
    _evacDuration =
        await _voicePlayer.setAsset(_voiceEvacuation) ?? _evacDuration;

    // Si l'écran a été fermé entre-temps, on ne démarre rien.
    if (_disposed) return;

    // 4) On lance la lecture de la sirène. ATTENTION : on n'écrit PAS
    //    `await _sirenPlayer.play()`. Avec just_audio, le « Future » de play()
    //    ne se termine qu'à la FIN de la lecture ; or la sirène boucle sans
    //    fin, donc `await` bloquerait ici pour toujours et la suite (le cycle
    //    d'annonces) ne s'exécuterait jamais. `unawaited(...)` dit
    //    explicitement « démarre la lecture mais ne m'attends pas ».
    unawaited(_sirenPlayer.play());

    // 5) On lance la boucle d'annonces en arrière-plan (sans l'attendre non
    //    plus, sinon start() ne rendrait jamais la main).
    unawaited(_runCycle());
  }

  /// Boucle qui joue une annonce, attend, en rejoue une, etc.
  /// Tourne tant que l'exercice est actif (ni en sourdine, ni fermé).
  Future<void> _runCycle() async {
    // Délai avant la toute première annonce.
    await _interruptibleDelay(_firstAnnounce);

    while (!_disposed && !_muted) {
      await _announce(); // joue une annonce (sirène baissée + voix)
      if (_disposed || _muted) break;

      // Attente jusqu'à la prochaine annonce. On veut une annonce toutes les
      // 30 s « du début d'une annonce au début de la suivante » : on retranche
      // donc la durée de l'annonce déjà jouée.
      final gap = _announcePeriod - _evacDuration;
      await _interruptibleDelay(gap > Duration.zero ? gap : _announcePeriod);
    }
  }

  /// Joue une annonce d'évacuation : baisse la sirène à 20 %, dit le message,
  /// puis remonte la sirène à 100 %.
  Future<void> _announce() async {
    if (_disposed || _muted) return;

    // Baisse la sirène pour qu'on entende la voix par-dessus.
    await _sirenPlayer.setVolume(_duckedVolume);

    // Recharge le fichier d'annonce AVANT de le jouer. C'est important :
    // relancer une lecture déjà terminée avec un simple `seek(0)` n'est pas
    // fiable avec just_audio ; recharger l'asset à chaque fois, si.
    final d = await _voicePlayer.setAsset(_voiceEvacuation) ?? _evacDuration;
    await _voicePlayer.setVolume(_fullVolume);
    unawaited(_voicePlayer.play()); // on ne bloque pas (cf. explication start)

    // On attend nous-mêmes la durée de l'annonce (+ une petite marge), car le
    // Future de play() n'est pas fiable pour ça.
    await _interruptibleDelay(d + const Duration(milliseconds: 300));
    if (_disposed || _muted) return;

    // Annonce finie : la sirène reprend son plein volume.
    await _sirenPlayer.setVolume(_fullVolume);
  }

  /// Attente « coupable » : comme un délai normal, mais qui s'arrête
  /// immédiatement si l'exercice est mis en sourdine ou si l'écran se ferme
  /// (au lieu d'attendre bêtement la fin du délai).
  Future<void> _interruptibleDelay(Duration total) async {
    const step = Duration(milliseconds: 200); // on vérifie l'état tous les 200 ms
    var elapsed = Duration.zero;
    while (elapsed < total && !_disposed && !_muted) {
      await Future<void>.delayed(step);
      elapsed += step;
    }
  }

  /// Bouton « Mettre en sourdine » : la sirène passe à 50 % et on arrête les
  /// annonces (en mettant `_muted` à vrai, la boucle `_runCycle` s'arrête).
  Future<void> mute() async {
    _muted = true;
    await _voicePlayer.stop(); // coupe une annonce éventuellement en cours
    if (!_disposed) await _sirenPlayer.setVolume(_mutedVolume);
  }

  /// Bouton « Exercice terminé » : joue « Exercice terminé. Merci » pendant que
  /// la sirène descend en fondu de 20 % à 0, puis attend la fin du message.
  Future<void> playDoneAndStop() async {
    _muted = true; // stoppe la boucle d'annonces
    await _voicePlayer.stop();
    if (_disposed) return;

    // Lance le message de fin (sans attendre, cf. explication dans start()).
    final duration =
        await _voicePlayer.setAsset(_voiceDone) ?? const Duration(seconds: 3);
    await _voicePlayer.setVolume(_fullVolume);
    unawaited(_voicePlayer.play());

    // Pendant que le message parle, la sirène s'éteint en douceur.
    await _sirenPlayer.setVolume(_duckedVolume);
    await _fadeSirenToZero(const Duration(milliseconds: 1500));
    await _sirenPlayer.stop();

    // On laisse le message se terminer avant de rendre la main.
    await _waitWhileMounted(duration + const Duration(milliseconds: 300));
  }

  /// Baisse progressivement le volume de la sirène jusqu'à 0 (fondu sortant),
  /// en plusieurs petits paliers pour que ce soit fluide.
  Future<void> _fadeSirenToZero(Duration over) async {
    const steps = 15; // nombre de paliers
    final stepDuration = over ~/ steps; // `~/` = division entière
    for (var i = 1; i <= steps; i++) {
      if (_disposed) return;
      // À chaque palier le volume diminue : 20 % * (1 - i/15) → 0.
      await _sirenPlayer.setVolume(_duckedVolume * (1 - i / steps));
      await Future<void>.delayed(stepDuration);
    }
  }

  /// Attente simple utilisée pour le message de fin. Contrairement à
  /// `_interruptibleDelay`, elle NE s'interrompt PAS sur la sourdine (qui est
  /// justement activée ici), seulement si l'écran se ferme.
  Future<void> _waitWhileMounted(Duration total) async {
    const step = Duration(milliseconds: 200);
    var elapsed = Duration.zero;
    while (elapsed < total && !_disposed) {
      await Future<void>.delayed(step);
      elapsed += step;
    }
  }

  /// Libère les ressources audio. Appelé quand l'écran d'exercice se ferme.
  /// Met `_disposed` à vrai (ce qui arrête toutes les boucles en cours).
  Future<void> dispose() async {
    _disposed = true;
    await _sirenPlayer.dispose();
    await _voicePlayer.dispose();
  }
}
