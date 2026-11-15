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
