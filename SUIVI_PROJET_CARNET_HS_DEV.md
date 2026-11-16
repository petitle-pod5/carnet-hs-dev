# Suivi du projet Carnet HS — DEV

Dernière mise à jour : 15 novembre 2026  
Dépôt concerné : `petitle-pod5/carnet-hs-dev`  
Application DEV : https://petitle-pod5.github.io/carnet-hs-dev/

> Ce document est le tableau de bord de suivi. La documentation technique détaillée reste dans `documentation/SECURITE_ET_ARCHITECTURE_SUPABASE.md`.  
> **Règle de sécurité :** aucune modification de la production V3.4.1 sans accord explicite. Les développements et essais se font sur DEV uniquement.

## Légende

- [ ] À faire
- [x] Réalisé / vérifié
- [~] En cours ou partiellement réalisé
- **Priorité** : P1 = indispensable/sécurité ; P2 = important ; P3 = amélioration

## 1. Socle et authentification

| État | Priorité | Tâche | Notes |
|---|---:|---|---|
| [x] | P1 | Intégrer le client Supabase JS v2 dans DEV | Commit `db15163fe694f9eb8de71f9080f1f2a4b1c41920` |
| [x] | P1 | Inscription et connexion par e-mail / mot de passe | Flux testé par l'utilisateur |
| [x] | P1 | Confirmation de l'adresse e-mail | E-mail reçu et confirmation effectuée |
| [x] | P1 | Corriger l'URL de retour vers le sous-répertoire DEV | Commit `1519d7a9159b1a1329f66996cda9ac2993b17392` |
| [x] | P2 | Afficher / masquer le mot de passe et sa confirmation | Commit `a282cce15ebf53093e13df7cbf2731fac0c5b1f8` |
| [x] | P2 | Réinitialisation du mot de passe | Fonction ajoutée ; parcours complet à revalider |
| [x] | P1 | Isoler le stockage local par identifiant utilisateur | Ajouté au code ; test multi-comptes à réaliser |
| [ ] | P1 | Tester inscription, déconnexion et reconnexion avec deux comptes distincts | Vérifier qu'aucune donnée locale ne fuit d'un compte à l'autre |
| [ ] | P1 | Vérifier la gestion des sessions et les retours d'authentification | Contrôler les cas de rechargement et de session expirée |

## 2. Supabase et sécurité des données

| État | Priorité | Tâche | Notes |
|---|---:|---|---|
| [x] | P1 | Créer les six tables : profiles, missions, overtime_entries, validations, audit_events, sync_receipts | Schéma public |
| [x] | P1 | Activer RLS sur les six tables | Présence vérifiée |
| [x] | P1 | Créer et examiner les 17 politiques RLS | Répartition et conditions examinées |
| [x] | P1 | Vérifier la règle d'insertion de validation personnelle | `validations_insert_self` limite l'insertion à sa propre validation déclarative |
| [ ] | P1 | Effectuer les tests d'isolation avec deux comptes réels | Indispensable avant de considérer la sécurité comme validée |
| [ ] | P1 | Tester les droits de lecture / écriture de chaque table | Confirmer les droits attendus et les refus |
| [ ] | P1 | Tester les cas d'accès non autorisé et les erreurs réseau | Documenter les résultats |
| [ ] | P2 | Définir et développer la validation indépendante par le chef d'équipe | Non prise en charge par la règle actuelle de validation personnelle |
| [~] | P1 | Persistance distante du profil et des missions | Fonctions de lecture/écriture présentes ; persistance réelle à confirmer par test |
| [ ] | P1 | Synchroniser les heures supplémentaires, validations et événements d'audit | Ces éléments sont encore enregistrés localement à ce stade |
| [ ] | P1 | Définir les règles de synchronisation, reprise hors ligne et anti-doublons | À concevoir avant mise en service |
| [ ] | P1 | Vérifier la sauvegarde et la restauration des données | À définir et tester |

## 3. Tests fonctionnels de l'application

| État | Priorité | Tâche | Notes |
|---|---:|---|---|
| [x] | P2 | Vérifier l'ouverture de la version DEV après correction de redirection | Retour utilisateur positif |
| [x] | P2 | Vérifier l'affichage des champs profil et des boutons de visibilité du mot de passe | Retour utilisateur positif |
| [x] | P1 | Enregistrer un profil, se déconnecter, puis vérifier sa récupération après reconnexion | Test utilisateur confirmé : toutes les informations du profil ont été retrouvées après reconnexion (16/11/2026) |
| [x] | P1 | Vérifier la récupération du profil depuis un autre appareil | Test utilisateur confirmé le 16/11/2026 : profil et mission principale récupérés sur PC Windows 11 et téléphone Android Oukitel WP55 Pro avec le même compte |
| [ ] | P1 | Vérifier la récupération depuis un second navigateur distinct | À réaliser séparément si le besoin est confirmé |
| [ ] | P1 | Tester la création, modification et suppression d'une mission | Vérifier local et distant |
| [ ] | P1 | Tester l'enregistrement d'heures en mode hors ligne | Vérifier qu'aucune donnée n'est perdue |
| [ ] | P1 | Tester la reprise après coupure réseau et les tentatives répétées | Vérifier l'absence de doublons |
| [ ] | P2 | Rejouer les scénarios historiques de calcul et de totalisation des HS | Ne pas réintroduire les anciens défauts |

## 4. Offres et règles produit — décisions connues

| État | Priorité | Élément | Décision / point à traiter |
|---|---:|---|---|
| [x] | P2 | Offre Essentielle | Tarif confirmé : 2 € / mois (15/11/2026) |
| [~] | P2 | Périmètre de l'offre Essentielle | Saisie locale, sauvegarde serveur des HS validées, synchronisation les jours avec HS, file d'attente hors ligne et reprise ; détails techniques à valider |
| [~] | P2 | Offre Connectée | Inclut l'Essentielle et prévoit rapports périodiques ainsi que sauvegarde/synchronisation PC-cloud ; périmètre à préciser |
| [ ] | P3 | Offre Partenaire | Offre agences / organisations : contenu et tarification à définir |
| [ ] | P2 | Coûts d'hébergement, services et paiements | Comparer les coûts réels avant engagement |
| [ ] | P2 | Choix du système d'abonnement et de facturation | Non décidé |
| [ ] | P2 | Conditions d'utilisation, confidentialité et mentions légales du service | À finaliser avec conseil adapté |

## 5. Documentation et suivi

| État | Priorité | Tâche | Notes |
|---|---:|---|---|
| [x] | P1 | Créer la documentation technique Supabase / sécurité | `documentation/SECURITE_ET_ARCHITECTURE_SUPABASE.md` |
| [x] | P1 | Consigner les commits et étapes d'intégration connus | Voir le mémo technique |
| [x] | P1 | Tenir à jour le mémo lors de chaque nouvelle idée validée | Règle demandée par l'utilisateur |
| [ ] | P2 | Créer / compléter l'historique chronologique du développement | Fichier dédié à vérifier/créer |
| [ ] | P2 | Mettre à jour le manuel utilisateur lorsque les parcours seront stabilisés | Après validation des fonctionnalités |
| [x] | P1 | Créer ce tableau central de suivi | Présent fichier |

## 6. Idées et améliorations à examiner

Ces éléments ne sont pas des engagements de développement tant qu'ils n'ont pas été discutés et validés.

- [ ] Parcours de validation par le chef d'équipe avec authentification et traçabilité adaptées.
- [ ] Interface multilingue et choix de langue à la première connexion.
- [ ] Rapports périodiques (hebdomadaires / mensuels) selon l'offre.
- [ ] Sauvegarde et consultation depuis un PC.
- [ ] Assistance guidée / chatbot.
- [ ] Suivi des versions et procédure de passage DEV vers production.

## 7. Journal des décisions et mises à jour

| Date | Décision / événement | Référence |
|---|---|---|
| 15/11/2026 | Tarif de l'offre Essentielle confirmé à 2 € / mois | Décision utilisateur |
| 15/11/2026 | Inscription, confirmation e-mail et retour vers DEV testés | Test utilisateur |
| 15/11/2026 | Affichage / masquage des mots de passe ajouté et vérifié visuellement | Commit `a282cce15ebf53093e13df7cbf2731fac0c5b1f8` |
| 15/11/2026 | Création du présent tableau de suivi | À compléter avec le commit GitHub |

## 8. Règles de travail

1. Toute nouvelle idée est d'abord discutée ; elle ne devient une tâche validée qu'après accord explicite de l'utilisateur.
2. À chaque idée validée, mettre à jour ce tableau **et** le mémo technique si elle a un impact technique, en indiquant date, périmètre, statut et commit lorsqu'il existe.
3. À chaque évolution livrée, noter le commit et les tests réellement effectués. Ne jamais marquer un test comme réussi sans résultat observé.
4. Ne pas confondre « code ajouté » et « fonctionnalité testée ».
5. Ne jamais modifier la production V3.4.1 sans autorisation explicite.
6. Garder les tâches non terminées visibles ; ne pas les supprimer simplement parce qu'elles sont reportées.

---
*Document de suivi évolutif — Carnet HS DEV.*


## 9. Revue statique du code — 15 novembre 2026

**Inspection documentaire/code uniquement — aucun changement applicatif.**

- [x] Examiner le flux d'authentification et l'isolation du stockage local dans le code DEV.
- [x] Confirmer que le profil et la mission principale ont des fonctions de lecture/écriture Supabase.
- [x] Confirmer que les HS, validations et événements d'audit restent locaux à ce stade.
- [x] Identifier que la validation chef d'équipe actuelle est saisie par l'utilisateur connecté et n'est pas une approbation indépendante.
- [ ] Tester les erreurs réseau pendant le chargement de session et la reprise après reconnexion.
- [ ] Définir une migration contrôlée des anciennes données locales vers l'espace utilisateur, sans import automatique.
- [ ] Concevoir et tester le vrai parcours de validation indépendante par le chef d'équipe.
- [ ] Concevoir la synchronisation des HS avec idempotence, reprise hors ligne, gestion des conflits et accusés de réception.

**Résultat :** aucune modification de code n'a été faite pendant cette revue. Les constats détaillés et leurs limites sont consignés dans `documentation/SECURITE_ET_ARCHITECTURE_SUPABASE.md`.

## 10. Références Git

- Création du tableau de suivi : commit `ce11b9f38858c4cf489fd0426883b034282fd7b8`.

## 11. Préparation technique — prochaines étapes

**Étude réalisée le 15/11/2026 — aucune modification applicative ou Supabase.**

- [x] Décrire le flux cible de synchronisation des HS et les garanties attendues (file locale, UUID stable, idempotence, accusé serveur, reprise).
- [x] Identifier la limite de `sync_receipts` : un reçu seul ne garantit pas une transaction atomique entre reçu et HS.
- [x] Décrire le modèle cible de validation indépendante (compte chef séparé, délégation explicite, périmètre mission, décision auditée).
- [x] Identifier les évolutions de schéma à étudier : délégations de validation et évolution du modèle de validation.
- [ ] Faire valider les règles métier et le schéma cible avant toute migration.
- [ ] Tester l'isolation à deux comptes avant ouverture de nouveaux droits RLS.
- [ ] Implémenter la synchronisation des HS dans DEV après validation du schéma.
- [ ] Recetter les scénarios hors ligne, reprise, doublons et multi-appareils.
- [ ] Concevoir et tester les droits des chefs d'équipe sur DEV.

Voir le détail dans `documentation/SECURITE_ET_ARCHITECTURE_SUPABASE.md`, section « Préparation technique — synchronisation et validation indépendante ».

## 12. Parcours commercial et évolution des abonnements — décision validée le 16 novembre 2026

**Décision produit validée :** le choix initial de l'offre est effectué sur le site internet Carnet HS, et non dans l'application. Le site présente les formules et oriente l'utilisateur vers la souscription.

- Une seule application Carnet HS pour toutes les formules.
- Un seul compte utilisateur, conservé lors de toute évolution d'abonnement.
- L'abonné peut faire évoluer son offre depuis son espace client sur le site, sans créer un nouveau compte.
- Le changement d'offre met à jour les droits et les fonctionnalités accessibles ; il ne doit pas réinitialiser ni faire perdre l'identifiant, le profil, les missions, les HS, les validations ou les sauvegardes.
- À la connexion, l'application récupère les droits d'abonnement associés au compte et adapte l'accès aux fonctionnalités.
- Le contrôle des droits doit être appliqué côté serveur (et dans les politiques d'accès), pas uniquement en masquant des éléments d'interface.
- Le site gère le parcours commercial et la souscription ; l'application reste l'outil opérationnel.

**À concevoir avant développement :** modèle d'abonnement lié à l'identifiant Auth, gestion des changements de formule et de leur date d'effet, paiement/facturation, traitement des échecs ou interruptions de paiement, et procédure de synchronisation des droits entre le site, le backend et l'application.

**Statut :** principe fonctionnel validé ; architecture détaillée, fournisseur de paiement et implémentation non décidés. Aucun code ni paramètre Supabase modifié lors de cette décision.


## 13. Identifiant client central et prévention des essais multiples — décision validée le 16 novembre 2026

**Décision validée :** créer un identifiant client central, indépendant de l'adresse e-mail. Les comptes de connexion éventuels, les périodes d'essai et les abonnements seront rattachés à cet identifiant client.

Objectifs :
- reconnaître un même client même s'il utilise plusieurs adresses e-mail ;
- empêcher qu'une simple nouvelle adresse e-mail permette de recommencer la période d'essai gratuite ;
- conserver un historique cohérent des essais et abonnements ;
- permettre l'évolution d'offre sans création d'un nouveau compte ni perte de données.

**Principes de conception :**
- distinguer l'identité client, les identifiants de connexion et l'abonnement ;
- prévoir une procédure de vérification et de rattachement de comptes avec contrôle de possession, sans fusion automatique sur la seule ressemblance d'adresses ou de noms ;
- appliquer les règles d'essai au niveau du client central, avec dates et historique non réinitialisable par une nouvelle inscription ;
- limiter les données personnelles collectées et définir leur durée de conservation, leurs finalités et les droits d'accès conformément au RGPD ;
- ne pas utiliser l'empreinte de l'appareil comme preuve unique d'identité ; un appareil peut être partagé ou remplacé ;
- ne pas conserver de données de carte bancaire : déléguer le paiement à un prestataire adapté et ne garder que les références minimales nécessaires.

**À concevoir avant développement :** méthode de vérification du client (par exemple téléphone vérifié et/ou moyen de paiement tokenisé, à arbitrer), procédure de récupération/rattachement d'un compte, gestion des cas légitimes de changement de coordonnées, règles anti-fraude proportionnées et schéma de données sécurisé.

**Statut :** principe d'identifiant client central validé ; méthode de vérification, règles détaillées et implémentation non décidées. Aucun code ni schéma Supabase modifié.


### Complément validé — vérification proportionnée du client (16 novembre 2026)

L'utilisateur valide le principe de ne pas imposer une collecte excessive de données personnelles : la protection contre les essais multiples doit décourager les abus sans compliquer inutilement l'inscription des clients légitimes.

- [x] Principe de proportionnalité et de minimisation des données validé.
- [ ] Choisir la méthode concrète de vérification (téléphone, moyen de paiement tokenisé ou combinaison) après étude des cas limites et des contraintes RGPD.


## 14. Ergonomie connexion — icône œil pour afficher le mot de passe (16 novembre 2026)

- [x] Remplacer le bouton texte « Afficher » par une icône œil à droite du champ mot de passe.
- [x] Basculer vers une icône œil barré lorsque le mot de passe est visible.
- [x] Conserver les attributs d'accessibilité (aria-label, aria-pressed, title).
- [x] Appliquer le même comportement au champ de confirmation à l'inscription.
- [x] Modification poussée sur DEV uniquement : commit 89b6474e5a8dc4dd0a89a604871d785dd7de6ad6.
- [x] Vérification utilisateur confirmée : rendu et fonctionnement de l'icône œil validés sur l'environnement testé (16/11/2026).


### Recette de persistance du profil — résultat confirmé le 16 novembre 2026

L'utilisateur confirme avoir enregistré les informations du profil, s'être déconnecté puis reconnecté avec le même compte, et avoir retrouvé toutes les informations. Le test de persistance du profil après reconnexion est donc marqué comme réussi.

Résultats confirmés : récupération du profil après reconnexion sur le même PC, puis récupération du profil et de la mission principale sur le téléphone Android Oukitel WP55 Pro avec le même compte (16/11/2026). Le test multi-appareils est donc réussi pour ces deux appareils. Restent les tests d'isolation entre deux comptes distincts, les accès non autorisés et les erreurs réseau. Cette réussite ne valide pas encore la synchronisation des HS, validations ou événements d'audit.


### Recette multi-appareils — résultat confirmé le 16 novembre 2026

L'utilisateur confirme avoir effectué le test sur son téléphone Android Oukitel WP55 Pro : le profil et la mission principale sont correctement récupérés avec le même compte que sur son PC Windows 11. Le scénario de récupération du profil entre PC et téléphone est marqué comme réussi. Aucun test d'isolation entre comptes distincts n'est couvert par ce résultat.
