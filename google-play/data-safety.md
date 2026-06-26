# Déclaration « Data Safety » (Sécurité des données) — Google Play

À recopier dans la console Play Store → *Contenu de l'application → Sécurité des
données*. Pour l'état **actuel** de l'app (100 % local, sans backend).

## Collecte et partage

| Question Play Console | Réponse |
|---|---|
| L'app collecte-t-elle des données utilisateur ? | **Non** |
| L'app partage-t-elle des données avec des tiers ? | **Non** |
| Les données sont-elles chiffrées en transit ? | Sans objet (aucune transmission) |
| L'utilisateur peut-il demander la suppression des données ? | Les données restent sur l'appareil ; les désinstaller suffit |

## Types de données — à cocher

Aucune catégorie n'est concernée :

- ❌ Informations personnelles (nom, e-mail, identifiants)
- ❌ Localisation
- ❌ Messages, contacts, photos
- ❌ Activité dans l'app / diagnostics envoyés
- ❌ Identifiants publicitaires

## Note pour l'évolution (Phase 3 — multi-appareils)

> Si un jour l'app envoie un jeton de notification (FCM) à un serveur de
> déclenchement, **cette déclaration devra être mise à jour** :
> - donnée « identifiant d'appareil / jeton push » = collectée,
> - finalité = « fonctionnalité de l'app » (déclencher l'alarme à distance),
> - chiffrée en transit = oui (HTTPS),
> - non partagée avec des tiers.
> Le déclenchement **par Bluetooth** entre appareils proches, lui, ne sort pas
> de l'appareil vers un serveur → resterait « aucune collecte ».
