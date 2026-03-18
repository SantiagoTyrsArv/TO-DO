create table if not exists tasks (
id uuid default gen_random_uuid() primary key,
user_id uuid references auth.users(id),
title text not null,
description text,
category text not null default 'General',
due_date timestamp with time zone,
is_completed boolean not null default false,
file_urls text[] not null default '{}',
created_at timestamp with time zone not null default now()
);

alter table tasks enable row level security;

alter table tasks alter column user_id drop not null;
alter table tasks alter column user_id set default null;

create policy "public_tasks_all" on tasks for all to anon using (true) with check (true);

insert into storage.buckets (id, name, public) values ('task-files', 'task-files', true) on conflict (id) do update set public = true;

create policy "public_storage_insert" on storage.objects for insert to anon with check (bucket_id = 'task-files');
create policy "public_storage_select" on storage.objects for select to public using (bucket_id = 'task-files');
create policy "public_storage_delete" on storage.objects for delete to public using (bucket_id = 'task-files');
