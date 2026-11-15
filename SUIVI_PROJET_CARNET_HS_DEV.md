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
| [ ] | P1 | Enregistrer un profil, se déconnecter, puis vérifier sa récupération après reconnexion | Test de persistance distante |
| [ ] | P1 | Vérifier la récupération du profil depuis un autre appareil / navigateur | À réaliser |
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
