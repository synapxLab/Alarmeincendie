import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alertfindumonde/core/settings/alarm_config.dart';

void main() {
  test('windowMinutes gère le passage par minuit (22h → 6h = 480 min)', () {
    const cfg = AlarmConfig(
      start: TimeOfDay(hour: 22, minute: 0),
      end: TimeOfDay(hour: 6, minute: 0),
    );
    expect(cfg.windowMinutes, 8 * 60);
  });

  test('windowMinutes pour une plage en journée (9h → 17h = 480 min)', () {
    const cfg = AlarmConfig(
      start: TimeOfDay(hour: 9, minute: 0),
      end: TimeOfDay(hour: 17, minute: 0),
    );
    expect(cfg.windowMinutes, 8 * 60);
  });
}
