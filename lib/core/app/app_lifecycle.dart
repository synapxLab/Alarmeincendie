import 'package:flutter/services.dart';

/// Pont vers le code natif Android pour gérer la fermeture de l'app.
class AppLifecycle {
  AppLifecycle._();

  static const _channel = MethodChannel('fr.alertfindumonde/lifecycle');

  /// Renvoie l'app en arrière-plan : le service d'alarme continue de
  /// tourner, mais l'app disparaît de l'écran.
  static Future<void> moveToBackground() =>
      _channel.invokeMethod('moveToBackground');

  /// Ferme complètement l'app et la retire des tâches récentes.
  static Future<void> closeCompletely() =>
      _channel.invokeMethod('closeCompletely');
}
