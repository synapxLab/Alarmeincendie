import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app/app_lifecycle.dart';
import '../../core/settings/alarm_config.dart';
import '../../core/settings/config_provider.dart';
import '../../core/update/update_provider.dart';
import '../about/about_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Mise à jour masquée pour l'instant : auto-check désactivé.
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   ref.read(updateProvider.notifier).autoCheckIfDue();
    // });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(configProvider);
    final notifier = ref.read(configProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert incendie'),
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            tooltip: '',
            onSelected: (value) {
              if (value == 'about') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'about', child: Text('À propos')),
            ],
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (cfg) => _Body(cfg: cfg, notifier: notifier),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.cfg, required this.notifier});

  final AlarmConfig cfg;
  final ConfigNotifier notifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: SwitchListTile(
            title: const Text('Entraînement actif',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(cfg.enabled
                ? 'L\'alarme se déclenchera de façon imprévue.'
                : 'Aucune alarme programmée.'),
            value: cfg.enabled,
            activeThumbColor: const Color(0xFFD32F2F),
            onChanged: (v) => notifier.setEnabled(v),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Plage horaire autorisée',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text(
                  'L\'alarme ne sonnera qu\'à l\'intérieur de cette plage.',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _TimeField(
                        label: 'Début',
                        time: cfg.start,
                        onPick: (t) => notifier.setWindow(start: t),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('→'),
                    ),
                    Expanded(
                      child: _TimeField(
                        label: 'Fin',
                        time: cfg.end,
                        onPick: (t) => notifier.setWindow(end: t),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Fréquence des exercices',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${cfg.frequencyPerYear} fois par an',
                    style: const TextStyle(color: Colors.black54)),
                Slider(
                  value: cfg.frequencyPerYear.toDouble(),
                  min: 1,
                  max: 4,
                  divisions: 3,
                  label: '${cfg.frequencyPerYear}×/an',
                  activeColor: const Color(0xFFD32F2F),
                  onChanged: (v) => notifier.setFrequency(v.round()),
                ),
              ],
            ),
          ),
        ),
        // Bloc « Prochain exercice prévu » masqué volontairement :
        // l'horaire doit rester une surprise.
        const SizedBox(height: 8),
        _TestButton(notifier: notifier),
        const SizedBox(height: 12),
        // Fermer : si l'entraînement est actif, on bascule en arrière-plan
        // (l'alarme reste programmée) ; sinon on ferme complètement l'app.
        OutlinedButton.icon(
          onPressed: () async {
            if (cfg.enabled) {
              await AppLifecycle.moveToBackground();
            } else {
              await AppLifecycle.closeCompletely();
            }
          },
          icon: const Icon(Icons.power_settings_new),
          label: Text(
            cfg.enabled
                ? 'Fermer (alarme maintenue en arrière-plan)'
                : "Fermer l'application",
          ),
        ),
        // Bloc « Mise à jour » masqué pour l'instant.
        // const Divider(height: 32),
        // _UpdateSection(cfg: cfg),
      ],
    );
  }

  // ignore: unused_element
  static String _formatDate(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)}/${dt.year} à ${_formatTime(dt)}';
  }

  static String _formatTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.hour)}h${two(dt.minute)}';
  }
}

/// Bouton de test : fond rouge, texte blanc, avec compte à rebours
/// des secondes avant le déclenchement de la sonnerie.
class _TestButton extends StatefulWidget {
  const _TestButton({required this.notifier});

  final ConfigNotifier notifier;

  @override
  State<_TestButton> createState() => _TestButtonState();
}

class _TestButtonState extends State<_TestButton> {
  static const _countdownSeconds = 10;

  Timer? _timer;
  int _remaining = 0;

  bool get _running => _remaining > 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    if (_running) return;
    await widget.notifier.triggerTest();
    if (!mounted) return;
    setState(() => _remaining = _countdownSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _remaining--;
        if (_remaining <= 0) {
          _remaining = 0;
          t.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _running ? null : _start,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFFD32F2F),
        disabledForegroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
      ),
      icon: const Icon(Icons.notifications_active),
      label: Text(
        _running
            ? 'Sonnerie dans ${_remaining}s…'
            : 'Test sonnerie (10 s)',
      ),
    );
  }
}

// ignore: unused_element
class _UpdateSection extends ConsumerWidget {
  const _UpdateSection({required this.cfg});

  final AlarmConfig cfg;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final update = ref.watch(updateProvider);
    final result = update.result;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mises à jour',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: cfg.updateCheckHours,
              decoration: const InputDecoration(
                labelText: 'Vérifier',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                for (final f in UpdateCheckFrequency.values)
                  DropdownMenuItem(value: f.hours, child: Text(f.label)),
              ],
              onChanged: (v) {
                if (v != null) {
                  ref.read(configProvider.notifier).setUpdateFrequency(v);
                }
              },
            ),
            const SizedBox(height: 12),
            if (update.checking)
              const Row(
                children: [
                  SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 12),
                  Text('Vérification en cours…'),
                ],
              )
            else if (result != null && result.available)
              _UpdateAvailable(result: result, installing: update.installing)
            else if (result != null && result.error != null)
              Text('Indisponible : ${result.error}',
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12))
            else if (result != null)
              const Text('Application à jour.',
                  style: TextStyle(color: Colors.green)),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: update.checking
                    ? null
                    : () => ref.read(updateProvider.notifier).checkNow(),
                icon: const Icon(Icons.system_update),
                label: const Text('Vérifier maintenant'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpdateAvailable extends ConsumerWidget {
  const _UpdateAvailable({required this.result, required this.installing});

  final dynamic result; // UpdateResult
  final bool installing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = result.availableVersionCode;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            code != null
                ? 'Nouvelle version disponible (build $code)'
                : 'Nouvelle version disponible',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: installing
                ? null
                : () => ref.read(updateProvider.notifier).startUpdate(),
            icon: installing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.download),
            label: Text(installing ? 'Installation…' : 'Mettre à jour'),
          ),
        ],
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.time,
    required this.onPick,
  });

  final String label;
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onPick;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) onPick(picked);
      },
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(time.format(context),
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
