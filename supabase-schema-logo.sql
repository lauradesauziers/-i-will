-- À exécuter en plus des schémas précédents.
-- Permet de personnaliser le logo affiché sur les pages d'un couple précis
-- (questionnaire, brief, budget, prestataires, plan de table). Si vide,
-- ces pages affichent simplement "I Will" en texte.

alter table public.briefs add column if not exists logo_url text;
