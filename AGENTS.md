# Instructions persistantes pour les agents — Carnet HS DEV

## Références de suivi

- Utiliser `SUIVI_PROJET_CARNET_HS_DEV.md` comme tableau de bord et registre des décisions, tâches, statuts et points en attente.
- Utiliser `documentation/SECURITE_ET_ARCHITECTURE_SUPABASE.md` pour les impacts techniques, le modèle de données, l'authentification et la sécurité.
- Après chaque décision explicitement validée par l'utilisateur, mettre à jour le tableau de bord. Mettre aussi à jour le mémo technique lorsqu'elle a un impact technique. Garder la date, le statut, le périmètre et les questions non résolues visibles.
- Ne jamais transformer une proposition, une question ou une hypothèse en décision validée. Garder les éléments en attente dans leurs sections de suivi.

## Vérification et traçabilité

- Lire les fichiers existants et leurs instructions avant de les modifier ; préserver leur contenu et leur historique.
- Ne marquer un test comme réalisé/réussi que si son résultat a été effectivement observé. Distinguer code ajouté, test effectué et résultat confirmé.
- Consigner les commits, tests et publications seulement lorsqu'ils existent et sont vérifiés. Ne pas prétendre qu'une mise à jour documentaire a été publiée si elle est seulement préparée.

## Git et périmètre

- Travailler uniquement sur le dépôt DEV `petitle-pod5/carnet-hs-dev` pour le code et ses documents techniques, et sur le dépôt interne autorisé pour ses documents de suivi.
- Ne jamais modifier le dépôt de production `petitle-pod5/carnet-hs`, ses paramètres ou son déploiement sans autorisation explicite distincte.
- Préparer les changements sur une branche dédiée et ouvrir une PR brouillon pour revue. Ne pas fusionner ni publier sans validation appropriée.
- Pour réduire les manipulations, tenir les décisions validées à jour dans les fichiers Markdown DEV au fil de l'eau. Consolider les documents Word/Excel internes en lot aux jalons convenus, conserver les versions remplacées et mettre à jour l'index.
