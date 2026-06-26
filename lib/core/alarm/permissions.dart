import 'package:permission_handler/permission_handler.dart';

/// Demande les permissions nécessaires au déclenchement fiable de l'alarme.
///
/// Idempotent : ne déclenche aucun dialogue système si les autorisations
/// sont déjà accordées (sinon le bouton « Test » redemanderait à chaque clic).
///
/// Retourne `true` si l'essentiel (notifications) est accordé.
Future<bool> requestAlarmPermissions() async {
  // Notifications : on ne demande que si ce n'est pas déjà accordé.
  if (!await Permission.notification.isGranted) {
    await Permission.notification.request();
  }

  // Android 12+ : alarme exacte. Avec USE_EXACT_ALARM (déclaré au manifest)
  // elle est auto-accordée ; on ne tente la demande (qui ouvre les réglages
  // système) que si elle est réellement refusée.
  if (await Permission.scheduleExactAlarm.isDenied) {
    await Permission.scheduleExactAlarm.request();
  }

  return Permission.notification.isGranted;
}
