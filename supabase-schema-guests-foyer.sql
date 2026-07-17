-- À exécuter en plus des schémas précédents.
-- Ajoute le regroupement par foyer (ex. "Marie & Paul D." = 2 personnes),
-- le régime alimentaire et l'hébergement, pour se rapprocher de la maquette.

alter table public.guests add column if not exists foyer text;
alter table public.guests add column if not exists regime text;
alter table public.guests add column if not exists hebergement text;
