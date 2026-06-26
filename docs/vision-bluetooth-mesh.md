# Vision — réseau Bluetooth bidirectionnel : présence & évacuation

> Document d'exploration (à confronter au SDMIS). Va plus loin que le simple
> déclenchement : si les appareils peuvent **se parler** en Bluetooth, on tient
> un **système de comptage et de localisation d'évacuation sans réseau**.
>
> ⚠️ Précision importante d'emblée : en **intérieur, le GPS ne fonctionne pas**.
> Quand on parle de « localiser », il s'agit de **localisation par proximité
> Bluetooth** (quel appareil est près de quelle borne / du point de
> rassemblement), pas de coordonnées GPS.

---

## 1. Le point de départ (tes idées)

- **Communication dans les 2 sens** : le Bluetooth ne sert pas qu'à diffuser
  l'alarme, il permet aussi de **remonter** des infos (accusés, état).
- **Cartographier les appareils** : tenir une **liste exhaustive** des appareils
  présents dans le périmètre.
- **À la fin de l'alerte** : repérer les appareils **encore dans le bâtiment**
  → identifier les **personnes potentiellement non évacuées**.

C'est exactement le problème n°1 d'une évacuation réelle : **« reste-t-il
quelqu'un à l'intérieur ? »**

---

## 2. Comment ça marche (principe, honnête)

### a) Inventaire / cartographie
Chaque appareil émet périodiquement une petite balise (un identifiant + son
état). Tous les appareils s'entendent → on reconstitue **la liste des présents**.

### b) Bornes fixes = points d'ancrage
Quelques **tablettes fixes** (« bornes ») placées à des endroits clés :
- une (ou +) **à l'intérieur** (couloirs, étages) ;
- une **au point de rassemblement** (dehors).

La **puissance du signal reçu (RSSI)** indique de quelle borne un appareil est
proche → on sait, en gros, **« encore au 2ᵉ étage »** vs **« au point de
rassemblement »**. Pas de coordonnées exactes : une **zone**.

### c) Statut d'évacuation par personne
3 états simples, mis à jour en direct :
- 🔴 **dans le bâtiment** (vu par une borne intérieure / jamais vu dehors) ;
- 🟢 **évacué** (vu par la borne du point de rassemblement, ou a appuyé sur
  « Je suis sorti ») ;
- ⚪ **inconnu / hors réseau** (plus de signal — batterie, appareil resté loin…).

### d) Tableau de bord responsable
Sur l'appareil du responsable (mode « Bâtiment ») : **liste en temps réel** —
combien sont sortis, combien manquent, et **où** (quelle zone) les manquants ont
été vus pour la dernière fois.

---

## 3. Ma sauce (extensions proposées)

- **Bouton « Je suis coincé / SOS »** sur l'écran d'alarme : relayé en priorité
  dans le mesh → le responsable voit immédiatement **qui** et **dans quelle
  zone**. Game-changer pour les secours.
- **Dernière position connue** : si un appareil disparaît du réseau, on garde
  **la dernière borne qui l'a vu** + l'heure → piste pour les pompiers à l'arrivée.
- **Fiche de transmission aux secours** : à leur arrivée, un écran « N personnes,
  X sorties, Y manquantes, dernières zones vues » — l'info qu'ils réclament en
  premier.
- **Rôles d'appareils** : *bornes fixes* (ancrage, branchées), *personnels*
  (chacun), *responsable* (tableau de bord). Une seule app, rôle configurable.
- **Comptage au point de rassemblement** : la borne extérieure fait l'**appel
  automatique** — plus de feuille papier.
- **Mode test/exercice** : rejoue tout ça à blanc et **archive le résultat**
  (qui a mis combien de temps, qui a oublié de confirmer) → s'intègre au
  registre PDF (Phase 1).
- **Escalade intelligente** : si une zone ne « répond » plus du tout (toutes ses
  bornes muettes), alerte spéciale « zone injoignable ».
- **Anti-angle-mort** : croiser BLE (présence) + bouton manuel (« sorti ») pour
  ne pas conclure trop vite qu'une personne est dehors juste parce que son
  téléphone n'émet plus.

---

## 4. Limites & points de vigilance (à dire au SDMIS)

- **Tout le monde doit avoir l'app + Bluetooth activé.** Réaliste pour du
  **personnel équipé** (école, EHPAD, entreprise), **pas** pour du public de
  passage. À positionner comme outil pour **occupants permanents**.
- **Précision = zone, pas mètre près.** On situe un étage / une aile, pas une
  pièce exacte (sauf à multiplier les bornes).
- **Fiabilité Bluetooth** variable selon constructeurs ; l'émission en
  arrière-plan est bridée par Android (foreground service requis).
- **Vie privée — sujet sensible.** Suivre la présence des gens = données
  sensibles. Garde-fous proposés :
  - activé **uniquement pendant un exercice / une alerte**, pas en continu ;
  - **aucune donnée ne quitte le site** (tout en local, pas de cloud) ;
  - identifiants **anonymes / rotatifs** (comme le COVID), nominatif seulement
    si la structure le configure explicitement ;
  - information claire des occupants (consentement, règlement intérieur).
- **Ne pas créer de faux sentiment de sécurité** : l'outil **assiste** le
  comptage, il ne remplace pas la levée de doute physique par les secours.

---

## 5. Pourquoi c'est fort pour les pompiers

- Répond à **leur première question** sur intervention : qui est encore dedans, où.
- **Sans réseau** : marche même si le bâtiment perd électricité/Wi-Fi.
- **Coût quasi nul** : pas d'installation lourde, juste des appareils + l'app.
- **Traçabilité** des exercices : preuve d'entraînement + axes d'amélioration.

---

## 6. Variante : une app « relai » légère (pour les occupants)

Idée : à côté de l'app complète (responsables), une **2ᵉ app très simple** que
chacun installe. Elle ne fait que **3 choses**, uniquement **pendant une alarme** :

1. **Relayer** le signal Bluetooth (chaque téléphone devient un nœud du mesh →
   plus il y a d'appareils, mieux l'alarme se propage et plus la cartographie
   est précise) ;
2. **Se localiser** (par proximité BLE en intérieur ; par GPS une fois dehors,
   au point de rassemblement, où le GPS fonctionne) ;
3. **Envoyer un message au chef** (responsable / « chef de compagnie »).

### Pourquoi une app séparée
- **Ultra-légère, zéro config** : on l'installe et on l'oublie → adoption large.
- **Densifie le réseau** : chaque occupant = un relais + un point de mesure.
- **Sépare les rôles** : les responsables ont le tableau de bord complet ; les
  occupants ont juste le strict nécessaire.
- **🔒 L'app relai NE PEUT PAS déclencher d'alarme.** Elle ne fait que recevoir,
  relayer et remonter des messages. Le déclenchement est réservé au responsable
  (voir §7). Cela évite qu'un occupant provoque une panique.

### Ma sauce — la messagerie en situation de stress
- **Messages prédéfinis en un tap** (plus rapide que taper en panique) :
  ✅ « Évacué » · 🆘 « Coincé » · 🩹 « Blessé » · 🔥 « Feu ici » · ❓ « Besoin d'aide ».
- **Texte libre** en option, mais les boutons d'abord.
- **Accusé du chef** : « message reçu » → la personne sait qu'on l'a vue.
- **Sens descendant aussi** : le chef peut pousser une **consigne** affichée sur
  tous les relais (« évacuation par l'escalier B », « confinez-vous »).
- **Réveil sur alarme uniquement** : l'app dort et ne s'active (Bluetooth +
  localisation) qu'à la réception d'un signal d'alarme → économie de batterie et
  respect de la vie privée (pas de suivi permanent).
- **Identité optionnelle** (prénom / salle / poste) pour que le chef sache qui
  écrit — configurable, sinon anonyme.

### Limites spécifiques
- Demande quand même l'app + Bluetooth chez chaque occupant.
- La **localisation** suit les mêmes règles que §4 (zone en intérieur, GPS
  seulement dehors).
- Messagerie = encore plus sensible côté vie privée → **actif seulement pendant
  l'alerte**, jamais en continu.

---

## 7. Sécurité : qui peut déclencher une alarme

Le déclenchement doit être **verrouillé** — une fausse alarme (panique,
plaisanterie, malveillance) serait grave. Deux niveaux de protection :

### a) Côté interface — clé de déverrouillage
Seul un **responsable autorisé** peut déclencher. Le bouton « Déclencher » est
protégé par une **clé de déverrouillage** : code PIN, mot de passe, ou
biométrie. L'app relai (occupants) **n'a tout simplement pas** ce bouton.

### b) Côté protocole — alarme signée (anti-fausse-balise)
Sans protection, n'importe quel appareil pourrait émettre une fausse balise
« ALARME » en Bluetooth et la faire propager par tous les relais. Donc :

- chaque bâtiment a une **clé partagée** (distribuée en rejoignant le groupe,
  ex. via le **QR code** — §3 de la roadmap) ;
- la balise d'alarme est **signée** avec cette clé ;
- les relais **vérifient la signature** avant de sonner / relayer → une alarme
  non signée par une source autorisée est **ignorée**.

### c) Gestion de la clé
- **Révocation / rotation** : si une clé fuite, le responsable la régénère et
  re-diffuse (nouveau QR code) ; les anciennes balises ne sont plus acceptées.
- **Plusieurs responsables** possibles (chacun sa capacité de déclenchement),
  mais le **relai jamais**.
- Distinction nette **Exercice vs Réel** dans la balise signée, pour ne pas
  confondre un test avec une vraie alerte.

> En résumé : **émettre une alarme = être responsable + posséder la clé**.
> Recevoir / relayer / signaler = tout le monde.

---

## 8. Questions à poser au SDMIS

- L'info **« qui reste dedans + dernière zone vue »** vous serait-elle utile à
  l'arrivée sur intervention ? Sous quelle forme ?
- Le **comptage automatique au point de rassemblement** a-t-il une valeur vs
  l'appel manuel ?
- Un **bouton SOS** relayé entre appareils est-il pertinent ou risqué ?
- Jusqu'où peut-on aller sur le **suivi de présence** sans poser de problème
  réglementaire / d'acceptabilité ?
- Une **app « relai » légère** distribuée aux occupants (relais + message au
  responsable pendant l'alerte) est-elle pertinente, ou faut-il tout regrouper
  dans une seule app ?

---

*Statut : exploration. À prototyper après validation du principe (Phase 3 de la
roadmap). Le cœur — déclenchement BLE + accusés — est la brique commune ; la
cartographie et la localisation par proximité viennent ensuite.*
