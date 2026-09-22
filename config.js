// Configuración del proyecto Supabase (Dashboard -> Settings -> API).
// La "anon key" es pública por diseño: la seguridad la ponen las reglas RLS
// y el login. La service_role key JAMÁS va aquí.
window.CONFIG = {
  SUPABASE_URL: "",       // p. ej. "https://abcdefgh.supabase.co"
  SUPABASE_ANON_KEY: ""   // la anon/public key
};
