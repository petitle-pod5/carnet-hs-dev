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
