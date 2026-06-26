# Construire et installer « Alert incendie »

Mémo des commandes. À lancer depuis la racine du projet :
`/data/vhosts/@synapxlab/alertfindumonde`

> Brancher la tablette en USB (débogage USB activé) avant toute commande `adb`.

---

## 0. Vérifier que la tablette est détectée

```bash
flutter devices
# ou
adb devices
```

La tablette de test apparaît sous l'identifiant `R52R3078CAJ` (SM P610).

---

## 1. Lancer en mode dev (debug, avec rechargement)

Le plus pratique pendant le développement. Compile, installe et **reste
attaché** : appuyer sur `r` = hot reload, `R` = redémarrage, `q` = quitter.

```bash
flutter run -d R52R3078CAJ
```

---

## 2. Construire un APK debug et l'installer à la main

Quand on veut juste (re)poser l'app sur la tablette sans rester attaché.

```bash
flutter build apk --debug
adb -s R52R3078CAJ install -r build/app/outputs/flutter-apk/app-debug.apk
```

- `-r` = réinstalle par-dessus en gardant les données.
- APK généré : `build/app/outputs/flutter-apk/app-debug.apk`

Pour repartir d'un état vierge (efface réglages + alarmes mémorisées) :

```bash
adb -s R52R3078CAJ uninstall fr.alertfindumonde.alertfindumonde
adb -s R52R3078CAJ install build/app/outputs/flutter-apk/app-debug.apk
```

---

## 3. Construire la version finale (release)

### APK release (installation directe / hors store)

```bash
flutter build apk --release
adb -s R52R3078CAJ install -r build/app/outputs/flutter-apk/app-release.apk
```

### AAB release (pour publier sur Google Play)

```bash
flutter build appbundle --release
# Fichier : build/app/outputs/bundle/release/app-release.aab
```

> La signature de release doit être configurée (clé + `android/key.properties`)
> avant de publier sur le Play Store.

---

## 4. Commandes utiles

```bash
# Nettoyer si un build se comporte bizarrement
flutter clean
flutter pub get

# Vérifier le code (erreurs / avertissements)
flutter analyze

# Lancer l'app déjà installée sans recompiler
adb -s R52R3078CAJ shell monkey -p fr.alertfindumonde.alertfindumonde -c android.intent.category.LAUNCHER 1

# Forcer l'arrêt de l'app
adb -s R52R3078CAJ shell am force-stop fr.alertfindumonde.alertfindumonde

# Capture d'écran de la tablette
adb -s R52R3078CAJ exec-out screencap -p > capture.png
```

---

## Mémo : que choisir ?

| Besoin | Commande |
|---|---|
| Développer / tester vite | `flutter run -d R52R3078CAJ` |
| Poser l'app (debug) | `flutter build apk --debug` puis `adb install -r …app-debug.apk` |
| Version finale à installer | `flutter build apk --release` |
| Publier sur le Play Store | `flutter build appbundle --release` |

> Identifiant de l'application : `fr.alertfindumonde.alertfindumonde`
