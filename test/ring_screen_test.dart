import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alertfindumonde/features/ring/ring_screen.dart';

void main() {
  testWidgets('RingScreen affiche le chrono et les deux boutons', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: RingScreen()),
      ),
    );

    // Chrono démarré à 00:00.
    expect(find.text('00:00'), findsOneWidget);
    expect(find.text('temps écoulé'), findsOneWidget);

    // Les deux actions, dans l'ordre.
    expect(find.text('Mettre en sourdine'), findsOneWidget);
    expect(find.text('Exercice terminé'), findsOneWidget);

    // Démonte pour annuler le Timer périodique.
    await tester.pumpWidget(const SizedBox());
  });
}
