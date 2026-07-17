import { supabase } from "./supabase-client.js";

const storedTheme = localStorage.getItem("i-will-theme");
if (storedTheme) document.documentElement.setAttribute("data-theme", storedTheme);

function toggleTheme() {
  const current = document.documentElement.getAttribute("data-theme");
  const next = current === "dark" ? "light" : "dark";
  document.documentElement.setAttribute("data-theme", next);
  localStorage.setItem("i-will-theme", next);
}

const NAV_ITEMS = [
  { href: "dashboard.html", label: "Accueil", icon: "⌂" },
  { href: "budget.html", label: "Budget", icon: "€" },
  { href: "prestataires.html", label: "Prestataires", icon: "◇" },
  { href: "taches.html", label: "Tâches", icon: "☑" },
  { href: "retroplanning.html", label: "Rétroplanning", icon: "▤" },
  { href: "plan-de-table.html", label: "Plan de table", icon: "◫" },
  { href: "invites.html", label: "Invités", icon: "◍" },
  { href: "echanges.html", label: "Échanges", icon: "✉" },
];

export function coupleIdFromUrl() {
  return new URLSearchParams(location.search).get("couple");
}

export function withCouple(href) {
  const id = coupleIdFromUrl();
  return id ? `${href}?couple=${id}` : href;
}

export async function requireSession() {
  const { data: { session } } = await supabase.auth.getSession();
  if (!session) {
    location.href = "dashboard.html";
    return null;
  }
  return session;
}

export async function renderNav(activeHref) {
  const coupleId = coupleIdFromUrl();
  const mount = document.getElementById("app-nav");
  if (!mount) return;

  let coupleLabel = "";
  let shareToken = "";
  let weddingDate = "";
  let counts = {};

  if (coupleId) {
    const { data } = await supabase
      .from("briefs")
      .select("couple_nom, share_token, date_mariage")
      .eq("id", coupleId)
      .maybeSingle();
    coupleLabel = data?.couple_nom || "";
    shareToken = data?.share_token || "";
    weddingDate = data?.date_mariage || "";

    const [{ count: vendorsCount }, { count: tasksCount }, { count: messagesCount }] = await Promise.all([
      supabase.from("vendors").select("id", { count: "exact", head: true }).eq("brief_id", coupleId),
      supabase.from("tasks").select("id", { count: "exact", head: true }).eq("brief_id", coupleId).eq("done", false),
      supabase.from("messages").select("id", { count: "exact", head: true }).eq("brief_id", coupleId),
    ]);
    counts = {
      "prestataires.html": vendorsCount || 0,
      "taches.html": tasksCount || 0,
      "echanges.html": messagesCount || 0,
    };
  }

  const items = NAV_ITEMS.map((item) => {
    const href = coupleId ? `${item.href}?couple=${coupleId}` : "dashboard.html";
    const disabled = !coupleId && item.href !== "dashboard.html";
    const cls = ["nav-link"];
    if (item.href === activeHref) cls.push("active");
    if (disabled) cls.push("disabled");
    const count = counts[item.href];
    const badge = count ? `<span class="nav-badge">${count}</span>` : "";
    return `<a class="${cls.join(" ")}" href="${disabled ? "#" : href}">
      <span class="nav-icon">${item.icon}</span>${item.label}${badge}
    </a>`;
  }).join("");

  const briefLink = shareToken
    ? `<a class="nav-link" href="brief.html?t=${shareToken}" target="_blank" rel="noopener">
        <span class="nav-icon">✎</span>Le brief
      </a>`
    : `<a class="nav-link disabled" href="#"><span class="nav-icon">✎</span>Le brief</a>`;

  const names = coupleLabel.split(/&| et /i).map((s) => s.trim()).filter(Boolean);
  const footerPeople = coupleId
    ? `
      ${names.map((n) => `
        <div class="person">
          <span class="avatar avatar-blue">${escapeHtml(n[0] || "?")}</span>
          <span><span class="name">${escapeHtml(n)}</span><span class="role">Couple</span></span>
        </div>
      `).join("")}
      <div class="person">
        <span class="avatar avatar-gold">L</span>
        <span><span class="name">Laura</span><span class="role">Wedding planner</span></span>
      </div>
    `
    : "";

  mount.innerHTML = `
    <div class="nav-brand">I Will</div>
    ${coupleLabel ? `<div class="nav-couple">${escapeHtml(coupleLabel)}</div>` : ""}
    <nav class="nav-links">${items}${briefLink}</nav>
    ${footerPeople ? `<div class="nav-footer">${footerPeople}</div>` : ""}
    <button class="theme-toggle" id="theme-toggle" type="button">◐ Thème</button>
    <a href="#" class="nav-logout" id="nav-logout">Se déconnecter</a>
  `;

  document.getElementById("nav-logout").addEventListener("click", async (e) => {
    e.preventDefault();
    await supabase.auth.signOut();
    location.href = "dashboard.html";
  });

  document.getElementById("theme-toggle").addEventListener("click", toggleTheme);

  const topbar = document.getElementById("page-topbar");
  if (topbar && coupleId) {
    let countdown = "";
    if (weddingDate) {
      const days = Math.ceil((new Date(weddingDate) - new Date()) / 86400000);
      const months = Math.round(days / 30.4);
      countdown = `
        <div class="countdown">
          <div class="jday">J${days >= 0 ? "-" + days : " passé"}</div>
          ${days >= 0 ? `<div class="sub">DANS ~${months} MOIS</div>` : ""}
        </div>
      `;
    }
    topbar.innerHTML = `
      <span class="couple-name">${escapeHtml(coupleLabel)}</span>
      <div class="topbar-right">
        ${countdown}
        <span class="sync-badge">Synchronisé</span>
      </div>
    `;
  }
}

function escapeHtml(str) {
  const div = document.createElement("div");
  div.textContent = str;
  return div.innerHTML;
}
