-- À exécuter en plus des schémas précédents.
-- Ajoute la relation (amis / famille / autre) à chaque invité, maintenant
-- ajouté personne par personne plutôt que par foyer.

alter table public.guests add column if not exists relation text;
