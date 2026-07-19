-- À exécuter en plus des schémas précédents.
-- Ajoute le budget de départ fixé par la planner, à partir duquel
-- le "reste disponible" est calculé (budget_global - total des postes prévus).

alter table public.briefs add column if not exists budget_global numeric;
