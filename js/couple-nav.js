export function coupleTokenFromUrl() {
  return new URLSearchParams(location.search).get("t");
}

const TABS = [
  { href: "brief.html", label: "Mon brief" },
  { href: "budget-couple.html", label: "Budget" },
  { href: "prestataires-couple.html", label: "Prestataires" },
  { href: "plan-de-table-couple.html", label: "Plan de table" },
];

export function renderCoupleTabs(activeHref) {
  const mount = document.getElementById("couple-tabs");
  if (!mount) return;
  const token = coupleTokenFromUrl();

  mount.innerHTML = TABS.map((tab) => {
    const cls = tab.href === activeHref ? "couple-tab active" : "couple-tab";
    return `<a class="${cls}" href="${tab.href}?t=${token || ""}">${tab.label}</a>`;
  }).join("");
}

// Affiche le logo personnalisé du couple s'il existe, sinon "I Will" en texte.
// Appelle get_brief (déjà accessible à anon) — un aller-retour de plus,
// négligeable, et évite de dupliquer cette logique dans chaque page.
export async function renderCoupleLogo(supabase, token) {
  const mount = document.getElementById("couple-logo");
  if (!mount || !token) return;

  const { data } = await supabase.rpc("get_brief", { p_token: token });
  if (data?.logo_url) {
    mount.innerHTML = `<img src="${data.logo_url}" alt="${data.couple_nom || "I Will"}" style="height:64px; width:auto; display:block;" />`;
  } else {
    mount.innerHTML = `<p class="logo" style="margin:0;">I Will</p>`;
  }
}
