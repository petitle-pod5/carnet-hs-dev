# Carnet HS — architecture sécurité et authentification (DEV)

Date : 15 novembre 2026

## État actuel constaté

- L'application est une page statique hébergée sur GitHub Pages.
- Les profils, heures, validations et sauvegardes sont stockés dans le navigateur via `localStorage`.
- Il n'existe actuellement ni création de compte, ni authentification serveur, ni séparation de données garantie entre utilisateurs.
- La validation de journée enregistre le nom du chef indiqué dans le profil, mais ne vérifie pas l'identité du chef.
- Une interface de connexion seule ne rendrait pas ces données privées ou sécurisées.

## Décision d'architecture proposée

Utiliser Supabase comme service backend, sous réserve de création et de configuration d'un projet appartenant au propriétaire de Carnet HS.

Composants :
1. Supabase Auth pour inscription, connexion, déconnexion et récupération de compte.
2. PostgreSQL pour les profils, missions, enregistrements HS, validations et journaux d'audit.
3. Row Level Security (RLS) activée sur toutes les tables exposées.
4. Chaque ligne métier porte un identifiant utilisateur ou une relation de mission contrôlée côté serveur.
5. Les règles RLS vérifient l'identité via `auth.uid()`; aucune sécurité ne repose uniquement sur un contrôle JavaScript dans le navigateur.
6. Les clés secrètes/service-role ne sont jamais intégrées au code public. Seule la clé publique anon/publishable peut être utilisée côté navigateur, avec RLS correctement configurée.
7. Les écritures hors ligne restent dans une file locale et ne sont marquées comme synchronisées qu'après accusé de réception serveur. Les opérations de synchronisation devront être idempotentes.

## Tables à concevoir

- `profiles` : utilisateur, identifiant salarié et informations de profil.
- `missions` : employeur, agence, lieu de travail, chef d'équipe, dates de validité.
- `overtime_entries` : début, fin, motif, mission, auteur.
- `validations` : entrée/journée concernée, validateur authentifié, date, mode et statut.
- `audit_events` : événements sensibles et historique des changements.
- `sync_receipts` : identifiants d'opérations reçues pour éviter les doublons.

Le schéma final devra être validé avant migration. Il faudra notamment décider comment rattacher un chef d'équipe à une mission et comment lui déléguer explicitement un droit de validation.

## Politique de sécurité minimale

- RLS activée et testée pour chaque table.
- Un utilisateur ne peut lire ou modifier que ses propres données, sauf délégation explicite et vérifiée.
- Un chef ne peut valider que les missions auxquelles il a été autorisé.
- Les validations sont append-only ou corrigées par événement compensatoire audité ; elles ne doivent pas être réécrites silencieusement.
- Les sauvegardes et restaurations sont versionnées. Une restauration ne doit jamais écraser silencieusement des données plus récentes.
- Transport HTTPS, politique de récupération de compte, journalisation et tests de restauration.
- Les tests doivent inclure deux comptes distincts pour vérifier qu'aucune donnée ne fuit entre eux.

## Pré-requis avant d'activer l'authentification

Le propriétaire doit créer le projet Supabase et fournir, via un canal adapté :
- l'URL du projet ;
- la clé publique anon/publishable ;
- la confirmation des paramètres d'authentification (inscription, confirmation email, récupération de compte).

Ne jamais demander ni intégrer une clé `service_role`, un mot de passe administrateur ou un secret serveur dans le dépôt public.

## Limite de la version DEV actuelle

La version DEV peut préparer l'interface et les contrôles de profil, mais tant que Supabase n'est pas configuré et que les politiques RLS n'ont pas été testées, les données restent locales au navigateur. Aucun écran ne doit laisser croire qu'un compte ou une sauvegarde serveur existe déjà.


## Journal de mise en place — 15 novembre 2026

### Projet Supabase

- Projet Supabase `carnet-hs-dev` créé dans l'espace du propriétaire.
- Offre actuellement affichée : Free.
- Le tableau de bord du projet a été ouvert et la rubrique Authentication a été atteinte.
- L'URL de redirection du site n'est pas encore configurée.
- Aucune connexion Supabase n'est encore intégrée au code de l'application.

### Paramètres Auth vérifiés et enregistrés

- Autoriser les nouvelles inscriptions : activé.
- Confirmation de l'adresse e-mail : activée.
- Fournisseur Email : activé.
- Liaison manuelle de comptes : désactivée.
- Connexions anonymes : désactivées.
- Changement d'adresse e-mail sécurisé : activé (confirmation sur l'ancienne et la nouvelle adresse).
- Changement de mot de passe sécurisé : activé.
- Mot de passe actuel exigé lors d'une modification : activé.
- Longueur minimale du mot de passe : 12 caractères.
- Exigences : minuscules, majuscules, chiffres et symboles.
- Magic links et OTP e-mail : désactivés (connexion prévue par e-mail + mot de passe).
- Expiration OTP e-mail : 3600 secondes ; longueur OTP : 8 chiffres (paramètres affichés, fonctionnalité OTP non activée).
- Protection contre les mots de passe compromis : indisponible sur l'offre Free selon l'indication affichée par le tableau de bord (fonctionnalité annoncée Pro et supérieur).

### Règle complémentaire dans l'interface Carnet HS

Lors de la création du compte, afficher une consigne explicite demandant à l'utilisateur de choisir un mot de passe unique, différent de celui de sa messagerie. Prévoir une confirmation du mot de passe, un contrôle de robustesse et un mécanisme d'affichage/masquage. Carnet HS ne demande jamais et ne stocke jamais le mot de passe de la messagerie. Cette consigne est pédagogique : Supabase ne peut pas comparer le mot de passe Carnet HS à celui d'un autre service.

### Étape suivante

Configurer les URL du site et les URL de redirection autorisées dans Authentication > URL Configuration, en utilisant uniquement l'adresse GitHub Pages DEV :
`https://petitle-pod5.github.io/carnet-hs-dev/`

Ne pas ajouter l'URL de production à ce projet DEV. Après cette étape, configurer les modèles d'e-mails de confirmation et de récupération, puis préparer le schéma PostgreSQL et les politiques RLS avant d'intégrer l'authentification à l'application.


### E-mails Auth — état SMTP (15 novembre 2026)

- Écran Authentication > Emails > SMTP Settings consulté.
- `Enable custom SMTP` est actuellement désactivé ; ce réglage est laissé désactivé volontairement.
- Le projet utilise donc le service SMTP intégré de Supabase pour les essais.
- Limites documentées par Supabase pour ce service par défaut : envoi uniquement aux adresses e-mail autorisées de l'équipe/organisation du projet, plafond actuellement indiqué de 2 e-mails par heure pour l'ensemble du projet, service best-effort sans garantie de disponibilité ou de livraison. Ce service n'est pas destiné à la production.
- Conséquence : les essais de confirmation/récupération ne pourront être réalisés qu'avec une adresse autorisée dans l'organisation Supabase tant qu'un SMTP personnalisé n'est pas configuré.
- Un fournisseur SMTP externe sera nécessaire avant les tests avec des adresses de bêta-testeurs et avant toute mise en service publique.
- Brevo reste une piste à évaluer, non choisie ni configurée à ce stade. Aucun identifiant SMTP n'a été saisi.
- Ne pas désactiver la confirmation d'e-mail pour contourner ces limites.


## Schéma SQL initial préparé — 15 novembre 2026

Fichier de migration ajouté au dépôt DEV :
`supabase/migrations/20261115_000001_initial_schema_rls.sql`

Il prépare les tables :
- `profiles` : profil vide créé automatiquement après inscription Auth.
- `missions` : informations de mission et coordonnées de contact.
- `overtime_entries` : périodes d'heures supplémentaires.
- `validations` : trace des validations.
- `audit_events` : journal d'événements non modifiable par le rôle authentifié.
- `sync_receipts` : identifiants de réception pour éviter les doublons de synchronisation.

RLS est activée sur les six tables. Les politiques limitent les lectures/écritures des utilisateurs authentifiés à leurs propres lignes. Les heures sont liées à une mission appartenant au même utilisateur via une clé étrangère composée.

### Limite volontaire concernant la validation

La migration n'autorise pour l'instant que la validation auto-déclarée par le compte connecté (`self_recorded`). Elle ne donne aucun accès à un chef d'équipe. La validation par un chef authentifié et la délégation de droits restent à concevoir et à tester avant activation ; ne pas présenter une auto-déclaration comme une validation indépendante du chef.

### Déploiement et validation

- Le fichier SQL est préparé dans GitHub DEV, mais n'a pas encore été exécuté dans Supabase.
- Avant exécution, vérifier que le tableau de bord affiche bien le projet `carnet-hs-dev` et sa base de données DEV.
- Exécuter la migration dans SQL Editor uniquement après confirmation visuelle du projet.
- Après exécution, vérifier les six tables, l'état RLS et les policies.
- Effectuer des tests avec deux comptes authentifiés distincts : le compte A ne doit jamais lire, modifier ou supprimer les données du compte B, et inversement.
- La sécurité n'est pas considérée comme validée tant que ces tests négatifs et positifs ne sont pas passés.


### Résultat de la migration — vérification visuelle (15 novembre 2026)

La capture du Table Editor Supabase montre les six tables attendues dans le schéma `public` :
`profiles`, `missions`, `overtime_entries`, `validations`, `audit_events` et `sync_receipts`.

La présence des tables est confirmée visuellement. L'activation effective de RLS et la présence des politiques doivent encore être vérifiées par une requête SQL de contrôle ; la sécurité n'est donc pas encore déclarée validée.


### Résultat du contrôle RLS — 15 novembre 2026

Requête de lecture exécutée dans Supabase SQL Editor sur les six tables du schéma `public`. Résultat affiché : les six lignes ont `rls_active = true` :
- `audit_events`
- `missions`
- `overtime_entries`
- `profiles`
- `sync_receipts`
- `validations`

L'activation de RLS est donc confirmée pour les six tables. La vérification des policies installées et les tests d'isolation entre deux comptes distincts restent à effectuer.


### Résultat du comptage des policies — 15 novembre 2026

La requête de comptage retourne exactement 17 policies sur les six tables :
- `audit_events` : 2
- `missions` : 4
- `overtime_entries` : 4
- `profiles` : 3
- `sync_receipts` : 2
- `validations` : 2

Le total et la répartition correspondent au script de migration. La présence des policies est confirmée ; leur comportement réel doit encore être vérifié par des tests d'accès avec deux comptes authentifiés distincts.


### Revue visuelle des conditions des 17 policies — 15 novembre 2026

Les captures de pg_policies montrent les conditions `USING` / `WITH CHECK` des policies et leur cohérence générale avec l'isolation par `auth.uid()` :
- profils : `id = auth.uid()` pour SELECT, INSERT et UPDATE ;
- missions : `user_id = auth.uid()` pour SELECT, INSERT, UPDATE et DELETE ;
- heures supplémentaires : `user_id = auth.uid()` pour SELECT, INSERT, UPDATE et DELETE ;
- audit : SELECT limité à `user_id = auth.uid()`, INSERT contrôlé par le propriétaire et l'acteur ;
- reçus de synchronisation : SELECT et INSERT limités à `user_id = auth.uid()` ;
- validations : SELECT limité au propriétaire ; INSERT en auto-déclaration, avec contrôle du compte validateur.
La fin de l'expression de `validations_insert_self` est tronquée dans la capture ; sa condition complète doit être relue directement dans SQL avant de certifier le détail. Les tests d'isolation entre deux comptes restent à effectuer. L'application DEV n'est pas encore connectée à Supabase à ce stade.


### Condition complète de validations_insert_self vérifiée — 15 novembre 2026

La condition `WITH CHECK` a été affichée en trois segments dans Supabase et confirme exactement :
`auth.uid() = user_id AND validator_user_id = auth.uid() AND validation_mode = 'self_recorded'`.

Ainsi, dans cette première version, un utilisateur authentifié ne peut insérer qu'une validation rattachée à son propre compte, en se déclarant lui-même validateur, et uniquement en mode `self_recorded`. Cela ne constitue pas une validation indépendante par le chef d'équipe ; celle-ci reste désactivée jusqu'à conception d'une délégation/authentification appropriée.


## Première intégration Supabase dans l'application DEV — 15 novembre 2026

Commit DEV : `db15163fe694f9eb8de71f9080f1f2a4b1c41920`.

Le fichier `index.html` de `petitle-pod5/carnet-hs-dev` contient désormais :
- chargement de la bibliothèque JavaScript Supabase v2 depuis jsDelivr ;
- client configuré avec l'URL du projet DEV et la clé Publishable (aucune clé secrète/service-role) ;
- interface de création de compte et de connexion par e-mail/mot de passe ;
- confirmation du mot de passe à l'inscription et rappel de choisir un mot de passe unique, différent de celui de la messagerie ;
- contrôle côté interface de 12 caractères minimum avec minuscules, majuscules, chiffres et symbole (Supabase reste l'autorité serveur pour les règles configurées) ;
- demande de réinitialisation du mot de passe ;
- déconnexion ;
- stockage local des données de l'application séparé par identifiant Auth Supabase ;
- lecture et enregistrement du profil et de la mission dans les tables `profiles` et `missions`, protégées par RLS.

### Limites explicites de cette première étape

- Les heures supplémentaires, validations et journaux de l'interface restent encore locaux ; leur synchronisation vers `overtime_entries`, `validations` et `audit_events` n'est pas encore intégrée.
- Les anciennes données locales globales V3.4.1 sont laissées intactes et ne sont pas importées automatiquement dans un compte, afin d'éviter tout mélange entre utilisateurs. Une procédure de migration contrôlée devra être conçue.
- Le code a été poussé sur le dépôt DEV uniquement. La production `petitle-pod5/carnet-hs` n'a pas été modifiée.
- L'intégration doit maintenant être testée sur la page GitHub Pages DEV : chargement de la page, inscription, réception/confirmation e-mail, connexion, création du profil vide, enregistrement/lecture du profil, déconnexion et reconnexion.
- Ne pas annoncer que toutes les données Carnet HS sont déjà isolées côté serveur tant que la synchronisation des HS/validations et les tests d'isolation entre deux comptes ne sont pas terminés.


## Correction du retour des e-mails Supabase — 15 novembre 2026

Le premier test d'inscription a confirmé l'envoi du courriel et la validation de l'adresse, mais le lien renvoyait à la racine GitHub Pages (`https://petitle-pod5.github.io/`) au lieu de l'application DEV.

Correction poussée dans `index.html`, commit `1519d7a9159b1a1329f66996cda9ac2993b17392` :
- `auth.signUp` transmet désormais explicitement `options.emailRedirectTo` vers `https://petitle-pod5.github.io/carnet-hs-dev/` ;
- la réinitialisation du mot de passe utilise également cette URL de retour.

Configuration Supabase à vérifier dans Authentication > URL Configuration :
- Site URL : `https://petitle-pod5.github.io/carnet-hs-dev/`
- Redirect URL autorisée : `https://petitle-pod5.github.io/carnet-hs-dev/`

Le lien de confirmation copié dans la conversation contenait un access token et un refresh token. Session à considérer comme exposée : révoquer les sessions de ce compte avant de continuer les tests. Un sign-out global révoque les refresh tokens, mais un access token JWT déjà émis peut rester valide jusqu'à son expiration ; cette limite est documentée par Supabase.


## Amélioration ergonomique — affichage du mot de passe — 15 novembre 2026

Commit DEV : `a282cce15ebf53093e13df7cbf2731fac0c5b1f8`.

Ajout de boutons Afficher/Masquer sur les deux champs du formulaire d'authentification :
- mot de passe lors de la connexion ou de l'inscription ;
- confirmation du mot de passe lors de l'inscription.

Le bouton bascule uniquement le type du champ entre `password` et `text`. La valeur saisie n'est ni modifiée ni transmise différemment. Contrôle clavier possible comme les autres boutons.
