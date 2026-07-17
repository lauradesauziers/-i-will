-- À exécuter dans Supabase > SQL Editor (une seule fois), en plus de
-- supabase-schema.sql. Ceci ajoute le "brief vivant" partagé par lien secret,
-- en complément du questionnaire (table responses) déjà en place.

create table public.briefs (
  id uuid primary key default gen_random_uuid(),
  share_token uuid not null default gen_random_uuid() unique,
  couple_nom text,
  email text,
  telephone text,
  adresse text,
  date_mariage date,
  budget_estime text,
  nb_invites text,
  lieu_souhaite text,
  format text,
  type_ceremonie text,
  invites_dorment text,
  deja_reserve text,
  accompagnement text,
  implication text,
  aide jsonb default '[]'::jsonb,
  envies text,
  non_souhaite text,
  notes text,
  derniere_maj_par text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Verrouillage total : RLS activé, aucune policy => la clé anon ne peut
-- ni lire ni écrire la table directement, seulement via les 2 fonctions
-- ci-dessous (qui exigent de connaître le share_token).
alter table public.briefs enable row level security;

create or replace function public.get_brief(p_token uuid)
returns public.briefs
language sql security definer set search_path = public as $$
  select * from public.briefs where share_token = p_token;
$$;

create or replace function public.save_brief(p_token uuid, p_data jsonb, p_par text default 'couple')
returns public.briefs
language plpgsql security definer set search_path = public as $$
declare r public.briefs;
begin
  update public.briefs set
    couple_nom      = coalesce(p_data->>'couple_nom', couple_nom),
    email           = coalesce(p_data->>'email', email),
    telephone       = coalesce(p_data->>'telephone', telephone),
    adresse         = coalesce(p_data->>'adresse', adresse),
    date_mariage    = coalesce((p_data->>'date_mariage')::date, date_mariage),
    budget_estime   = coalesce(p_data->>'budget_estime', budget_estime),
    nb_invites      = coalesce(p_data->>'nb_invites', nb_invites),
    lieu_souhaite   = coalesce(p_data->>'lieu_souhaite', lieu_souhaite),
    format          = coalesce(p_data->>'format', format),
    type_ceremonie  = coalesce(p_data->>'type_ceremonie', type_ceremonie),
    invites_dorment = coalesce(p_data->>'invites_dorment', invites_dorment),
    deja_reserve    = coalesce(p_data->>'deja_reserve', deja_reserve),
    accompagnement  = coalesce(p_data->>'accompagnement', accompagnement),
    implication     = coalesce(p_data->>'implication', implication),
    aide            = coalesce(p_data->'aide', aide),
    envies          = coalesce(p_data->>'envies', envies),
    non_souhaite    = coalesce(p_data->>'non_souhaite', non_souhaite),
    notes           = coalesce(p_data->>'notes', notes),
    derniere_maj_par = p_par,
    updated_at = now()
  where share_token = p_token
  returning * into r;

  if not found then
    raise exception 'Brief introuvable pour ce lien';
  end if;
  return r;
end;
$$;

-- La clé anon ne peut appeler QUE ces 2 fonctions, rien d'autre sur la table.
grant execute on function public.get_brief(uuid) to anon;
grant execute on function public.save_brief(uuid, jsonb, text) to anon;
