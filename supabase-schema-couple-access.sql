-- À exécuter dans Supabase > SQL Editor, en plus des schémas précédents.
-- Donne au couple (via son lien secret, sans compte) un accès à une partie
-- de ce que voit la planner : budget en lecture, prestataires validés en
-- lecture, et plan de table en modification. Tout le reste (tâches internes,
-- prestataires en négociation, échanges) reste réservé à la planner.
--
-- Principe : chaque fonction reçoit le token du couple, retrouve son
-- brief_id en interne, et n'agit jamais que sur les lignes de CE couple.
-- Aucune table n'est ouverte directement à "anon" — uniquement ces fonctions.

-- Budget, lecture seule
create or replace function public.get_couple_budget(p_token uuid)
returns setof public.budget_items
language sql security definer set search_path = public as $$
  select bi.* from public.budget_items bi
  join public.briefs b on b.id = bi.brief_id
  where b.share_token = p_token
  order by bi.created_at asc;
$$;

-- Prestataires validés uniquement (pas le pipeline en cours de négociation)
create or replace function public.get_couple_vendors(p_token uuid)
returns setof public.vendors
language sql security definer set search_path = public as $$
  select v.* from public.vendors v
  join public.briefs b on b.id = v.brief_id
  where b.share_token = p_token and v.statut = 'valide'
  order by v.categorie asc;
$$;

-- Invités, lecture (nécessaire pour afficher le plan de table)
create or replace function public.get_couple_guests(p_token uuid)
returns setof public.guests
language sql security definer set search_path = public as $$
  select g.* from public.guests g
  join public.briefs b on b.id = g.brief_id
  where b.share_token = p_token
  order by g.nom asc;
$$;

-- Tables, lecture
create or replace function public.get_couple_tables(p_token uuid)
returns setof public.seating_tables
language sql security definer set search_path = public as $$
  select t.* from public.seating_tables t
  join public.briefs b on b.id = t.brief_id
  where b.share_token = p_token
  order by t.created_at asc;
$$;

-- Déplacer un invité vers une table (ou vers "non assigné" si p_table_id est null)
create or replace function public.assign_couple_guest_table(p_token uuid, p_guest_id uuid, p_table_id uuid)
returns public.guests
language plpgsql security definer set search_path = public as $$
declare
  v_brief_id uuid;
  r public.guests;
begin
  select id into v_brief_id from public.briefs where share_token = p_token;
  if v_brief_id is null then
    raise exception 'Lien invalide';
  end if;

  if p_table_id is not null and not exists (
    select 1 from public.seating_tables where id = p_table_id and brief_id = v_brief_id
  ) then
    raise exception 'Table introuvable pour ce couple';
  end if;

  update public.guests set table_id = p_table_id
  where id = p_guest_id and brief_id = v_brief_id
  returning * into r;

  if not found then
    raise exception 'Invité introuvable pour ce couple';
  end if;
  return r;
end;
$$;

-- Ajouter une table
create or replace function public.add_couple_table(p_token uuid, p_nom text, p_capacite int)
returns public.seating_tables
language plpgsql security definer set search_path = public as $$
declare
  v_brief_id uuid;
  r public.seating_tables;
begin
  select id into v_brief_id from public.briefs where share_token = p_token;
  if v_brief_id is null then
    raise exception 'Lien invalide';
  end if;

  insert into public.seating_tables (brief_id, nom, capacite)
  values (v_brief_id, coalesce(p_nom, 'Nouvelle table'), coalesce(p_capacite, 8))
  returning * into r;
  return r;
end;
$$;

grant execute on function public.get_couple_budget(uuid) to anon;
grant execute on function public.get_couple_vendors(uuid) to anon;
grant execute on function public.get_couple_guests(uuid) to anon;
grant execute on function public.get_couple_tables(uuid) to anon;
grant execute on function public.assign_couple_guest_table(uuid, uuid, uuid) to anon;
grant execute on function public.add_couple_table(uuid, text, int) to anon;
