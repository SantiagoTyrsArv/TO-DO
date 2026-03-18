-- ─── 1. Crear la tabla de tareas (Tasks) ─────────────────────────────────

create table if not exists tasks (
  id            uuid                     default gen_random_uuid() primary key,
  -- Relacionamos la tarea con el usuario autenticado (OBLIGATORIO para RLS)
  user_id       uuid                     not null references auth.users(id) default auth.uid(),
  title         text                     not null,
  description   text,
  category      text                     not null default 'General',
  due_date      timestamp with time zone,
  is_completed  boolean                  not null default false,
  file_urls     text[]                   not null default '{}',
  created_at    timestamp with time zone not null default now()
);

-- Habilitar Row Level Security (RLS) en la tabla
alter table tasks enable row level security;


-- ─── 2. Políticas de Seguridad (RLS) para la tabla Tasks ─────────────────

-- Permitir a los usuarios ver solo sus propias tareas [web:1][web:11]
create policy "Usuarios pueden ver sus propias tareas"
  on tasks for select
  to authenticated
  using (auth.uid() = user_id);

-- Permitir a los usuarios crear sus propias tareas [web:13][web:14]
create policy "Usuarios pueden crear sus propias tareas"
  on tasks for insert
  to authenticated
  with check (auth.uid() = user_id);

-- Permitir a los usuarios actualizar solo sus propias tareas
create policy "Usuarios pueden actualizar sus propias tareas"
  on tasks for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Permitir a los usuarios eliminar solo sus propias tareas
create policy "Usuarios pueden eliminar sus propias tareas"
  on tasks for delete
  to authenticated
  using (auth.uid() = user_id);


-- ─── 3. Configuración de Supabase Storage ────────────────────────────────

-- Crear el bucket 'task-files'. Se configura como privado (public = false) 
-- para que no cualquiera en internet pueda acceder a las URLs estáticas sin permiso.
insert into storage.buckets (id, name, public)
values ('task-files', 'task-files', false)
on conflict (id) do update set public = false;


-- ─── 4. Políticas de Seguridad (RLS) para Storage ────────────────────────

-- OJO: Estas políticas asumen que subes los archivos desde Flutter en una 
-- ruta que empiece con el ID del usuario: `supabase.auth.currentUser!.id + '/archivo.png'`

-- Permitir a los usuarios autenticados subir archivos SOLO a su propia carpeta [web:15][web:19]
create policy "Usuarios pueden subir archivos a su propia carpeta"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'task-files' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

-- Permitir a los usuarios ver/descargar solo sus propios archivos [web:15][web:19]
create policy "Usuarios pueden leer archivos de su propia carpeta"
  on storage.objects for select
  to authenticated
  using (
    bucket_id = 'task-files' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

-- Permitir a los usuarios actualizar (sobrescribir) sus propios archivos
create policy "Usuarios pueden actualizar archivos de su propia carpeta"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'task-files' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

-- Permitir a los usuarios eliminar solo sus propios archivos
create policy "Usuarios pueden eliminar archivos de su propia carpeta"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'task-files' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );
