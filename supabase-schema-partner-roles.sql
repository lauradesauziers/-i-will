-- À exécuter en plus des schémas précédents.
-- Libellé affiché sous chaque prénom dans le pied de la sidebar planner
-- (ex. "Future mariée" / "Futur marié"). Optionnel : si non renseigné,
-- l'app affiche "Couple" par défaut. partner1 = premier prénom de
-- couple_nom, partner2 = second (ordre du champ "Cécile & Wilfried").

alter table public.briefs add column if not exists partner1_role text;
alter table public.briefs add column if not exists partner2_role text;

update public.briefs
set partner1_role = 'Future mariée', partner2_role = 'Futur marié'
where couple_nom = 'Cécile & Wilfried';
