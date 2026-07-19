-- À exécuter en plus des schémas précédents.
-- Accès complet du couple à sa propre plateforme, avec une vraie connexion
-- email + mot de passe — SANS créer de compte Supabase Auth pour eux.
--
-- Pourquoi pas un vrai compte "authenticated" : toutes les policies
-- existantes ("planner_full_access_...") disent "authenticated peut tout
-- faire", sans distinction de couple. Un compte authenticated pour le
-- couple verrait alors TOUS les couples de la plateforme, pas juste le
-- sien. À la place : mot de passe vérifié côté serveur (haché avec
-- pgcrypto), qui débloque leur token secret existant — le même mécanisme
-- que le lien, juste avec un écran de connexion devant.

create extension if not exists pgcrypto;

alter table public.briefs add column if not exists login_email text;
alter table public.briefs add column if not exists password_hash text;

-- Appelée par la planner (authenticated) pour définir/changer l'accès du couple.
create or replace function public.set_couple_credentials(p_brief_id uuid, p_email text, p_password text)
returns void
language plpgsql security definer set search_path = public as $$
begin
  update public.briefs
  set login_email = lower(trim(p_email)),
      password_hash = crypt(p_password, gen_salt('bf'))
  where id = p_brief_id;

  if not found then
    raise exception 'Couple introuvable';
  end if;
end;
$$;
grant execute on function public.set_couple_credentials(uuid, text, text) to authenticated;

-- Appelée par le couple depuis l'écran de connexion. Renvoie le share_token
-- existant si email + mot de passe correspondent, sinon null.
create or replace function public.couple_login(p_email text, p_password text)
returns uuid
language plpgsql security definer set search_path = public as $$
declare
  r public.briefs;
begin
  select * into r from public.briefs
  where login_email = lower(trim(p_email))
  limit 1;

  if not found or r.password_hash is null then
    return null;
  end if;

  if r.password_hash = crypt(p_password, r.password_hash) then
    return r.share_token;
  end if;

  return null;
end;
$$;
grant execute on function public.couple_login(text, text) to anon;

-- Tâches : lecture complète (les leurs + celles de la planner), écriture
-- uniquement sur "done" et uniquement pour leurs propres tâches.
create or replace function public.get_couple_tasks(p_token uuid)
returns setof public.tasks
language sql security definer set search_path = public as $$
  select t.* from public.tasks t
  join public.briefs b on b.id = t.brief_id
  where b.share_token = p_token
  order by t.due_date asc nulls last;
$$;
grant execute on function public.get_couple_tasks(uuid) to anon;

create or replace function public.couple_toggle_task(p_token uuid, p_task_id uuid, p_done boolean)
returns public.tasks
language plpgsql security definer set search_path = public as $$
declare
  v_brief_id uuid;
  r public.tasks;
begin
  select id into v_brief_id from public.briefs where share_token = p_token;
  if v_brief_id is null then
    raise exception 'Lien invalide';
  end if;

  update public.tasks set done = p_done
  where id = p_task_id and brief_id = v_brief_id and assignee = 'couple'
  returning * into r;

  if not found then
    raise exception 'Tâche introuvable ou non modifiable';
  end if;
  return r;
end;
$$;
grant execute on function public.couple_toggle_task(uuid, uuid, boolean) to anon;

-- Prestataires : lecture complète, tous statuts (contrairement à
-- get_couple_vendors qui ne renvoie que les validés). Toujours lecture
-- seule : pas d'ajout ni de suppression côté couple.
create or replace function public.get_couple_vendors_full(p_token uuid)
returns setof public.vendors
language sql security definer set search_path = public as $$
  select v.* from public.vendors v
  join public.briefs b on b.id = v.brief_id
  where b.share_token = p_token
  order by v.categorie asc;
$$;
grant execute on function public.get_couple_vendors_full(uuid) to anon;

-- Échanges : lecture + écriture (auteur forcé à 'couple', impossible à usurper).
create or replace function public.get_couple_messages(p_token uuid)
returns setof public.messages
language sql security definer set search_path = public as $$
  select m.* from public.messages m
  join public.briefs b on b.id = m.brief_id
  where b.share_token = p_token
  order by m.created_at asc;
$$;
grant execute on function public.get_couple_messages(uuid) to anon;

create or replace function public.send_couple_message(p_token uuid, p_contenu text)
returns public.messages
language plpgsql security definer set search_path = public as $$
declare
  v_brief_id uuid;
  r public.messages;
begin
  select id into v_brief_id from public.briefs where share_token = p_token;
  if v_brief_id is null then
    raise exception 'Lien invalide';
  end if;

  insert into public.messages (brief_id, auteur, contenu)
  values (v_brief_id, 'couple', p_contenu)
  returning * into r;
  return r;
end;
$$;
grant execute on function public.send_couple_message(uuid, text) to anon;
