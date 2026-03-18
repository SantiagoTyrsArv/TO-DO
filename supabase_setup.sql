-- Run this script in the Supabase SQL Editor to set up the tasks table.

create table if not exists tasks (
  id          uuid                     default gen_random_uuid() primary key,
  title       text                     not null,
  description text,
  category    text                     not null default 'General',
  due_date    timestamp with time zone,
  is_completed boolean                 not null default false,
  created_at  timestamp with time zone not null default now()
);

-- Enable Row Level Security
alter table tasks enable row level security;

-- Public policy (open access — tighten with auth when ready)
create policy "Allow all access" on tasks
  for all
  using (true)
  with check (true);
