-- ============================================================
-- Web de revisión del Sidur Maguén David — esquema Supabase
-- Pegar completo en: Dashboard -> SQL Editor -> Run
-- ANTES de correrlo: cambia el correo de ADMIN_EMAIL (línea 12)
-- ============================================================

-- ---------- perfiles (nombre visible + bandera de administrador)
create table if not exists perfiles (
  id uuid primary key references auth.users on delete cascade,
  nombre text not null default '',
  admin boolean not null default false
);

-- crea el perfil automáticamente al crear cada usuario;
-- el usuario cuyo correo coincida aquí queda como administrador:
create or replace function crear_perfil() returns trigger
language plpgsql security definer as $$
begin
  insert into perfiles (id, nombre, admin)
  values (new.id,
          coalesce(new.raw_user_meta_data->>'nombre', split_part(new.email,'@',1)),
          new.email = 'ADMIN_EMAIL')   -- <== PON AQUÍ TU CORREO, entre comillas
  on conflict (id) do nothing;
  return new;
end $$;
drop trigger if exists tg_crear_perfil on auth.users;
create trigger tg_crear_perfil after insert on auth.users
  for each row execute function crear_perfil();

create or replace function es_admin() returns boolean
language sql stable security definer as
$$ select coalesce((select admin from perfiles where id = auth.uid()), false) $$;

-- ---------- marcas del revisor (una por referencia: bloque, línea o página)
create table if not exists marcas (
  ref text primary key,          -- 'B:<id de bloque>' | 'L:<pag>.<linea>' | 'P:<pag>'
  estado text not null check (estado in ('aprobado','corregido','error')),
  nota text not null default '',
  corr jsonb not null default '[]',   -- [{i, de, a, grupo}]
  por uuid not null default auth.uid(),
  por_nombre text not null default '',
  ts timestamptz not null default now()
);

-- ---------- secciones liberadas
create table if not exists secciones (
  sec text primary key,
  estado text not null default 'liberada',
  por uuid not null default auth.uid(),
  por_nombre text not null default '',
  ts timestamptz not null default now()
);

-- ---------- seguridad (RLS): solo usuarios autenticados; borrar = dueño de la
-- marca o administrador; reabrir sección (borrar) = solo administrador
alter table perfiles  enable row level security;
alter table marcas    enable row level security;
alter table secciones enable row level security;

create policy perfiles_leer    on perfiles  for select to authenticated using (true);
create policy perfiles_propio  on perfiles  for update to authenticated using (id = auth.uid());

create policy marcas_leer      on marcas    for select to authenticated using (true);
create policy marcas_escribir  on marcas    for insert to authenticated with check (por = auth.uid());
create policy marcas_actualizar on marcas   for update to authenticated using (true) with check (por = auth.uid());
create policy marcas_borrar    on marcas    for delete to authenticated
  using (por = auth.uid() or es_admin());

create policy secciones_leer   on secciones for select to authenticated using (true);
create policy secciones_crear  on secciones for insert to authenticated with check (por = auth.uid());
create policy secciones_borrar on secciones for delete to authenticated using (es_admin());

-- ---------- storage: lectura solo autenticada de los buckets privados
-- (los buckets 'datos' y 'paginas' los crea herramientas/subir_supabase.py)
create policy storage_leer on storage.objects for select to authenticated
  using (bucket_id in ('datos','paginas'));

-- ============================================================
-- Después de correr esto:
-- 1) Authentication -> Sign In / Up:  DESACTIVA "Allow new users to sign up".
-- 2) Authentication -> Users -> Add user: crea tu usuario (el del correo de
--    arriba) y el de cada revisor (correo + contraseña). En "User Metadata"
--    puedes poner {"nombre": "Rab Fulano Levy"}.
-- ============================================================
