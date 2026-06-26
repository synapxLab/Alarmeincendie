import 'package:in_app_update/in_app_update.dart';

/// Résultat d'une vérification de mise à jour via Google Play.
class UpdateResult {
  const UpdateResult({
    required this.available,
    this.availableVersionCode,
    this.flexibleAllowed = false,
    this.error,
  });

  final bool available;
  final int? availableVersionCode;
  final bool flexibleAllowed;
  final String? error;
}

/// Vérifie et applique les mises à jour via l'API officielle Google Play
/// (In-App Updates). Ne fonctionne que pour une app installée depuis le
/// Play Store (ou une piste de test interne) : en debug/sideload, l'appel
/// échoue, ce qui est attendu.
class UpdateService {
  Future<UpdateResult> check() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      return UpdateResult(
        available:
            info.updateAvailability == UpdateAvailability.updateAvailable,
        availableVersionCode: info.availableVersionCode,
        flexibleAllowed: info.flexibleUpdateAllowed,
      );
    } catch (e) {
      return UpdateResult(available: false, error: '$e');
    }
  }

  /// Lance le téléchargement de la mise à jour en arrière-plan (flux flexible).
  Future<AppUpdateResult> startFlexible() => InAppUpdate.startFlexibleUpdate();

  /// Installe la mise à jour déjà téléchargée (redémarre l'app).
  Future<void> complete() => InAppUpdate.completeFlexibleUpdate();
}
