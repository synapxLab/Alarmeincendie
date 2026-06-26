# Alert incendie — roadmap priorisée

> Ordre de construction conseillé. Priorisation = **valeur / effort** + dépendances.
> Effort indicatif : **S** (≤ 1 j) · **M** (quelques jours) · **L** (semaine+).

---

## Principe de priorisation

1. **Finir et fiabiliser** l'existant avant d'ajouter.
2. **La traçabilité d'abord** (historique) : c'est le socle qui débloque le PDF,
   la progression, le cas ERP… beaucoup de features en dépendent.
3. **Valeur pédagogique** ensuite (scénarios, consignes, accessibilité).
4. **Le multi-appareils en dernier** : fort impact mais gros chantier (serveur).

---

## Phase 0 — Finitions (maintenant)  · effort S

Boucler ce qui est presque prêt avant d'élargir.

- [ ] Valider à l'oreille l'audio (sirène / annonce 30 s / sourdine / fin).
- [ ] Régler les constantes (délai 6 s, période 30 s, 20 %/50 %) selon ressenti.
- [ ] Réactiver le bloc « Mise à jour » quand prêt, ou le retirer proprement.
- [ ] Signature **release** (keystore) → pouvoir produire un APK/AAB distribuable.

**Jalon :** version stable installable, son validé.

---

## Phase 1 — Traçabilité (socle)  · effort M

Le pivot : sans historique, pas de PDF ni de progression.

- [ ] **Historique des exercices** (date, heure, temps d'évacuation, sourdine).
      Stockage local (`shared_preferences` ou petite base).
- [ ] Écran **« Historique »** (liste + détail).
- [ ] **Export PDF** du registre d'exercices.
- [ ] **Courbe de progression** du temps d'évacuation.

**Jalon :** « je peux montrer la preuve et le progrès des exercices ».
**Débloque :** cas d'usage ERP / crèches / écoles.

---

## Phase 2 — Valeur pédagogique  · effort M

Rendre l'exercice plus juste et plus inclusif (à cadrer avec le SDMIS).

- [ ] **Scénarios** : incendie / fumée / **confinement (PPMS)** / intrusion,
      chacun avec sa voix et sa consigne.
- [ ] **Consignes post-déclenchement** à l'écran (fermez les portes, point de
      rassemblement, ne revenez pas).
- [ ] **Accessibilité** : flash écran + vibration forte (malentendants).
- [ ] **Messages multilingues** (FR/EN/…), réglages des délais exposés à l'UI.

**Jalon :** outil crédible côté prévention, adaptable au public.

---

## Phase 3 — Multi-appareils (le gros levier)  · effort L

Passer de « 1 appareil » à « tout un bâtiment ». **Deux canaux complémentaires** :
le Bluetooth (local, sans réseau) en priorité, le push internet en secours.

- [ ] **Mode « Bâtiment »** (en plus du mode « Solo » actuel).
- [ ] **Déclenchement par Bluetooth (BLE mesh) — canal principal.**
      Un appareil émet une balise « ALARME », les voisins (~10-30 m) sonnent et
      **ré-émettent** (escalade de proche en proche), avec id + TTL pour éviter
      les boucles. **Fonctionne sans Wi-Fi ni 4G** (résilient en cas d'incendie).
- [ ] **Push internet (FCM) — canal de secours / longue portée.**
      Serveur PHP minimal (`/trigger`, token) → message data → `Alarm.set`,
      pour joindre les appareils hors de portée Bluetooth quand du réseau existe.
- [ ] **Groupes « bâtiment »** rejoignables par **QR code**.
- [ ] **Mode responsable** : déclenchement **manuel** d'un exercice.
- [ ] Distinction **Exercice / Réel** très visible.

**Jalon :** un responsable déclenche, toutes les tablettes du site sonnent —
même sans réseau (relais Bluetooth).
**Pré-requis :** Phase 1 (suivi par site). **À prototyper tôt :** l'émission BLE
en arrière-plan (support variable selon plugins/constructeurs).

---

## Phase 4 — Intégrations avancées  · effort L

- [ ] **Tableau de bord de site** (qui a évacué, temps moyen, dernier exercice).
- [ ] **Appel nominatif / comptage** des présents.
- [ ] **Plan d'évacuation** intégré (photos/schéma des issues).
- [ ] **Détecteurs connectés** (DAAF connectés, Nest Protect) → bascule mode réel.
- [ ] **Notification à un proche / responsable** en fin d'exercice.

---

## Vue d'ensemble

| Phase | Thème | Effort | Pourquoi cet ordre |
|---|---|---|---|
| 0 | Finitions | S | Base stable avant d'élargir |
| 1 | Traçabilité | M | Socle qui débloque le reste |
| 2 | Pédagogie | M | Crédibilité prévention, inclusif |
| 3 | Multi-appareils | L | Plus gros levier, mais chantier serveur |
| 4 | Intégrations | L | Confort & écosystème |

---

## Prochaine action concrète

➡️ **Terminer la Phase 0** (valider l'audio + signature release), puis attaquer
l'**historique des exercices** (Phase 1) : c'est le meilleur ratio valeur/effort
et ça ouvre le plus de portes.

> À réordonner après l'échange avec le SDMIS : leurs retours peuvent faire
> remonter un scénario (Phase 2) ou le registre PDF (Phase 1) en tête.
