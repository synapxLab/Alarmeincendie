import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_update/in_app_update.dart';

import '../settings/config_provider.dart';
import 'update_service.dart';

final updateServiceProvider = Provider<UpdateService>((ref) => UpdateService());

class UpdateState {
  const UpdateState({
    this.checking = false,
    this.installing = false,
    this.result,
  });

  final bool checking;
  final bool installing;
  final UpdateResult? result;

  UpdateState copyWith({
    bool? checking,
    bool? installing,
    UpdateResult? result,
  }) {
    return UpdateState(
      checking: checking ?? this.checking,
      installing: installing ?? this.installing,
      result: result ?? this.result,
    );
  }
}

/// État de la dernière vérification de mise à jour.
final updateProvider =
    NotifierProvider<UpdateNotifier, UpdateState>(UpdateNotifier.new);

class UpdateNotifier extends Notifier<UpdateState> {
  @override
  UpdateState build() => const UpdateState();

  /// Vérifie maintenant et met à jour l'horodatage du dernier contrôle.
  Future<UpdateResult> checkNow() async {
    state = state.copyWith(checking: true);
    final result = await ref.read(updateServiceProvider).check();
    state = UpdateState(result: result);
    await ref.read(configProvider.notifier).markUpdateChecked();
    return result;
  }

  /// Vérifie uniquement si l'intervalle configuré est écoulé.
  Future<void> autoCheckIfDue() async {
    final cfg = ref.read(configProvider).value;
    if (cfg == null) return;
    if (cfg.isUpdateCheckDue(DateTime.now())) {
      await checkNow();
    }
  }

  /// Télécharge puis installe la mise à jour (flux flexible Play).
  Future<void> startUpdate() async {
    final service = ref.read(updateServiceProvider);
    state = state.copyWith(installing: true);
    try {
      final res = await service.startFlexible();
      if (res == AppUpdateResult.success) {
        await service.complete(); // redémarre l'app sur la nouvelle version
      }
    } finally {
      state = state.copyWith(installing: false);
    }
  }
}
