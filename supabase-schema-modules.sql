-- À exécuter dans Supabase > SQL Editor, en plus de supabase-schema.sql
-- et supabase-schema-briefs.sql. Ajoute les modules du dashboard planner :
-- budget, prestataires, tâches, plan de table, invités, échanges.
--
-- Principe d'accès : ces tables sont pilotées uniquement par toi (Laura),
-- connectée sur dashboard.html. Le couple n'y a pas accès direct (il garde
-- le questionnaire + son brief). D'où : RLS activé, policies réservées au
-- rôle "authenticated" (= toi une fois connectée), rien pour "anon".

-- Correctif : "briefs" n'avait aucune policy, donc même toi (connectée) ne
-- pouvais pas le lire directement hors de Table Editor. On l'ouvre à
-- "authenticated" pour que ton dashboard puisse lister/éditer les couples.
create policy "planner_full_access_briefs"
on public.briefs for all
to authenticated
using (true) with check (true);

create table public.budget_items (
  id uuid primary key default gen_random_uuid(),
  brief_id uuid not null references public.briefs(id) on delete cascade,
  categorie text not null,
  prestataire text,
  montant_prevu numeric,
  montant_engage numeric default 0,
  montant_paye numeric default 0,
  notes text,
  created_at timestamptz default now()
);
alter table public.budget_items enable row level security;
create policy "planner_full_access_budget_items"
on public.budget_items for all to authenticated using (true) with check (true);

create table public.vendors (
  id uuid primary key default gen_random_uuid(),
  brief_id uuid not null references public.briefs(id) on delete cascade,
  nom text not null,
  categorie text,
  statut text not null default 'a_contacter'
    check (statut in ('a_contacter', 'devis', 'coup_de_coeur', 'valide')),
  contact_email text,
  contact_tel text,
  prix text,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
alter table public.vendors enable row level security;
create policy "planner_full_access_vendors"
on public.vendors for all to authenticated using (true) with check (true);

create table public.tasks (
  id uuid primary key default gen_random_uuid(),
  brief_id uuid not null references public.briefs(id) on delete cascade,
  titre text not null,
  description text,
  assignee text not null default 'laura' check (assignee in ('laura', 'couple')),
  due_date date,
  done boolean not null default false,
  created_at timestamptz default now()
);
alter table public.tasks enable row level security;
create policy "planner_full_access_tasks"
on public.tasks for all to authenticated using (true) with check (true);

create table public.seating_tables (
  id uuid primary key default gen_random_uuid(),
  brief_id uuid not null references public.briefs(id) on delete cascade,
  nom text not null,
  capacite integer not null default 8,
  created_at timestamptz default now()
);
alter table public.seating_tables enable row level security;
create policy "planner_full_access_seating_tables"
on public.seating_tables for all to authenticated using (true) with check (true);

create table public.guests (
  id uuid primary key default gen_random_uuid(),
  brief_id uuid not null references public.briefs(id) on delete cascade,
  nom text not null,
  groupe text,
  rsvp_status text not null default 'en_attente'
    check (rsvp_status in ('en_attente', 'oui', 'non')),
  table_id uuid references public.seating_tables(id) on delete set null,
  notes text,
  created_at timestamptz default now()
);
alter table public.guests enable row level security;
create policy "planner_full_access_guests"
on public.guests for all to authenticated using (true) with check (true);

create table public.messages (
  id uuid primary key default gen_random_uuid(),
  brief_id uuid not null references public.briefs(id) on delete cascade,
  auteur text not null default 'laura' check (auteur in ('laura', 'couple')),
  contenu text not null,
  created_at timestamptz default now()
);
alter table public.messages enable row level security;
create policy "planner_full_access_messages"
on public.messages for all to authenticated using (true) with check (true);
