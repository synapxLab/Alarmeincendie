# Alert incendie

Application Flutter d'entraînement à l'évacuation incendie. Elle déclenche une
alarme **imprévue**, quelques fois par an, à l'intérieur d'une plage horaire
définie, afin de s'entraîner à réagir à une alerte sans en connaître la date ni
l'heure à l'avance.

## Stack technique

- **Flutter / Dart**
- **Riverpod** — gestion d'état
- **alarm** — planification des alarmes et lecture audio en arrière-plan

## Architecture

```
lib/
  core/       services (alarm, settings, update)
  features/   écrans (home, ring, about)
  main.dart   point d'entrée
```

## Build

```
flutter pub get
flutter run -d <device>
```

Pour générer l'APK de production :

```
flutter build apk --release
```

## Contact

Centre de secours de Saint-Priest (SDMIS) :

- **Courriel** : ct.saintpriest@sdmis.fr
- **Téléphone** : 04 78 78 55 02

## Licence

Distribué sous licence **Apache 2.0**. Voir le fichier [LICENSE](LICENSE).

Copyright © 2026 **synapxLab** / **Adliss**.
