# AlertFinDuMonde — Stratégie d'alerte : état de l'art & décision

> **⚠️ DÉCISION FINALE (2026-06-25, révisée) : serveur 100 % maison.**
> On n'adopte PAS ntfy comme produit. On construit notre propre micro-serveur de déclenchement sur notre serveur. Seule pièce externe tolérée : **Google/FCM, uniquement pour le transport du push** jusqu'au téléphone. ntfy reste une simple référence d'inspiration (priorité 5, modèle topic).
> Contraintes API : **gratuite, sans compte, sans clé de licence, sans pub, sans tracking/log superflu — « l'API doit se faire oublier »** (un seul endpoint authentifié par token).
> Détail en bas (« Décision finale »). L'« Option A — ntfy » plus bas est conservée pour l'historique mais **supersédée**.

## Contexte

L'app a deux modes :
1. **Entraînement** — alarme rare et imprévisible (1 à 4×/an, dans une plage horaire de nuit).
2. **Incident réel** — alarme déclenchée par la supervision via un webhook (serveur down, ransomware, base supprimée…).

Question posée : *« impossible qu'il n'existe pas déjà un équivalent ».* → Vérifié. **Si, il en existe**, et même deux catégories logicielles matures.

## 1. Moitié « incident IT → alarme forte par webhook »

Catégorie **on-call / incident alerting / paging**. Une API webhook fait sonner fort le téléphone de l'astreinte en passant outre le mode silencieux.

| Outil | Nature | Déclenchement | Remarque |
|---|---|---|---|
| PagerDuty | Commercial, leader | Events API v2 | Le plus mature |
| Opsgenie | Commercial | API | Atlassian a arrêté les nouvelles ventes (juin 2025) |
| OnPage | Commercial | « Persistent alerting » | Force DND/silencieux jusqu'à 8 h |
| Grafana OnCall | Open-source | Webhook | OSS en maintenance (mars 2025) → Grafana Cloud IRM |
| **ntfy** ⭐ | **Open-source, auto-hébergeable, gratuit** | `curl -H "Priority: 5"` | **Quasi-clone exact de notre besoin** |

### Pourquoi ntfy est le bon choix

- Webhook HTTP trivial (`POST`/`PUT` sur un *topic*).
- **Priorité 5 = son d'alarme persistant qui passe outre les modes silencieux.**
- Apps **Android/iOS déjà existantes** (+ web).
- **Auto-hébergeable** sur notre serveur (auth par token/login) → conforme à la règle « pas de services tiers », **zéro Google/FCM**.
- Intégrations natives : Grafana, Prometheus Alertmanager, Uptime Kuma, cron, tout script HTTP.

```bash
curl -H "Priority: 5" -H "Title: Ransomware NAS-01" \
     -d "Chiffrement anormal détecté — isoler" \
     https://ton-serveur/astreinte-infra
```

Authentification : username+password, access tokens, ou paramètre de requête.

## 2. Moitié « évacuation / notification de masse »

Catégorie **mass notification** : Everbridge, AlertMedia, Omnilert, Alertus, YUDU Sentinel.
API, géo-ciblage, accusés de réception, gestion explicite des exercices incendie — mais **gros produits entreprise** (écoles, hôpitaux, États). Hors cible pour un usage solo/petit parc.

## Ce qui n'a PAS d'équivalent (notre vraie valeur)

- Le **déclenchement aléatoire, rare et imprévisible pour l'entraînement** (1–4×/an, plage de nuit, sans que personne ne sache quand). Les outils ci-dessus déclenchent sur **événement réel** ou **envoi manuel**, jamais en auto-exercice surprise.
- Le **chrono d'évacuation + flux sourdine / terminé** packagé en une app simple.

## DÉCISION FINALE (révisée) — serveur maison + FCM transport

On construit le serveur de déclenchement nous-mêmes. ntfy n'est plus adopté ; il sert d'inspiration.

### Principe

```
Supervision (Zabbix/cron/script)
        │  POST /trigger  (token Bearer)
        ▼
  Micro-serveur maison (PHP, sur notre serveur)
        │  envoie un push data haute priorité
        ▼
   FCM (Google) ── seul tiers, uniquement le transport ──►  Téléphones
        ▼
  App Flutter : handler background → Alarm.set() immédiat → sonnerie + chrono
```

### Règles (« l'API doit se faire oublier »)

- **Gratuite**, **sans compte**, **sans clé de licence**, **sans pub**, **sans tracking/analytics**.
- Un **seul endpoint** authentifié par **token partagé** (Bearer). Rien d'autre exposé.
- Pas de log superflu : on stocke juste le **registre des appareils** (tokens FCM + groupe), nécessaire pour pousser. Pas d'historique d'incidents sauf si voulu plus tard.
- **Aucun tiers sauf Google/FCM**, et FCM **uniquement pour le transport** du push (gratuit, pas de licence, pas de pub). Le reste (réception, logique, alarme) est 100 % maison.

### Composants à construire

**Serveur (PHP, notre serveur) :**
- [ ] `POST /register` — l'app envoie son token FCM + son groupe d'astreinte. Upsert dans une table `devices(token, groupe, maj_le)`.
- [ ] `POST /trigger` — auth `Authorization: Bearer <TOKEN>` ; corps `{type, severity, title, message, targets[]}` ; résout les tokens du/des groupe(s) et envoie un **message data FCM haute priorité** (HTTP v1, via compte de service Google JSON). Réponse `202`.
- [ ] (option) `POST /ack` — l'app confirme la réception → mesure du temps de réaction.

**App Flutter :**
- [ ] `firebase_core` + `firebase_messaging` : récupérer le token, le `POST /register`.
- [ ] `FirebaseMessaging.onBackgroundMessage` : sur message data → `Alarm.set()` immédiat (réveille l'app même fermée, écran verrouillé) → réutilise l'écran de sonnerie + chrono existants.
- [ ] Conserver intacts le **scheduler d'exercices aléatoires** + le mode entraînement.

**Landing :**
- [ ] Réécrire la section API de `index.html` : notre endpoint `POST /trigger` maison (exemple `curl`, token), retirer la mention « spec à concevoir » au profit du contrat réel.

### Caveat honnête (transport)

Pour faire **sonner fort un téléphone app fermée + écran verrouillé**, deux voies seulement :
1. **FCM data haute priorité** (choisi) — fiable, économe en batterie, mais nécessite un **projet Firebase** (= Google, mais gratuit, sans pub/licence). C'est le « ou juste google pour la diffusion » accepté.
2. **100 % sans Google** — l'app maintient une **connexion WebSocket/SSE permanente** via un **service de premier plan Android** (notification permanente + conso batterie). Faisable (notre serveur fait déjà du websocket en prod) mais plus lourd côté téléphone. → bascule possible si on veut zéro Google.

## Décision — Option A *(supersédée — historique)*

1. **Mode incident réel → délégué à ntfy auto-hébergé.** On n'écrit PAS de backend de push maison. L'app Flutter **s'abonne à un topic ntfy** (ou on réutilise carrément l'app ntfy). On supprime la spec d'API maison `/api/v1/trigger`.
2. **Mode entraînement → reste 100 % maison** (planificateur aléatoire + chrono) : c'est le différenciateur sans équivalent.
3. **« Pas de tiers » respecté** : ntfy tourne sur notre serveur, pas de Google/FCM.

### Implications techniques (à faire)

- [ ] Déployer un serveur **ntfy auto-hébergé** (Docker ou binaire) sur le serveur, derrière le domaine.
- [ ] Côté app : intégrer l'**abonnement à un topic ntfy** pour le mode incident (lib `ntfy`/UnifiedPush, ou WebSocket `/{topic}/ws`, ou simple subscribe SSE).
- [ ] Conserver intacts le **scheduler d'exercices aléatoires** + l'**écran de sonnerie/chrono**.
- [ ] Mettre à jour `index.html` : remplacer la section « API maison » par la doc d'intégration **ntfy** (exemples `curl` priorité 5, topics par groupe d'astreinte).
- [ ] (Option) Mapper nos `type`/`severity` sur les en-têtes ntfy (`Priority`, `Tags`, `Title`).

## Sources

- [Open-Source PagerDuty Alternatives 2026 — OnPage](https://www.onpage.com/open%E2%80%91source-pagerduty-alternatives-2026-complete-guide/)
- [PagerDuty vs Opsgenie vs OnPage (2025)](https://www.onpage.com/pagerduty-vs-opsgenie-vs-onpage-which-on-call-alerting-tool-is-right-for-your-team/)
- [ntfy.sh](https://ntfy.sh/) · [Doc publish (priorités)](https://docs.ntfy.sh/publish/) · [ntfy sur Google Play](https://play.google.com/store/apps/details?id=io.heckel.ntfy)
- [Everbridge Mass Notification](https://www.everbridge.com/use-cases/mass-notification-and-incident-communications/) · [AlertMedia vs Everbridge](https://www.alertmedia.com/blog/alertmedia-vs-everbridge-emergency-mass-notification/) · [Top Emergency Notification Providers — Omnilert](https://www.omnilert.com/blog/top-emergency-notification-systems-providers)
