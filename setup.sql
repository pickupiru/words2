-- Swedish Word Trainer Cloud - Supabase setup
-- Run this once in Supabase: SQL Editor -> New query -> Run

create extension if not exists pgcrypto;

create table if not exists public.word_lists (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null check (char_length(name) between 1 and 80),
  words jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint word_lists_user_name_unique unique (user_id, name),
  constraint words_must_be_array check (jsonb_typeof(words) = 'array')
);

alter table public.word_lists enable row level security;

drop policy if exists "Users can read own word lists" on public.word_lists;
create policy "Users can read own word lists"
on public.word_lists for select
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "Users can insert own word lists" on public.word_lists;
create policy "Users can insert own word lists"
on public.word_lists for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists "Users can update own word lists" on public.word_lists;
create policy "Users can update own word lists"
on public.word_lists for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists "Users can delete own word lists" on public.word_lists;
create policy "Users can delete own word lists"
on public.word_lists for delete
to authenticated
using ((select auth.uid()) = user_id);

grant select, insert, update, delete on table public.word_lists to authenticated;
