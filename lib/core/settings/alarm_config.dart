import 'package:flutter/material.dart';

/// Fréquence de vérification des mises à jour (valeur = intervalle en heures).
enum UpdateCheckFrequency {
  onLaunch('À chaque ouverture', 0),
  daily('Quotidienne', 24),
  weekly('Hebdomadaire', 168),
  manual('Manuelle', -1);

  const UpdateCheckFrequency(this.label, this.hours);

  final String label;
  final int hours;

  static UpdateCheckFrequency fromHours(int hours) =>
      UpdateCheckFrequency.values.firstWhere(
        (f) => f.hours == hours,
        orElse: () => UpdateCheckFrequency.daily,
      );
}

/// Configuration d'entraînement à l'alarme incendie.
///
/// L'alarme sonne [frequencyPerYear] fois par an, à un moment aléatoire situé
/// dans la plage horaire de nuit [start]..[end] (qui peut traverser minuit).
@immutable
class AlarmConfig {
  const AlarmConfig({
    this.enabled = false,
    this.start = const TimeOfDay(hour: 22, minute: 0),
    this.end = const TimeOfDay(hour: 6, minute: 0),
    this.frequencyPerYear = 2,
    this.nextRing,
    this.updateCheckHours = 24,
    this.lastUpdateCheck,
  });

  /// Entraînement actif ou non.
  final bool enabled;

  /// Début de la plage horaire autorisée.
  final TimeOfDay start;

  /// Fin de la plage horaire autorisée.
  final TimeOfDay end;

  /// Nombre de déclenchements par an (1 à 4).
  final int frequencyPerYear;

  /// Prochaine sonnerie programmée (null si inactif).
  final DateTime? nextRing;

  /// Intervalle de vérification des mises à jour, en heures (voir
  /// [UpdateCheckFrequency]).
  final int updateCheckHours;

  /// Dernière vérification de mise à jour effectuée.
  final DateTime? lastUpdateCheck;

  UpdateCheckFrequency get updateFrequency =>
      UpdateCheckFrequency.fromHours(updateCheckHours);

  AlarmConfig copyWith({
    bool? enabled,
    TimeOfDay? start,
    TimeOfDay? end,
    int? frequencyPerYear,
    DateTime? nextRing,
    bool clearNextRing = false,
    int? updateCheckHours,
    DateTime? lastUpdateCheck,
  }) {
    return AlarmConfig(
      enabled: enabled ?? this.enabled,
      start: start ?? this.start,
      end: end ?? this.end,
      frequencyPerYear: frequencyPerYear ?? this.frequencyPerYear,
      nextRing: clearNextRing ? null : (nextRing ?? this.nextRing),
      updateCheckHours: updateCheckHours ?? this.updateCheckHours,
      lastUpdateCheck: lastUpdateCheck ?? this.lastUpdateCheck,
    );
  }

  /// Durée de la plage horaire en minutes (gère le passage par minuit).
  int get windowMinutes {
    final startM = start.hour * 60 + start.minute;
    final endM = end.hour * 60 + end.minute;
    final diff = endM - startM;
    return diff > 0 ? diff : diff + 24 * 60;
  }

  /// Indique si une vérification de mise à jour est due.
  bool isUpdateCheckDue(DateTime now) {
    if (updateCheckHours < 0) return false; // mode manuel
    if (updateCheckHours == 0) return true; // à chaque ouverture
    final last = lastUpdateCheck;
    if (last == null) return true;
    return now.difference(last).inHours >= updateCheckHours;
  }

  Map<String, Object?> toJson() => {
        'enabled': enabled,
        'startHour': start.hour,
        'startMinute': start.minute,
        'endHour': end.hour,
        'endMinute': end.minute,
        'frequencyPerYear': frequencyPerYear,
        'nextRing': nextRing?.toIso8601String(),
        'updateCheckHours': updateCheckHours,
        'lastUpdateCheck': lastUpdateCheck?.toIso8601String(),
      };

  factory AlarmConfig.fromJson(Map<String, Object?> json) {
    DateTime? parse(Object? v) =>
        v is String ? DateTime.tryParse(v) : null;
    return AlarmConfig(
      enabled: json['enabled'] as bool? ?? false,
      start: TimeOfDay(
        hour: json['startHour'] as int? ?? 22,
        minute: json['startMinute'] as int? ?? 0,
      ),
      end: TimeOfDay(
        hour: json['endHour'] as int? ?? 6,
        minute: json['endMinute'] as int? ?? 0,
      ),
      frequencyPerYear: json['frequencyPerYear'] as int? ?? 2,
      nextRing: parse(json['nextRing']),
      updateCheckHours: json['updateCheckHours'] as int? ?? 24,
      lastUpdateCheck: parse(json['lastUpdateCheck']),
    );
  }
}
