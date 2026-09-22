# Web de revisión — Sidur Maguén David

Herramienta de cotejo rabínico del texto extraído del sidur (5.ª ed., 2018).

**Arquitectura de seguridad:** este repositorio (y GitHub Pages) contiene SOLO el
cascarón de la aplicación — ni una letra del sidur ni imágenes del libro. Todo el
contenido y las marcas de revisión viven en Supabase: texto e imágenes en buckets
**privados** (solo usuarios autenticados), marcas en Postgres con RLS, y login con
usuarios creados por el administrador (sin registro abierto).

## Puesta en marcha (una sola vez)

1. **Supabase** (gratis): crear cuenta en supabase.com → New project.
2. **Esquema**: abrir `supabase/esquema.sql`, poner tu correo en la línea de
   `ADMIN_EMAIL`, pegarlo en *SQL Editor* → Run.
3. **Cerrar el registro**: *Authentication → Sign In / Up* → desactivar
   "Allow new users to sign up".
4. **Usuarios**: *Authentication → Users → Add user* — crea tu usuario (correo del
   paso 2) y uno por revisor (correo + contraseña). En *User Metadata* puede ir
   `{"nombre": "Rab Fulano Levy"}`.
5. **Contenido** (desde la carpeta del proyecto del sidur, en tu máquina):
   ```
   python herramientas/preparar_datos_web.py
   set SUPABASE_URL=https://TUPROYECTO.supabase.co
   set SUPABASE_SERVICE_KEY=...   (Settings -> API -> service_role; solo local)
   python herramientas/subir_supabase.py
   ```
6. **config.js**: poner `SUPABASE_URL` y la **anon key** (Settings → API).
7. **GitHub Pages**: subir este repo a GitHub (público) → Settings → Pages →
   Deploy from branch `main` / root. La web queda en
   `https://<usuario>.github.io/<repo>/`.

## Qué puede hacer el revisor

- Shajarit por **bloques** litúrgicos; el resto del MVP por **página** del libro.
- Ver la **imagen original** de cada página (con zoom) para cotejar.
- **Aprobar**, **corregir palabra por palabra** o **marcar dudas** con nota.
- Al corregir una palabra, aplicar la corrección a **todos los lugares del sidur
  donde aparece idéntica** (mismo nikud y teamim) de una sola vez.
- **Liberar secciones** completas. Todo queda firmado (nombre + cuenta).
- Reabrir secciones o borrar marcas ajenas: solo el administrador.

Las marcas se leen después con `herramientas/` para integrarlas a
`datos/correcciones.json` con registro para el Rabinato.
