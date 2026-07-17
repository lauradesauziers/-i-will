# I Will

Questionnaire mariage + espace planner, en HTML/CSS/JS pur (pas de build,
pas de Node nécessaire). Le client Supabase est chargé via CDN (esm.sh).

## Structure

- `questionnaire.html` — formulaire public pour les couples
- `dashboard.html` — espace privé pour toi (login + liste des réponses)
- `js/supabase-client.js` — connexion Supabase, lit `js/config.js`
- `js/config.example.js` — modèle de config à copier
- `supabase-schema.sql` — table + règles de sécurité à exécuter une fois
- `css/style.css` — charte (bleu marine / or / crème)

## Mise en place (10 minutes)

1. Crée un compte sur [supabase.com](https://supabase.com) et un nouveau
   projet (gratuit).
2. Dans **SQL Editor**, colle et exécute le contenu de `supabase-schema.sql`.
3. Dans **Authentication > Users**, crée ton propre utilisateur (ton email +
   un mot de passe) — c'est ce compte qui te servira à te connecter sur
   `dashboard.html`.
4. Dans **Project Settings > API**, copie l'URL du projet et la clé
   `anon public`.
5. Copie `js/config.example.js` en `js/config.js` et colle-y ces deux
   valeurs.
6. Ouvre `questionnaire.html` dans un navigateur (ou héberge le dossier —
   voir plus bas) pour tester l'envoi, puis `dashboard.html` pour te
   connecter et voir la réponse apparaître.

`config.js` n'est volontairement pas fourni : ne le commite jamais tel
quel dans un dépôt public si tu changes un jour de clé ou de projet.

## Sécurité

- La clé `anon` est faite pour être publique côté client — la vraie
  protection vient des règles RLS dans `supabase-schema.sql` : n'importe
  qui peut *envoyer* une réponse, mais seule une personne connectée (toi)
  peut les *lire*.
- Ne mets jamais la clé `service_role` dans ce dossier.

## Héberger

Aucun build requis. Tu peux déposer le dossier tel quel sur Netlify Drop,
Vercel, GitHub Pages, ou n'importe quel hébergement statique.

## Et après ?

Cette première version couvre le formulaire + la lecture des réponses.
Les modules suivants (budget, prestataires en kanban, plan de table,
messagerie) sont à construire un par un — voir la maquette pour la
direction visuelle et fonctionnelle.
