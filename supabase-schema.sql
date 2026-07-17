-- À exécuter dans Supabase > SQL Editor (une seule fois)

create table if not exists public.responses (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  couple_names text not null,
  wedding_date date,
  contact_email text not null,
  contact_phone text,
  guest_count_estimate text,
  vision_style text,
  must_haves text,
  must_avoid text,
  involvement_level text,
  support_wanted text,
  budget_range text,
  additional_notes text
);

alter table public.responses enable row level security;

-- N'importe quel couple peut envoyer ses réponses (formulaire public)
create policy "Anyone can submit a response"
on public.responses for insert
to anon
with check (true);

-- Seule une personne connectée (toi, via l'espace planner) peut lire les réponses
create policy "Only authenticated planners can read responses"
on public.responses for select
to authenticated
using (true);
