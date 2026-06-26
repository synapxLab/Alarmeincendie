# Alert incendie — audit de positionnement & pistes de fonctionnalités

> Document de travail (préparation de l'échange avec le SDMIS).
> Comparaison avec les solutions existantes, puis idées de fonctionnalités
> classées par effort / valeur.

---

## 1. Ce que fait l'app aujourd'hui

- Déclenche une **alarme imprévue** (1–4×/an) dans une **plage horaire** choisie.
- Sirène + **annonce vocale** d'évacuation, répétée toutes les 30 s.
- **Chronomètre d'évacuation** (temps de sortie).
- Bouton **sourdine** (50 %) et **fin d'exercice** (message « Exercice terminé »).
- Fonctionne **en arrière-plan**, gratuit, **sans compte, sans pub, sans tracking**.

**Positionnement :** un outil d'**entraînement** au réflexe d'évacuation, là où
le marché se concentre sur la **détection** (matériel) ou la **conformité
documentaire** (logiciels pro). Cet angle « répétition du geste » est peu couvert.

---

## 2. Comparaison avec l'existant

| Solution | Cible | Ce qu'elle fait | Limite | Alert incendie apporte… |
|---|---|---|---|---|
| **DAAF** (détecteur de fumée autonome) | Tous logements (obligatoire FR) | Détecte la fumée, sonne | N'**entraîne** personne, ne mesure rien | L'entraînement régulier au réflexe |
| **SSI** (système sécurité incendie) | ERP / bâtiments | Détection + alarme générale câblée | Coût élevé, installation, pas d'exercice ludique | Une couche logicielle légère et gratuite |
| **Logiciels de registre** (type BatiRegistre…) | ERP, syndics | Suivi conformité, planning des exercices | Payant, paperasse, ne **déclenche** pas l'exercice | Le déclenchement + la mesure terrain |
| **PPMS** (écoles) | Établissements scolaires | Procédures de mise en sûreté | Cadre administratif, pas d'app grand public | Un déclencheur concret + traçabilité |
| **Apps réveil/alarme** | Grand public | Sonnent à heure fixe | Aucune logique d'évacuation ni de surprise | Scénario incendie + imprévu + chrono |
| **Apps « fire drill » étrangères** | Niche | Simulent une alarme | Rares, souvent payantes, peu localisées FR | Voix FR, gratuit, local, sobre |

**Angle mort du marché :** personne ne propose un outil **simple et gratuit**
qui *fait répéter* l'évacuation à des particuliers / petites structures, avec
**effet de surprise** et **mesure du temps de sortie**.

---

> ⚠️ **Ne pas se positionner sur le « bouton d'alerte ».** Ce marché est déjà
> saturé : PTI/DATI (protection travailleur isolé), apps SOS grand public,
> déclencheurs manuels type « bris de glace ». Le bouton d'alerte n'est **pas**
> un différenciateur. Le cap à garder = **l'entraînement par surprise** (faire
> *répéter* le réflexe d'évacuation), angle quasi inoccupé. Les briques d'alerte
> (SOS, messagerie, mesh) restent des **moyens au service de l'évacuation**, pas
> le produit.

## 3. Différenciateurs à garder (ne pas diluer)

- **Surprise** : l'imprévu est le cœur pédagogique — à préserver.
- **Zéro friction** : pas de compte, pas de cloud obligatoire.
- **Souveraineté / vie privée** : tout en local, pas de tracking.
- **Sobriété** : une action = un écran clair, utilisable en stress.

---

## 4. Fonctionnalités possibles

### 🟢 Rapides & à forte valeur (court terme)

- **Historique des exercices** : date, heure, **temps d'évacuation**, sourdine
  utilisée. Base de tout le reste.
- **Export PDF du registre** d'exercices (utile/obligatoire côté ERP).
- **Plusieurs scénarios** : incendie, fumée, **confinement** (PPMS), intrusion —
  chacun avec sa voix et sa consigne.
- **Messages vocaux personnalisables** (texte → voix, déjà maîtrisé) et
  **multilingue** (FR/EN/…).
- **Consignes post-déclenchement** à l'écran : « fermez les portes », « point de
  rassemblement », « ne revenez pas ».
- **Accessibilité** : flash écran + vibration forte pour malentendants.

### 🟡 Moyen terme (différenciation forte)

- **Point de rassemblement** : carte / photo + checklist de présence.
- **Appel nominatif / comptage** : qui est sorti, qui manque.
- **Progression** : courbe du temps d'évacuation dans le temps (gamification douce).
- **Mode responsable** : déclenchement **manuel** d'un exercice à la demande.
- **Plan d'évacuation intégré** : photos/schéma des issues du logement/local.
- **Quiz / mini-tutoriel** de prévention (extincteur, fumée, portes).

### 🔵 Ambitieux (vision « multi-appareils »)

- **Déclenchement par Bluetooth (BLE mesh) — sans réseau.** Un appareil émet une
  balise « alarme », les voisins sonnent et **ré-émettent** de proche en proche
  (« escalade », principe BLE du contact tracing COVID, mais en Bluetooth
  classique). **Atout majeur : fonctionne même si le Wi-Fi/4G tombe** (cas
  incendie). Canal de déclenchement **principal** en mode « Bâtiment ».
- **Déclenchement simultané via push (FCM) — canal de secours** pour joindre les
  appareils hors de portée Bluetooth quand du réseau est disponible.
- Une seule app, **2 modes** : « Solo » (particulier, actuel) et « Bâtiment »
  (ERP/école/EHPAD, multi-appareils BLE + FCM).
- **Groupes « bâtiment »** rejoignables par **QR code**.
- **Tableau de bord** d'un site (qui a évacué, temps moyen, dernier exercice).
- **Intégration détecteurs connectés** (DAAF connectés, Nest Protect) : un vrai
  départ de fumée bascule en mode réel.
- **Distinction Exercice / Réel** très visible (couleur, message).

### ⚙️ Confort / réglages

- Choix de la **sirène** et du **volume cible**.
- **Réveil progressif** (montée du volume) en mode nuit.
- **Délais paramétrables** (temps sirène seule, période des annonces).
- **Notification à un proche / responsable** en fin d'exercice.

---

## 5. Pistes selon le public visé

- **Particuliers / familles** : surprise, chrono, progression, consignes simples.
- **Assistantes maternelles / petites crèches** : registre PDF, appel nominatif.
- **Petits ERP / commerces** : registre conforme, déclenchement manuel, multi-appareils.
- **Écoles** : scénarios PPMS, comptage, traçabilité.
- **EHPAD / personnes vulnérables** : accessibilité, réveil progressif, alerte proche.

---

## 6. Questions à poser au SDMIS (pour cadrer la suite)

- Le **temps d'évacuation** mesuré a-t-il une valeur pédagogique exploitable ?
- Quels **scénarios** sont prioritaires (incendie vs confinement) ?
- Quelles **consignes** afficher pour ne pas induire de mauvais réflexes ?
- Un **registre PDF** serait-il réellement utile aux structures qu'ils suivent ?
- Un **déclenchement sans réseau** (propagation Bluetooth de proche en proche,
  alarme simultanée dans tout un bâtiment) répond-il à un vrai besoin terrain ?
- Risques à éviter (banalisation de l'alarme, confusion exercice/réel) ?

---

*Ce document est une base de discussion : les priorités seront affinées selon
les retours du terrain.*
