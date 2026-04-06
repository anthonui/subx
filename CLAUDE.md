# CLAUDE.md — SUBX

Guide de référence pour la conception de toutes les pages de l'application SUBX.
À lire avant de créer ou modifier quoi que ce soit.

---

## Présentation du projet

**SUBX** est une plateforme française de découverte et réservation d'événements sportifs hybrides (Hyrox, OCR, Functional Fitness…).

**Stack :** HTML/CSS/JS vanilla — zéro framework, zéro bundler. Chaque page est un fichier `.html` autonome avec tout le CSS inline dans `<style>` et tout le JS dans `<script>` en bas de `<body>`.

**Backend :** Supabase (Auth + PostgreSQL + Edge Functions)

---

## Structure des fichiers

```
SUBX/
├── index.html           — Page publique (landing + liste événements + tiroir panier)
├── event.html           — Détail événement (public, fond blanc, modal tickets, tiroir panier, avatar navbar)
├── profil.html          — Dashboard athlète (authentifié, affiche registrations)
├── organisateur.html    — Dashboard organisateur (authentifié, rôle organizer, gère ticket_type)
├── admin.html           — Backoffice admin (authentifié, rôle admin)
├── dashboard_athlete/   — Assets dashboard athlète
├── supabase/
│   ├── migrations/
│   │   ├── 20260331_init_subx.sql               — Schéma initial (profiles, organizers, event)
│   │   ├── 20260406_registrations.sql            — Table registrations + RLS
│   │   ├── 20260406_ticket_type_public_read.sql  — Table ticket_type + RLS public
│   │   └── 20260406_security_perf_fixes.sql      — Index perf + triggers anti-fraude + RLS correctifs
│   └── functions/       — Edge Functions Deno
├── logo_subx.svg        — Logo blanc (sur fond sombre)
├── logo_subx_dark.svg   — Logo sombre (sur fond clair)
└── dashboard_bg.webp    — Image de fond hero
```

---

## Design System

### Palette de couleurs

```css
:root {
  --green:       #7CB928;   /* Couleur principale — CTA, accents, actifs */
  --green-dark:  #5A8A1E;   /* Hover du vert */
  --green-light: #9BD43E;   /* Vert clair, rarement utilisé */
  --black:       #1A1A1A;   /* Fond principal (pages sombres) */
  --dark:        #2A2A2A;   /* Sidebar, cartes secondaires */
  --card:        #222222;   /* Fond des cartes dans les dashboards */
  --border: rgba(255,255,255,0.07); /* Bordures subtiles sur fond sombre */
  --gray:        #F5F5F5;   /* Fond clair (page event.html) */
  --white:       #FFFFFF;
}
```

> **Règle d'or :** tout élément interactif actif ou important utilise `--green`. Ne pas utiliser d'autres couleurs d'accent sans raison.

### Typographie

| Police | Usage | CDN |
|--------|-------|-----|
| **Oswald** (400–700) | Titres, chiffres stats, labels nav, wordmark | Google Fonts |
| **Montserrat** (300–700) | Corps, boutons, labels, tout le reste | Google Fonts |

```html
<!-- Toujours inclure ces deux polices dans chaque nouvelle page -->
<link href="https://fonts.googleapis.com/css2?family=Montserrat:ital,wght@0,300;0,400;0,500;0,600;0,700;1,400;1,500&family=Oswald:wght@400;500;600;700&display=swap" rel="stylesheet">
```

### Espacements & bordures

- **border-radius cartes :** `12px` à `14px`
- **border-radius boutons pill :** `50px`
- **border-radius boutons normaux :** `6px` à `10px`
- **Gap entre éléments :** multiples de `4px` (8, 12, 16, 20, 24, 32)
- **Padding sections :** `32px`
- **Container max-width :** `1200px` (pages publiques), `1100px` (admin)

---

## Layouts

### Layout A — Page publique (index.html, event.html)

- **Navbar sticky** en haut (`height: 64px`, fond semi-transparent + `backdrop-filter: blur(10px)`)
- **Container centré** `max-width: 1200px`
- Fond : `--black` (index) ou `--white` (event)
- Navbar toujours sur fond `rgba(26,26,26,0.95)` — même sur fond blanc

### Layout B — Dashboard (profil.html, organisateur.html)

- **Sidebar fixe** à gauche (`width: 240px` via `--sidebar-w`)
- **Main content** avec `margin-left: var(--sidebar-w)`
- **Topbar sticky** dans le main (`backdrop-filter: blur(12px)`)
- Fond général : `--black`
- Navigation par sections avec `.page` (display:none) / `.page.active` (display:block)

### Layout C — Admin (admin.html)

- Pas de sidebar — topbar simple sticky `height: 64px`
- `max-width: 1100px` centré
- Fond : `#1A1A1A` avec `--card: #2A2A2A`

---

## Composants récurrents

### Navbar publique

```html
<nav class="navbar">
  <div class="container">
    <!-- Logo SVG + liens + boutons connexion/profil -->
  </div>
</nav>
```
- Logo : `<img src="logo_subx.svg">` hauteur `32px`
- Liens hover : `color: var(--green)`
- Bouton secondaire : `.btn-outline` (bordure verte, fond transparent → vert au hover)

### Sidebar dashboard

Structure fixe :
1. `.sidebar-logo` — logo + badge rôle (organisateur/admin)
2. `.sidebar-nav` — nav items avec `.nav-item` / `.nav-item.active`
3. `.sidebar-footer` — avatar utilisateur + bouton déconnexion

Nav item actif : `background: rgba(124,185,40,0.15); color: var(--green)`

### Boutons

```css
/* Primaire */
.btn-primary { background: var(--green); color: #fff; }
.btn-primary:hover { background: var(--green-dark); transform: translateY(-1px); }

/* Outline */
.btn-outline { border: 1px solid rgba(255,255,255,0.15); color: rgba(255,255,255,0.7); }
.btn-outline:hover { border-color: var(--green); color: var(--green); }

/* Danger */
.btn-danger { background: rgba(229,57,53,0.15); color: #E57373; border: 1px solid rgba(229,57,53,0.2); }

/* Style commun */
.btn { border-radius: 50px; font-family: 'Montserrat'; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; }
```

### Badges de statut

```css
/* Toujours ce pattern : bg semi-transparent + bordure colorée */
.badge-pending  { background: rgba(255,140,0,0.15);  color: #FF8C00; border: 1px solid rgba(255,140,0,0.3); }
.badge-approved { background: rgba(124,185,40,0.15); color: var(--green); border: 1px solid rgba(124,185,40,0.3); }
.badge-rejected { background: rgba(229,57,53,0.15);  color: #E53935; border: 1px solid rgba(229,57,53,0.3); }
/* border-radius: 20px; padding: 3-4px 10-12px; font-size: 11px; font-weight: 600-700; text-transform: uppercase */
```

### Cartes

```css
.card {
  background: var(--card); /* #222 */
  border: 1px solid var(--border); /* rgba(255,255,255,0.07) */
  border-radius: 14px;
  transition: border-color 0.2s;
}
.card:hover { border-color: rgba(255,255,255,0.15); }
```

### Stats cards

- Valeur : **Oswald** `2rem` font-weight `600`
- Label : `0.72rem` uppercase `letter-spacing: 0.06em` couleur `rgba(255,255,255,0.45)`
- Icône optionnelle en haut à droite : `36px` carré, `border-radius: 10px`, fond vert transparent

### Toast notifications

Toujours en bas à droite, position fixed. Pattern :
```css
.toast { background: var(--card); border-radius: 10px; border-left: 4px solid [couleur]; }
.toast.success { border-left-color: var(--green); }
.toast.error   { border-left-color: var(--red); }
/* Animation: fade in depuis le bas, auto-disparition 3.5s */
```

### Tiroir panier (cart drawer)

Présent dans `event.html` et `index.html`. S'ouvre au clic sur l'icône panier navbar.
- HTML : `<div class="cart-drawer-overlay" id="cartDrawerOverlay">` contenant `<div class="cart-drawer">`
- Fonctions JS : `openCartDrawer()`, `closeCartDrawer()`, `renderCartDrawer()`, `removeFromCart(eventId, ticketId)`
- Données : localStorage clé `subx_cart` — tableau d'objets `{ eventId, eventName, eventDate, eventCity, ticketId, ticketName, levels, price, qty }`
- Badge : `.cart-badge` injecté dynamiquement dans `.navbar-icon[aria-label="Panier"]` via `updateCartBadge()`

### Avatar utilisateur navbar (pages publiques)

Présent dans `event.html`. Fonction `initNavbarAuth()` appelée au `DOMContentLoaded`.
- Non connecté → icône SVG user grise (`#navbarProfileBtn`)
- Connecté → `.navbar-avatar` (cercle vert avec initiales ou photo) remplace l'icône
- Clic → `window.location.href = 'profil.html'`
- Récupère `full_name` et `avatar_url` depuis `profiles`

### Modal inscription tickets (event.html)

- HTML : `#inscriptionOverlay` > `#inscriptionModal`
- Ouverture : `openModal(eventData)` — vérifie l'auth Supabase avant d'ouvrir
- Tickets : chargés depuis `ticket_type` via `window._subxTickets` (priorité) ou fallback sur `e.formats`/`e.prices`
- Stepper quantité : `changeQty(ticketId, delta)` — max 10
- Paiement : `payNow()` → INSERT dans `registrations` avec `ticket_type_id` — le trigger serveur valide le prix
- Non connecté → toast erreur + redirect `index.html#auth`

### Auth Guard / Overlay de chargement

```html
<div id="authGuard"> <!-- ou #auth-overlay -->
  <div class="spinner"></div>
  <p>Vérification…</p>
</div>
```
```css
.spinner { border: 4px solid var(--border); border-top-color: var(--green); border-radius: 50%; animation: spin 0.8s linear infinite; }
```
- Affiché au chargement, masqué une fois l'auth vérifiée
- Redirige vers `index.html` si non authentifié ou rôle insuffisant

---

## Supabase — Intégration

### Initialisation (toujours en haut du `<script>`)

```js
const SUPABASE_URL  = 'https://ipuryomreqlrhhutjnkq.supabase.co';
const SUPABASE_ANON = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
const sb = supabase.createClient(SUPABASE_URL, SUPABASE_ANON);
```

```html
<!-- CDN à inclure dans chaque page qui utilise Supabase -->
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
```

### Tables principales connues

| Table | Description |
|-------|-------------|
| `profiles` | Profils utilisateurs (`id`, `full_name`, `avatar_url`, `is_organizer`, `role`, `email`, `city`, `phone`, `preferred_discipline`) |
| `organizers` | Données organisation (`user_id`, `org_name`, `website`, `phone`, `description`) |
| `event` | Événements (`id`, `organizer_id`, `name`, `race_type`, `level[]`, `date`, `city`, `address`, `formats[]`, `prices JSONB`, `price_from`, `image_url`, `published`) |
| `ticket_type` | Tickets créés par l'organisateur (`id`, `event_id`, `format`, `level`, `price`, `max_spots`) — **source de vérité des prix** |
| `registrations` | Inscriptions athlètes (`id`, `athlete_id`, `event_id`, `ticket_type_id`, `ticket_id`, `ticket_name`, `qty`, `unit_price`, `total_price`, `status`, `payment_ref`) |

### Énumérations SQL

| Type | Valeurs |
|------|---------|
| `race_type_enum` | `hybride`, `fonctionnel`, `obstacle`, `autre` |
| `level_enum` | `debutant`, `intermediaire`, `expert`, `elite` |
| `format_enum` | `solo`, `duo`, `equipe`, `relais` |
| `user_role_enum` | `athlete`, `organizer` |
| `registration_status_enum` | `pending`, `confirmed`, `cancelled` |

### RLS — Règles importantes

- `profiles` : lecture par tout utilisateur authentifié, écriture uniquement sur son propre profil
- `event` : lecture publique si `published = TRUE`, écriture uniquement par l'organisateur propriétaire
- `ticket_type` : lecture publique si l'event est publié, écriture uniquement par l'organisateur
- `registrations` : lecture par l'athlète (ses propres) + organisateur (ses events), INSERT par l'athlète, UPDATE uniquement pour passer en `cancelled`

### Triggers serveur critiques

| Trigger | Table | Rôle |
|---------|-------|------|
| `registrations_check_price` | `registrations` | Vérifie que `unit_price` = prix réel du `ticket_type` — **anti-fraude** |
| `registrations_check_availability` | `registrations` | Vérifie les places restantes avant insertion |
| `registrations_updated_at` | `registrations` | Met à jour `updated_at` automatiquement |
| `event_updated_at` | `event` | Met à jour `updated_at` automatiquement |

### Pattern Auth Guard

```js
async function initAuth() {
  const { data: { user } } = await sb.auth.getUser();
  if (!user) { window.location.replace('index.html'); return; }

  // Pour les pages avec rôle requis :
  const { data: profile } = await sb.from('profiles').select('role').eq('id', user.id).single();
  if (!profile || profile.role !== 'admin') { window.location.replace('index.html'); return; }

  // Masquer l'overlay et afficher la page
  document.getElementById('authGuard').style.display = 'none';
  document.querySelector('.layout').classList.add('ready');
}
```

### Helper sécurité (XSS)

Toujours utiliser cette fonction avant d'injecter du contenu utilisateur dans le DOM :
```js
function escHtml(str) {
  if (!str) return '';
  return String(str)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;')
    .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}
```

---

## Responsive

- **Mobile :** `max-width: 640px` — masquer la sidebar (burger menu), réduire paddings
- **Tablette :** `max-width: 768px` — grilles → 1 colonne
- Les dashboards avec sidebar utilisent un overlay mobile + toggle JS
- La navbar publique a un `.hamburger` + `.mobile-menu` (display:none → display:block avec `.active`)

---

## Règles de création d'une nouvelle page

1. **Copier le bloc `:root`** exact depuis une page existante — ne pas réinventer les variables
2. **Inclure les 2 polices** Google Fonts (Montserrat + Oswald)
3. **Inclure le CDN Supabase** si la page nécessite l'auth ou des données
4. **Choisir le bon layout** (A, B ou C) et le reproduire fidèlement
5. **Auth guard en premier** — la page ne s'affiche qu'après vérification
6. **Toujours `escHtml()`** sur tout contenu venant de la base de données
7. **Toutes les transitions** : `0.2s ease` ou `0.3s ease` — pas d'animations complexes
8. **Police Oswald** pour les titres, chiffres, labels importants — Montserrat pour tout le reste
9. **Vert `#7CB928`** pour tout ce qui est actif, validé, CTA principal
10. **Pas de dépendances externes** sauf : Google Fonts, Supabase JS, Leaflet (cartes si besoin)

---

## Librairies externes autorisées

| Lib | Usage | CDN |
|-----|-------|-----|
| Supabase JS v2 | Auth + BDD | `cdn.jsdelivr.net/npm/@supabase/supabase-js@2` |
| Leaflet 1.9.4 | Cartes interactives | `unpkg.com/leaflet@1.9.4` |
| Google Fonts | Montserrat + Oswald | `fonts.googleapis.com` |

Aucune autre lib ne doit être ajoutée sans discussion.

---

<!-- VERCEL BEST PRACTICES START -->
## Bonnes pratiques Vercel (référence)

- Traiter les Vercel Functions comme sans état et éphémères ; utiliser Blob ou les intégrations marketplace pour persister l'état
- Ne pas démarrer de nouveaux projets sur Vercel KV/Postgres (abandonnés) ; utiliser Redis/Postgres via le Marketplace
- Stocker les secrets dans les Variables d'Environnement Vercel ; pas dans git ni dans `NEXT_PUBLIC_*`
- Utiliser `waitUntil` pour les traitements post-réponse
- Utiliser les Cron Jobs pour les tâches planifiées (UTC, HTTP GET sur l'URL de production)
- Utiliser Vercel Blob pour les uploads/médias
<!-- VERCEL BEST PRACTICES END -->
