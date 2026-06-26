# Publication sur Google Play — Alert incendie

Tout ce qu'il faut pour téléverser l'app sans refus technique.
Identifiant de l'app : `fr.alertfindumonde.alertfindumonde`

---

## État du socle (déjà préparé dans le projet)

| Élément | État |
|---|---|
| `applicationId` / `namespace` | ✅ `fr.alertfindumonde.alertfindumonde` |
| Config de signature release (sans secret versionné) | ✅ `android/app/build.gradle.kts` lit `android/key.properties` |
| R8 / minify / shrinkResources | ✅ activés en release + `proguard-rules.pro` |
| Build release testée | ✅ `flutter build apk --release` OK |
| `.gitignore` (keystore, key.properties) | ✅ secrets exclus |
| Politique de confidentialité | ✅ rédigée (`privacy-policy.md`) — **à héberger** |
| Déclaration Data Safety | ✅ rédigée (`data-safety.md`) |
| Icône application | ✅ flamme (mipmaps en place) |

**Reste à faire manuellement** : créer le keystore, héberger la politique de
confidentialité, produire la bannière + captures, remplir la fiche Play.

---

## 1. Créer le keystore (clé de signature) — une seule fois

```bash
keytool -genkey -v \
  -keystore ~/keys/alertfindumonde-upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

- Réponds aux questions (nom, organisation…), choisis un **mot de passe solide**.
- **Sauvegarde ce fichier `.jks` et le mot de passe en lieu sûr** : sans lui, tu
  ne pourras plus publier de mise à jour.

Puis crée `android/key.properties` (copie de `key.properties.example`) :

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=/home/synapxlab/keys/alertfindumonde-upload.jks
```

> `key.properties` et `*.jks` sont déjà exclus du dépôt par `.gitignore`.

## 2. Play App Signing (recommandé par Google)

À l'inscription de l'app dans la Play Console, **active « Play App Signing »** :
Google gère la clé finale de distribution ; ta clé `.jks` devient la **clé
d'upload**. Si tu la perds, Google peut la réinitialiser — d'où l'intérêt.

## 3. Numéro de version

Géré dans `pubspec.yaml` (Flutter le propage à Android) :

```yaml
version: 1.0.0+1   # 1.0.0 = versionName (visible) · +1 = versionCode (entier ↑)
```

À **chaque envoi** sur Play, incrémenter le nombre après `+` (1.0.0+2, +3…).

## 4. Produire le bundle à téléverser (AAB)

```bash
flutter build appbundle --release
# → build/app/outputs/bundle/release/app-release.aab
```

C'est ce `.aab` qu'on dépose sur la Play Console (plus léger qu'un APK : Google
génère un APK adapté à chaque appareil).

## 5. Fiche Play Store — éléments à fournir

| Élément | Format | État |
|---|---|---|
| Icône | 512×512 PNG | ⚠️ à exporter (on a la flamme en mipmap) |
| Bannière (feature graphic) | 1024×500 PNG | ❌ à créer |
| Captures d'écran téléphone | min. 2, PNG/JPG | ❌ à faire (accueil + écran d'alarme) |
| Captures tablette (optionnel) | — | ❌ |
| Description courte / longue | texte | ❌ à rédiger |
| Politique de confidentialité | **URL publique** | ⚠️ héberger `privacy-policy.md` |
| Catégorie | « Outils » ou « Maison » | à choisir |
| Coordonnées | e-mail | ✅ |

## 6. Questionnaires Play Console

- **Sécurité des données** : suivre `data-safety.md` (→ « aucune donnée collectée »).
- **Classification du contenu** : remplir le questionnaire (app utilitaire, tout public).
- **Annonces** : l'app ne contient pas de publicité.
- **Public cible** : choisir les tranches d'âge.

---

## Checklist finale avant envoi

- [ ] Keystore créé + sauvegardé + `key.properties` rempli
- [ ] `version:` incrémentée dans `pubspec.yaml`
- [ ] `flutter build appbundle --release` produit le `.aab`
- [ ] Politique de confidentialité en ligne (URL)
- [ ] Icône 512, bannière 1024×500, captures prêtes
- [ ] Data Safety + classification du contenu remplis
- [ ] Play App Signing activé
- [ ] `.aab` téléversé sur une piste (interne d'abord, puis production)

---

## Risques / points de vigilance

- **Taille** : l'APK universel fait ~62 Mo (assets audio WAV). L'AAB réduit la
  taille livrée par appareil ; on peut aussi alléger en convertissant la sirène
  WAV en plus léger si besoin.
- **targetSdk** : doit respecter le minimum Google en vigueur (Android 14/15
  selon la date). Flutter 3.41 cible une version récente — vérifier au moment de
  publier.
- **Perte du keystore** = impossible de mettre à jour l'app : sauvegarde
  impérative (Play App Signing limite ce risque).
- **Permissions sensibles** (`SCHEDULE_EXACT_ALARM`, `USE_FULL_SCREEN_INTENT`) :
  justifiées par la nature « alarme » de l'app ; Google peut demander une
  explication dans la fiche — préparer une phrase type « application d'alarme
  d'entraînement à l'évacuation ».
