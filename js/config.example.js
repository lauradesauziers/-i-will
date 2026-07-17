// Copie ce fichier en "config.js" (même dossier) et remplace les valeurs
// ci-dessous par celles de TON projet Supabase :
// Supabase > Project Settings > API > Project URL / anon public key
//
// L'anon key n'est pas un secret classique : elle est faite pour être
// exposée côté client, tant que les policies RLS (voir supabase-schema.sql)
// restent en place. Ne mets JAMAIS la "service_role" key ici.

window.I_WILL_CONFIG = {
  supabaseUrl: "https://xxxxxxxxxxxx.supabase.co",
  supabaseAnonKey: "eyJhbGciOi...",
};
