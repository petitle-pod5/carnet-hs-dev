# Suivi du projet Carnet HS — DEV

Dernière mise à jour : 22 novembre 2026  
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
| [x] | P1 | Tester inscription, déconnexion et reconnexion avec deux comptes distincts | Test fonctionnel réussi le 16/11/2026 sur DEV : compte B affiche un profil vierge ; après retour au compte A, profil original retrouvé |
| [ ] | P1 | Vérifier la gestion des sessions et les retours d'authentification | Contrôler les cas de rechargement et de session expirée |

## 2. Supabase et sécurité des données

| État | Priorité | Tâche | Notes |
|---|---:|---|---|
| [x] | P1 | Créer les six tables : profiles, missions, overtime_entries, validations, audit_events, sync_receipts | Schéma public |
| [x] | P1 | Activer RLS sur les six tables | Présence vérifiée |
| [x] | P1 | Créer et examiner les 17 politiques RLS | Répartition et conditions examinées |
| [x] | P1 | Vérifier la règle d'insertion de validation personnelle | `validations_insert_self` limite l'insertion à sa propre validation déclarative |
| [~] | P1 | Effectuer les tests d'isolation avec deux comptes réels | Test fonctionnel de séparation des profils réussi le 16/11/2026 ; tests directs des policies RLS, accès non autorisés et droits table par table restent à réaliser |
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


### Recette fonctionnelle à deux comptes — résultat confirmé le 16 novembre 2026

- [x] Connexion au compte B : l'utilisateur retrouve un profil vierge, sans les informations du compte A.
- [x] Retour au compte A : l'utilisateur retrouve son profil original.
- [x] Le test fonctionnel de séparation et de conservation des profils est réussi sur DEV.
- [ ] Tester séparément les policies RLS et les accès directs non autorisés avec deux sessions/comptes ; le test d'interface ne suffit pas à certifier toute la sécurité backend.



### Contrôle SQL des droits et policies — 16 novembre 2026

L'utilisateur a exécuté dans le SQL Editor Supabase une requête de contrôle en lecture seule sur les six tables du schéma public.

Résultats visibles sur la capture :
- RLS active (true) sur les six tables.
- Nombre de policies : 17 au total, réparties comme attendu : profiles 3, missions 4, overtime_entries 4, validations 2, audit_events 2, sync_receipts 2.
- Le privilège SQL SELECT est accordé au rôle authenticated sur les six tables.
- Le privilège SQL SELECT n'est pas accordé au rôle anon sur les six tables.

**Conclusion limitée :** le contrôle de configuration est cohérent avec la migration initiale. Il confirme l'activation de RLS, le nombre de policies et les privilèges SELECT affichés. Il ne teste pas les expressions réelles des policies ni les opérations SELECT/INSERT/UPDATE/DELETE sous deux sessions Auth distinctes. Les tests d'isolation backend restent à effectuer. Aucun changement de code, de policy, de schéma ou de donnée n'a été réalisé ; production inchangée.


### Préparation des tests directs RLS — 16 novembre 2026

- [x] Relire la migration SQL initiale directement dans le dépôt DEV.
- [x] Établir la matrice des privilèges attendus par table et par opération.
- [x] Préparer un protocole de tests positifs et négatifs avec deux sessions Auth.
- [ ] Exécuter les lectures croisées A/B sur les six tables depuis des sessions authentifiées.
- [ ] Exécuter les tests d'écriture croisée sur des lignes sentinelles temporaires, sans viser les données réelles.
- [ ] Vérifier les opérations autorisées du propriétaire et nettoyer les seules lignes sentinelles créées pour le test.

La préparation documentaire est consignée dans `documentation/SECURITE_ET_ARCHITECTURE_SUPABASE.md`. Revue statique uniquement : aucune requête d'écriture, aucun changement de policy, aucun changement applicatif ou de donnée Supabase. La production reste inchangée.


## 15. Site internet commercial — audit statique initial du 17 novembre 2026

**Périmètre :** examen en lecture seule du fichier commercial de production fourni par l'utilisateur (preview-commercial.html) et des ressources associées récupérées dans le dépôt de production. Cette revue ne constitue pas un test fonctionnel complet du site en navigateur. Aucun fichier, paramètre, compte ou contenu de production n'a été modifié.

### Éléments examinés

- preview-commercial.html — structure et liens de la page commerciale.
- site-commercial-preview/styles.css — styles et règles responsive.
- site-commercial-preview/app.js — logique de l'assistant de démonstration.
- site-commercial-preview/mentions-legales.html — contenu juridique provisoire.
- site-commercial-preview/confidentialite.html — projet de texte relatif aux données personnelles.

### Constats confirmés par lecture du code

- [x] Structure HTML organisée en sections : accueil, fonctionnement, offres, questions, appel final et pied de page.
- [x] Navigation principale par ancres internes ; boutons principaux renvoyant aux sections de la page.
- [x] Feuilles de style comportant deux seuils responsive (850 px et 560 px) avec réorganisation des colonnes et cartes.
- [x] Assistant local à réponses prédéfinies ; les questions et réponses sont insérées avec textContent. Les questions ne sont pas transmises à un service distant par le JavaScript examiné.
- [x] Quatre questions rapides sont configurées ; les réponses reposent sur une recherche simple de mots-clés et peuvent être imprécises pour des questions ambiguës ou multi-sujets.
- [x] QR code généré par un service tiers (api.qrserver.com) et configuré pour pointer vers l'application de production https://petitle-pod5.github.io/carnet-hs/.
- [x] Le bouton « Ouvrir Carnet HS » pointe également vers l'application de production, et non vers DEV.
- [x] Le pied de page contient encore l'adresse provisoire contact@exemple.fr.
- [x] Les pages Mentions légales et Confidentialité existent, mais affichent explicitement leur statut provisoire et contiennent des champs à compléter (identité de l'éditeur, coordonnées, hébergeur, responsable du traitement, contact, etc.).
- [x] La maquette précise qu'aucune souscription ni aucun paiement ne sont proposés à ce stade.
- [x] Le texte de confidentialité décrit l'assistant comme local et indique que les sauvegardes distantes/synchronisations évoquées ne sont pas actives dans cette maquette.

### Points de vigilance / actions proposées — non encore validés comme décisions produit

| Priorité | Point | Action proposée |
|---|---|---|
| P1 | Contact provisoire | Définir et publier une adresse de contact réelle avant ouverture commerciale. |
| P1 | Mentions légales et confidentialité provisoires | Compléter et faire vérifier les textes selon l'identité juridique, l'hébergement et les traitements réellement mis en œuvre. |
| P1 | Parcours commercial incomplet | Définir le parcours réel de découverte, création de compte, choix d'offre, souscription et accès à l'application avant d'annoncer une souscription disponible. |
| P2 | QR code dépendant d'un service tiers | Étudier la génération et l'hébergement du QR code dans les ressources du projet ; vérifier la destination sur téléphone. |
| P2 | Assistant à mots-clés | Tester les questions ambiguës et prévoir une réponse de repli claire ; maintenir les réponses alignées sur les fonctions réellement disponibles. |
| P2 | Responsive non testé sur appareils | Effectuer une recette réelle sur plusieurs largeurs d'écran et sur Android/iPhone. |
| P2 | Ressources et liens | Tester en navigateur le chargement CSS/JS, les liens de pied de page, les redirections et le QR code. |

### Limites de cette revue

- Le code CSS prévoit une adaptation mobile, mais aucun rendu réel sur téléphone n'a été validé par cette revue.
- La présence d'un lien ou d'un bouton dans le code ne prouve pas que sa destination est disponible ou que son comportement fonctionne en ligne.
- Le QR code est configuré vers la production ; son affichage et son scan effectif restent à tester.
- Aucun parcours de création de compte, paiement ou souscription n'a été exécuté.
- Les mentions légales et la confidentialité n'ont pas fait l'objet d'une validation juridique.
- Les constats concernent la version des fichiers examinés le 17/11/2026 ; ils ne certifient pas à eux seuls l'état actuel du site en production.

**Statut :** audit statique initial réalisé ; audit fonctionnel en navigateur et recette mobile restent à effectuer. Les recommandations ci-dessus sont des propositions de travail, pas des décisions de modification du site.

**Règle de périmètre :** aucun changement apporté au dépôt de production petitle-pod5/carnet-hs, à son site publié, à Supabase ou à l'application. Toute correction future devra être préparée et testée sur DEV après validation explicite.



## 16. Organisation documentaire mixte — 18 novembre 2026

Les documents de suivi et de décisions destinés à la lecture et à l’archivage sont conservés en Word dans le dépôt interne, sous `01_SUIVI_DEVELOPPEMENT/`. Les tableaux et simulations sont tenus dans Excel, sous `03_TABLEAUX_EXCEL/`. La documentation technique utile aux développeurs reste en Markdown dans `documentation/`.

Pour les deux premières offres, les fichiers Word `Suivi_offres_Carnet_HS_2026-11-18 (1).docx` et Excel `Suivi_offres_Carnet_HS_2026-11-18.xlsx` sont présents sur `main` dans le dépôt interne depuis la fusion de la PR #1, le 18 novembre 2026. La tarification confirmée de l’offre Essentielle est de 2 €/mois. Le tarif de l’offre Connectée et les coûts de service, paiement et hébergement ne sont pas renseignés tant qu’ils ne sont pas décidés. Aucun code applicatif ni paramètre Supabase n’est modifié par cette organisation documentaire.

**À valider avant toute publication commerciale ou transfert en production :** tarif Connectée, périmètres encore ouverts des deux offres, coûts réels, modèle de facturation et textes commerciaux/juridiques. Cette mise à jour documentaire ne vaut pas validation de ces points. Les fichiers bureautiques sont fusionnés dans `main` du dépôt interne.


## Décisions commerciales et techniques — 19 novembre 2026

Les décisions ci-dessous complètent et, lorsqu'elles diffèrent, remplacent les formulations provisoires antérieures de ce tableau.

### Décisions validées

- Identité : l'UUID Supabase reste l'identifiant technique. Un `client_code` Carnet HS distinct, unique et permanent est attribué côté serveur. Il ne dépend pas de l'e-mail et ne remplace pas l'authentification.
- Offre 1 — Essentielle : « Je gère mes heures supplémentaires. Je sauvegarde en local (téléphone, PC, Mac). Je fais le bilan avec mon responsable, à la fréquence que nous définissons ensemble, pour validation. »
- Le serveur Supabase est l'autorité sur les abonnements et les droits. Il les détermine, transmet les droits à l'application et vérifie les opérations sensibles ; l'interface seule ne sécurise pas une fonction.
- Une seule application sert les trois offres et adapte les fonctionnalités selon les droits. Le site commercial gère la relation client et la souscription ; Supabase conserve identité, abonnements et droits ; l'application utilise les droits.
- Architecture en quatre blocs : gestion du compte, gestion commerciale, gestion des droits, application Carnet HS.
- Changement d'offre immédiat dans les deux sens, avec adaptation des droits et régularisation au prorata. Une montée d'offre attend la confirmation du paiement côté serveur. Compte, UUID, code client et données restent les mêmes.
- Les cinq tables commerciales proposées sont `plans`, `subscriptions`, `plan_entitlements`, `subscription_events` et `billing_customers`. Les six tables historiques restent intactes ; toute modification ultérieure exige un plan explicite.
- Hors connexion : saisie et conservation locales, détection de la connexion et de la joignabilité du serveur, puis synchronisation automatique au retour du réseau avec le message « Connexion active, synchronisation en cours… ». Une donnée n'est confirmée synchronisée qu'après accusé du serveur ; les reprises évitent les doublons.
- E-mails automatiques avant l'échéance et au début de la tolérance de 7 jours. Une coupure réseau n'efface pas les heures locales ; l'application informe que la synchronisation attend le retour du réseau et les droits applicables.
- Validation du chef par lien sécurisé ou par son propre compte.

### Points en attente

- Avec le Rex : procédure de refus, correction, nouvelle soumission et traçabilité d'une validation.
- Détails du lien sécurisé et de la vérification de l'identité du chef.
- Noms, tarifs et périmètre détaillé des offres 2 et 3, calendrier exact des rappels, prestataire de paiement et modalité d'avoir/remboursement du prorata.
- Durée de cache des droits hors connexion et comportement précis de synchronisation après expiration.

### État de réalisation

Le fichier `supabase/migrations/20261119_000002_commercial_entitlements.sql` est préparé comme migration additive pour le projet `carnet-hs-dev`. Il prévoit l'ajout de `client_code` à `profiles` et des cinq tables commerciales, avec des règles RLS restrictives. La migration n'a pas été appliquée.

#### État réel contrôlé dans Supabase DEV le 19 novembre 2026

Le tableau de bord du projet `carnet-hs-dev` a été ouvert. L'offre actuelle ne permet pas de créer une branche de base de données sans changement payant de formule ; aucune branche n'a été créée.

Une requête SQL en lecture seule a confirmé l'inventaire actuel de six tables publiques (`profiles`, `missions`, `overtime_entries`, `validations`, `audit_events`, `sync_receipts`) et 17 politiques RLS. RLS est activée sur les six tables, mais n'est pas forcée. Les 17 politiques existantes sont permissives et réservées au rôle `authenticated`.

Le contrôle complémentaire des colonnes de `profiles` et des cinq tables commerciales n'a pas abouti dans l'éditeur. La présence ou l'absence de `client_code` n'est donc pas confirmée. La migration n'a pas été exécutée, et aucune modification distante de schéma, de policy ou de données n'est déclarée.

**À reprendre :** confirmer les colonnes de `profiles` et l'existence des cinq tables proposées ; examiner l'interaction des nouvelles politiques restrictives avec les policies permissives déjà en place ; appliquer uniquement après ce contrôle, puis vérifier les objets et policies résultants. Ne pas toucher aux six tables historiques au-delà de l'ajout planifié de `client_code` à `profiles`, ni au projet de production `petitle-pod5/carnet-hs`.


## 17. Site commercial Carnet HS — 22 novembre 2026

Les pages de présentation des offres et les réponses prédéfinies du chatbot ont été mises à jour dans `petitle-pod5/carnet-hs`, branche `codex/site-offres-chatbots-2026-11`, commit `d43732c6f257d7a26c8a9fd9f1256cb6bbb51040`. La page affiche Essentiel à 0 € pendant trois mois, puis 2 € par mois; Essentiel + à 3,99 € par mois; Partenaire est indiqué comme formule en préparation. Le chatbot indique que les paiements et la sauvegarde cloud ne sont pas activés sur la maquette.

**Vérifications effectuées le 22/11/2026 :** ouverture locale de `site-commercial/index.html`, `site-commercial-preview/index.html` et `preview-commercial.html`; test des réponses du chatbot sur les prix et les sauvegardes; `git diff --check` propre. Aucun test automatisé formel n’a été repéré ni lancé.

**État de livraison :** la branche est poussée sur GitHub, mais elle n’est ni fusionnée ni déployée. Les textes des offres 2 et 3 doivent d’abord être finalisés par l’utilisateur. Après cette étape, reprendre la revue, puis traiter la fusion et le déploiement comme étapes distinctes à effectuer ultérieurement. Aucun code applicatif principal, aucune donnée ou configuration Supabase et aucun fichier de production n’ont été modifiés.

La prochaine mise à jour des documents Word/Excel de suivi commercial devra intégrer les textes définitifs et les décisions tarifaires confirmées. Les coûts réels et le modèle de facturation restent à confirmer; aucune donnée n’est inventée ici.
