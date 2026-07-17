import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const config = window.I_WILL_CONFIG;

if (!config || config.supabaseUrl.includes("xxxxxxxxxxxx")) {
  document.addEventListener("DOMContentLoaded", () => {
    const banner = document.createElement("div");
    banner.textContent =
      "Supabase n'est pas configuré : copie js/config.example.js en js/config.js et renseigne tes clés (voir README.md).";
    banner.style.cssText =
      "background:#b3432b;color:#fff;padding:12px 20px;text-align:center;font-size:14px;";
    document.body.prepend(banner);
  });
}

export const supabase = config
  ? createClient(config.supabaseUrl, config.supabaseAnonKey)
  : null;
