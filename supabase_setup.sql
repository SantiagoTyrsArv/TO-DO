-- Run this script in the Supabase SQL Editor to set up the tasks table.

create table if not exists tasks (
  id          uuid                     default gen_random_uuid() primary key,
  title       text                     not null,
  description text,
  category    text                     not null default 'General',
  due_date    timestamp with time zone,
  is_completed boolean                 not null default false,
  file_urls   text[]                   not null default '{}',
  created_at  timestamp with time zone not null default now()
);

-- Enable Row Level Security
alter table tasks enable row level security;

-- Public policy (open access — tighten with auth when ready)
create policy "Allow all access" on tasks
  for all
  using (true)
  with check (true);

-- ─── If you already have the table, run only this migration line: ──────────
-- alter table tasks add column if not exists file_urls text[] not null default '{}';

-- ─── Supabase Storage bucket (do this in Dashboard > Storage): ────────────
-- 1. Go to Storage → New bucket → Name: "task-files" → Toggle PUBLIC → Create
-- 2. That bucket will hold all task attachment files.
