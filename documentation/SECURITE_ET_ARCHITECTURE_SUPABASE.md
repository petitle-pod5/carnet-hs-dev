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


## Recette utilisateur — première connexion et profil vierge — 15 novembre 2026

L'utilisateur a réalisé un test réel sur la DEV et a confirmé que le parcours fonctionne :
- ouverture de Carnet HS DEV ;
- création du compte avec adresse e-mail et mot de passe ;
- réception du courriel Supabase et confirmation de l'adresse ;
- retour vers l'URL correcte de Carnet HS DEV après confirmation ;
- connexion au compte et affichage de l'espace personnel ;
- affichage d'un profil vierge à compléter.

Le retour vers la racine GitHub Pages, qui produisait une 404, a été corrigé en forçant l'URL de redirection DEV dans le parcours d'inscription et de réinitialisation du mot de passe.

### Ergonomie validée
L'utilisateur a demandé et validé l'ajout d'un contrôle Afficher/Masquer sur le mot de passe et sur sa confirmation. Modification intégrée dans le commit DEV `a282cce15ebf53093e13df7cbf2731fac0c5b1f8`.

### Point restant — ne pas considérer la persistance du profil comme validée
À ce stade, l'écran connecté indique que les heures restent locales et le formulaire de profil indique encore une mémorisation sur le téléphone. La création/connexion Supabase est donc validée par le test utilisateur, mais pas encore l'enregistrement du profil dans la table Supabase ni sa récupération sur un autre appareil. Ces tests restent à réaliser avant de déclarer la synchronisation et l'isolation des données pleinement validées.

### Règle de suivi
Toute nouvelle idée ou évolution explicitement validée par l'utilisateur doit être ajoutée au présent mémo DEV, avec sa date, son périmètre, son statut (validé / à tester / en attente) et, si disponible, le commit correspondant. La production reste hors périmètre tant qu'une migration n'a pas été explicitement autorisée.


## Revue statique du code DEV — 15 novembre 2026

Revue du fichier `index.html` effectuée sans modification du code ni exécution de tests en conditions réelles.

### Points confirmés dans le code
- L'authentification utilise le client Supabase JS v2 et les comptes sont associés à un espace local nommé avec l'identifiant Supabase de l'utilisateur.
- Le profil et la mission principale sont lus depuis Supabase à la connexion et écrits lors de l'enregistrement du profil.
- Les heures supplémentaires, validations et événements d'audit sont encore stockés dans le navigateur ; aucun appel d'écriture vers `overtime_entries`, `validations` ou `audit_events` n'a été trouvé dans le code examiné.
- La validation affichée comme validation du chef d'équipe est actuellement enregistrée par l'utilisateur connecté à partir du nom saisi dans son profil. Elle ne constitue donc pas encore une validation indépendante/authentifiée du chef d'équipe.
- Le message d'interface distingue bien le profil lié à Supabase et les heures qui restent locales.

### Points de vigilance à tester / corriger avant extension
1. **Restauration des données historiques :** le code de changement de compte utilise un espace local vierge par utilisateur. L'ancien stockage global n'est pas importé automatiquement. Prévoir une migration volontaire et contrôlée si des utilisateurs possèdent déjà des HS locales.
2. **Chargement du compte :** `activateSession` charge le profil distant avant d'afficher l'application. Tester les erreurs réseau, la reprise après échec et les événements de session afin d'éviter un écran bloqué ou un état incohérent.
3. **Validation chef d'équipe :** concevoir un véritable parcours d'approbation séparé, avec identité du validateur, autorisation serveur et traçabilité. Ne pas présenter la validation actuelle comme indépendante.
4. **Synchronisation des HS :** concevoir l'envoi idempotent, la reprise hors ligne, les conflits et les accusés de réception avant d'écrire dans les tables correspondantes.

### Limites de cette revue
Il s'agit d'une inspection statique du code et de la documentation. Aucun test multi-comptes, aucune requête de contrôle sur les données réelles et aucun test sur appareil secondaire n'ont été exécutés pendant cette revue. Les constats ne remplacent pas une recette fonctionnelle ou un audit de sécurité complet.

## Préparation technique — synchronisation et validation indépendante

Date : 15 novembre 2026
Statut : étude préparatoire uniquement — aucune migration ni modification applicative exécutée.

### A. Synchronisation des heures supplémentaires

**État de départ confirmé :** `overtime_entries` contient déjà les colonnes `id`, `user_id`, `mission_id`, `started_at`, `ended_at`, `note`, `created_at`, `updated_at`. La table `sync_receipts` contient une contrainte unique `(user_id, operation_id)`. Les heures de l'application restent toutefois enregistrées dans `localStorage` ; aucun flux de synchronisation n'est implémenté dans `index.html`.

**Flux recommandé à concevoir :**
1. À la fin d'une HS, créer un identifiant UUID stable côté appareil et conserver l'entrée dans le stockage local.
2. Lui attribuer un état local explicite : `pending`, `syncing`, `synced` ou `error`, sans jamais retirer la copie locale avant confirmation serveur.
3. À la reconnexion, envoyer les opérations en attente avec leur identifiant stable. L'enregistrement serveur doit être idempotent : une même opération rejouée ne crée jamais une seconde HS.
4. Utiliser `sync_receipts` comme mécanisme de déduplication seulement après avoir défini précisément la transaction serveur. La table actuelle ne suffit pas à elle seule à garantir une écriture atomique de l'HS et de son reçu.
5. Après confirmation du serveur, marquer l'entrée comme synchronisée. En cas d'échec, conserver les données et l'état d'erreur pour une nouvelle tentative.
6. Charger les HS distantes à la connexion et fusionner avec la file locale sans écraser une entrée locale plus récente ou non synchronisée.
7. Prévoir les cas d'édition/suppression, les missions expirées, les HS en cours sans heure de fin, les conflits et les changements d'appareil.

**Décisions techniques à prendre avant codage :**
- Générer l'UUID local à la création de l'HS et le conserver à chaque tentative.
- Définir si une HS terminée est immuable ou modifiable ; privilégier un événement de correction audité plutôt qu'une modification silencieuse après validation.
- Définir la stratégie d'upload transactionnel (fonction PostgreSQL/RPC ou autre mécanisme serveur atomique) afin d'éviter une HS créée sans reçu ou un reçu sans HS.
- Définir les règles de conservation et de récupération des données locales historiques avant toute migration.
- Définir le traitement des doublons déjà présents dans les appareils et les anciennes données V3.4.1.

**Recette minimale :** création hors ligne, reconnexion, envoi réussi, répétition de la même opération, coupure pendant l'envoi, redémarrage navigateur, connexion sur un second appareil, absence de doublon, absence de perte et isolation entre deux comptes.

### B. Validation indépendante par le chef d'équipe

**État de départ confirmé :** la table `validations` accepte uniquement `validation_mode = 'self_recorded'` et exige `validator_user_id = auth.uid()`. Il n'existe pas encore de table de délégation/autorisation des chefs dans la migration initiale. Le bouton actuel enregistre une validation locale à partir du nom renseigné dans le profil ; ce n'est pas une approbation indépendante.

**Modèle recommandé à concevoir :**
1. Le salarié conserve la saisie et la transmission de ses HS.
2. Le chef d'équipe dispose de son propre compte Auth ; il ne partage jamais le compte du salarié.
3. Une autorisation explicite relie le compte du chef à une mission ou à un périmètre précis, avec dates de validité et révocation possible.
4. Le chef consulte uniquement les éléments qui lui sont attribués et peut approuver ou refuser avec commentaire facultatif.
5. Le serveur vérifie l'identité, l'autorisation active, le périmètre de la mission et l'état de l'entrée. Le contrôle ne doit pas reposer sur le JavaScript du navigateur.
6. Chaque décision est ajoutée comme événement non silencieusement modifiable : auteur authentifié, date serveur, entrée/journée concernée, résultat et commentaire. Une correction ultérieure crée un nouvel événement audité.
7. Le salarié voit clairement l'état : en attente, approuvé, refusé ou à corriger. Une auto-déclaration ne doit jamais être affichée comme une validation par un chef.

**Objets de base de données à étudier avant migration :** une table de délégation/affectation des validateurs (chef, mission, période, statut, créateur) et une évolution contrôlée de `validations` pour distinguer l'auto-déclaration et l'approbation indépendante. Les politiques RLS et contraintes doivent être conçues avec des tests négatifs ; ne pas ajouter de policy permissive générique.

**Recette minimale :** chef autorisé peut consulter et décider ; chef non autorisé ne voit rien et ne peut rien valider ; salarié ne peut pas se faire passer pour le chef ; délégation expirée/révoquée refusée ; décision horodatée et traçable ; tentative de modification/suppression directe refusée.

### C. Ordre de réalisation proposé

1. Stabiliser les tests d'authentification et d'isolation à deux comptes.
2. Définir le modèle de données et les règles métier de synchronisation, puis faire valider le schéma avant migration.
3. Implémenter la synchronisation des HS sur DEV avec conservation locale et idempotence.
4. Effectuer la recette hors ligne/en ligne et multi-appareils.
5. Concevoir séparément les délégations de chefs et le modèle de validation indépendante.
6. Ajouter les migrations et politiques RLS de validation uniquement après revue et tests de sécurité.
7. Ne préparer un passage en production qu'après recette complète et accord explicite.

### Limites

Ce document est une proposition technique préparatoire. Aucun schéma SQL, policy RLS, code applicatif ou donnée Supabase n'a été modifié par cette étude. Les choix métier et le schéma définitif restent à valider avant implémentation.

## Parcours unique et gestion des abonnements — décision produit validée le 16 novembre 2026

Le choix de la formule est réalisé sur le site internet Carnet HS. Le site constitue le point d'entrée commercial (présentation des offres, souscription et espace client) ; l'application mobile/web reste un outil unique utilisé par tous les abonnés.

### Principes validés

- Un seul compte Auth Supabase par utilisateur, quelle que soit la formule.
- L'utilisateur peut faire évoluer son abonnement depuis son espace client sur le site, sans recréer de compte.
- Le changement d'offre modifie les droits et les fonctionnalités disponibles, sans supprimer ni réinitialiser les données du compte : profil, missions, heures supplémentaires, validations et sauvegardes.
- L'application lit les droits associés au compte et adapte le parcours et les fonctions accessibles.
- Les autorisations doivent être contrôlées côté serveur. Le masquage d'un bouton ou d'un écran dans le navigateur n'est jamais une protection suffisante.
- Le site pilote la relation commerciale et l'abonnement ; l'application fournit les fonctions correspondant aux droits actifs.

### Architecture à définir avant implémentation

Prévoir un enregistrement d'abonnement rattaché à l'identifiant utilisateur Auth, avec au minimum l'offre, l'état de l'abonnement, les dates d'effet et les références nécessaires au fournisseur de paiement. Définir un mécanisme fiable pour mettre à jour les droits après souscription ou changement de formule, gérer les paiements échoués, résiliations et périodes de transition, et éviter qu'une notification de paiement falsifiée ou rejouée puisse accorder des droits.

Les changements de formule ne doivent pas provoquer de duplication de compte ni de migration destructive des données. Les transitions entre offres devront être testées avec conservation de l'historique et contrôle des droits avant/après changement.

**Statut :** principe fonctionnel validé le 16 novembre 2026. Le fournisseur de paiement, le schéma précis, les règles de facturation et le code ne sont pas encore choisis ou implémentés. Cette décision n'a entraîné aucune modification de l'application ni de Supabase. La production reste inchangée.


## Identifiant client central — prévention des essais multiples

Décision produit validée le 16 novembre 2026 : Carnet HS doit disposer d'un identifiant client central, indépendant de l'adresse e-mail. Les identifiants de connexion, les périodes d'essai et les abonnements seront rattachés à ce client central.

### Objectifs et séparation des concepts

- **Client** : identité commerciale centrale de la personne ou de l'organisation.
- **Compte(s) de connexion** : identifiants Auth permettant d'accéder au service ; l'adresse e-mail n'est pas l'identité commerciale à elle seule.
- **Essai** : droit temporaire attribué et historisé au niveau du client central, afin qu'une nouvelle adresse e-mail ne réinitialise pas automatiquement la période gratuite.
- **Abonnement** : formule et état de facturation rattachés au client central, tout en donnant accès au compte utilisateur autorisé.

### Garanties à concevoir

1. Un nouvel e-mail ne doit pas suffire à créer un nouvel essai gratuit pour le même client.
2. Le rattachement ou la fusion de comptes doit exiger une preuve de contrôle des comptes concernés et une procédure sûre ; ne jamais fusionner automatiquement sur la seule base d'un nom ou d'une adresse ressemblante.
3. La récupération d'accès et le changement de coordonnées doivent être prévus pour éviter de bloquer un client légitime.
4. Les décisions d'attribution d'essai et les changements d'abonnement doivent être journalisés côté serveur et protégés contre les répétitions ou notifications frauduleuses.
5. Collecter le minimum de données personnelles nécessaire, documenter finalités et durées de conservation, et prévoir les droits RGPD applicables.
6. Ne pas traiter l'empreinte d'un appareil comme preuve unique : appareils partagés, réinitialisés ou remplacés rendent cette méthode peu fiable et potentiellement intrusive.
7. Ne pas stocker les numéros complets de carte bancaire ni les codes de sécurité. Utiliser un prestataire de paiement et conserver uniquement les références/tokenisations nécessaires.

### Méthode de vérification — encore à arbitrer

Le téléphone vérifié et/ou une référence de moyen de paiement tokenisée peuvent être étudiés comme signaux supplémentaires, mais aucun ne doit être adopté sans évaluer les faux positifs, les cas de changement de numéro ou de moyen de paiement, l'accessibilité et la proportionnalité RGPD. L'adresse e-mail seule ne suffit pas à établir l'unicité d'un client.

### Statut

Le principe d'un identifiant client central indépendant de l'e-mail est validé. Le modèle de données, la méthode de vérification, les règles de rattachement de plusieurs comptes et la durée de l'essai restent à définir. Aucun code, schéma SQL, policy RLS ni paramètre Supabase n'a été modifié à la suite de cette décision. La production reste inchangée.


### Principe complémentaire validé — minimisation des données

Le 16 novembre 2026, l'utilisateur valide le principe de ne pas imposer une collecte excessive de données personnelles pour lutter contre les inscriptions multiples. La protection contre les abus doit rester proportionnée et ne pas compliquer inutilement l'inscription des clients légitimes.

En conséquence, la méthode de vérification concrète reste à arbitrer : téléphone vérifié, référence de moyen de paiement tokenisée ou combinaison de signaux. Le choix devra prendre en compte les faux positifs, les changements légitimes de coordonnées, l'accessibilité, la sécurité et les exigences RGPD. Cette validation porte sur le principe de minimisation, pas encore sur une méthode technique particulière.


## Ergonomie des champs mot de passe — icône œil (16 novembre 2026)

À la demande de l'utilisateur, les boutons texte « Afficher » ont été remplacés par une icône œil intégrée visuellement à droite du champ de saisie, sur le formulaire de connexion et le champ de confirmation à l'inscription.

- Un clic affiche le mot de passe et remplace l'icône par un œil barré ; un nouveau clic masque le mot de passe.
- Les attributs accessibles aria-label, aria-pressed et title sont mis à jour selon l'état.
- Commit DEV : 89b6474e5a8dc4dd0a89a604871d785dd7de6ad6.
- Aucun changement de logique d'authentification ni de stockage du mot de passe.
- Rendu sur appareils et test fonctionnel à confirmer par l'utilisateur.
- Production non modifiée.


### Vérification utilisateur — 16 novembre 2026

L'utilisateur confirme que la vérification demandée est OK. Le rendu et le comportement de l'icône œil ont été validés sur l'environnement testé. Aucun autre changement n'est signalé.


### Recette utilisateur — persistance du profil après reconnexion (16 novembre 2026)

L'utilisateur confirme avoir complété et enregistré son profil, effectué une déconnexion, puis s'être reconnecté avec le même compte. Toutes les informations du profil ont été retrouvées après reconnexion.

**Conclusion limitée au scénario testé :** la persistance du profil et de la mission principale dans Supabase, puis leur récupération après reconnexion sur le même compte, sont confirmées par ce test utilisateur.

**Tests restant à réaliser :** récupération sur un autre appareil/navigateur, isolation entre deux comptes distincts, tests d'accès non autorisé et gestion des erreurs réseau. Les HS, validations et événements d'audit restent hors de cette validation et leur synchronisation n'est pas encore confirmée.


## Recette utilisateur — récupération du profil sur téléphone Android (16 novembre 2026)

L'utilisateur confirme que le test sur son téléphone Android Oukitel WP55 Pro est concluant : en se connectant avec le même compte que sur son PC Windows 11, il retrouve correctement son profil et sa mission principale.

**Conclusion :** la récupération du profil et de la mission principale est confirmée sur les deux environnements testés (PC Windows 11 et téléphone Android Oukitel WP55 Pro). Ce résultat valide le scénario multi-appareils pour ces appareils et ce compte. Il ne valide pas l'isolation entre deux comptes distincts, les contrôles d'accès non autorisé, les erreurs réseau ni la synchronisation des HS, validations ou événements d'audit.

**Production :** aucune modification. **Code applicatif / Supabase :** aucune modification liée à cette recette ; seule la documentation DEV est mise à jour.


## Recette utilisateur — séparation fonctionnelle de deux comptes (16 novembre 2026)

L'utilisateur a effectué le test sur Carnet HS DEV avec deux comptes Auth distincts et deux adresses e-mail :

1. Connexion au deuxième compte (compte B) : un profil vierge est affiché, sans reprise des informations du compte A.
2. Retour au compte initial (compte A) : le profil original est correctement retrouvé.

**Résultat :** test fonctionnel utilisateur réussi pour la séparation et la conservation des profils entre ces deux comptes dans le parcours testé.

**Limite importante :** ce test d'interface ne constitue pas à lui seul une vérification exhaustive des politiques RLS. Les tests directs des droits de lecture/écriture table par table, des accès non autorisés et des tentatives de contournement avec deux sessions distinctes restent à effectuer avant de considérer la sécurité backend comme validée.

Aucun code applicatif, schéma SQL, policy RLS ou paramètre Supabase n'a été modifié à la suite de cette recette. La production reste inchangée.


## Contrôle SQL des droits et policies — 16 novembre 2026

L'utilisateur a exécuté dans Supabase SQL Editor la requête de contrôle en lecture seule portant sur les six tables du schéma public. La capture des résultats affiche :

| Table | RLS active | Nombre de policies | authenticated SELECT | anon SELECT |
|---|---:|---:|---:|---:|
| audit_events | true | 2 | true | false |
| missions | true | 4 | true | false |
| overtime_entries | true | 4 | true | false |
| profiles | true | 3 | true | false |
| sync_receipts | true | 2 | true | false |
| validations | true | 2 | true | false |

Le total est de 17 policies, avec la répartition attendue par la migration initiale. Le privilège SELECT est accordé au rôle authenticated et non accordé au rôle anon sur chacune des six tables.

**Interprétation :** ce résultat confirme la configuration générale affichée (RLS active, nombre de policies et privilèges SQL SELECT). Il ne prouve pas à lui seul que chaque expression USING / WITH CHECK fonctionne comme prévu, ni que les opérations de lecture, insertion, modification et suppression sont correctement isolées entre deux utilisateurs réels. Un contrôle de grants SELECT ne couvre pas non plus les autres privilèges SQL. Les tests backend sous deux sessions Auth distinctes restent donc indispensables.

**Périmètre de l'opération :** requête SELECT uniquement ; aucune donnée, table, policy, fonction ou configuration Supabase n'a été modifiée. Aucun changement de code applicatif. La production V3.4.1 reste inchangée.

### Étape suivante

Préparer des tests contrôlés avec deux comptes Auth distincts via des sessions authentifiées de l'application DEV ou un client de test utilisant les sessions de ces comptes. Vérifier au minimum que chaque compte ne peut lire ni modifier les lignes de l'autre, et que les refus ou résultats vides correspondent aux règles attendues. Ne pas utiliser le rôle SQL élevé du SQL Editor comme substitut à un utilisateur authentifié ; ne jamais exposer ni utiliser une clé service_role dans le navigateur.
