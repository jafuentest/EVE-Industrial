# Migrate to React SPA + Apply EVE-Industrial Design System

## Context

The user wants two things done together: (1) migrate from Rails ERB views to a React SPA, and (2) apply the "New Eden Command Console" design system (claude.ai/design project `30b1e141-4efe-4eeb-adcf-c72f1e7b1f5b`). Doing both at once avoids double-reworking the ERB views.

The design system is React-native — every component ships `.jsx` + `.d.ts` files and the `ui_kits/eve-industrial/` shows full recreations of all four app pages. This makes a simultaneous migration the right call.

---

## Architecture: Rails API + Vite/React Frontend (same repo)

**Rails** keeps: models, ActiveRecord, EVE SSO OAuth flow, session auth, background jobs. Existing controllers are converted to JSON API endpoints under `api/v1/`.

**Vite** (`vite_rails` gem) runs alongside Rails. In dev, `bin/dev` starts both. In production, Vite builds to `public/vite-dist/` which Rails serves as static assets. Same origin = session cookies work with no CORS configuration.

**React** renders the full app shell (Sidebar + TopBar) and all four data pages, using the design system's React components directly.

**EVE SSO flow in SPA mode:**
1. React mounts → `GET /api/session` → 200 (user JSON) or 401 (not logged in)
2. On 401, render the Login screen
3. User clicks "Log in with EVE Online" → full-page navigation to EVE SSO URL
4. EVE OAuth → Rails `/login` callback → Rails sets session → Rails redirects to `/` (React root)
5. React mounts again → `GET /api/session` → 200 → renders app

---

## Phase 1: Vite + React Setup

### 1a. Add `vite_rails` gem and initialize

Add to `Gemfile`: `gem 'vite_rails'`

Run `bundle exec vite install` — this creates:
- `vite.config.mts`
- `app/frontend/entrypoints/application.tsx` (Vite entry)
- Updates `bin/dev` (Procfile.dev) to start Vite dev server alongside Rails

Remove `jsbundling-rails`, `cssbundling-rails`, `sass` npm packages from `package.json`. Remove the old `app/javascript/` and `app/assets/stylesheets/` build pipeline. Vite takes over all JS and CSS.

### 1b. Bring in React

Add to `package.json`:
- `react`, `react-dom`, `@types/react`, `@types/react-dom`
- `typescript`
- `@vitejs/plugin-react`
- `react-router-dom`, `@types/react-router-dom`

Use TypeScript (`.tsx`/`.ts`) throughout the React app. `vite.config.mts` and `tsconfig.json` are standard Vite+React+TS boilerplate.

### 1c. Import design system tokens

Copy the six token CSS files from the design system into `app/frontend/styles/theme/`:
- `fonts.css`, `colors.css`, `typography.css`, `spacing.css`, `effects.css`, `base.css`

Create `app/frontend/styles/app.css` that:
1. Imports all six token files
2. Adds app component styles (sidebar, topbar, table, buttons, badges — using design system tokens)

Import `app.css` from the Vite entry point.

Table sorting is handled by the design system's own `Table` component — no jQuery table plugin is part of this stack.

### 1d. Layout shell: Rails serves a single HTML root

Convert `layouts/application.html.erb` to a minimal HTML shell that:
- Loads the Vite entry JS
- Has `<div id="app"></div>` as the React mount point
- Includes the Google Fonts link (Chakra Petch · IBM Plex Sans · IBM Plex Mono)
- Pulls in Lucide icons via the `lucide-react` npm package

All subsequent routing is handled by React Router.

---

## Phase 2: Rails JSON API

Convert existing controllers to serve JSON. Add a new namespace `api/v1/`:

### API controllers

| Route | Controller | Returns |
|---|---|---|
| `GET /api/session` | `Api::V1::SessionsController#show` | user JSON (incl. `corporation_name`) or 401 |
| `DELETE /api/session` | `Api::V1::SessionsController#destroy` | logout, 200 |
| `GET /api/industry_jobs` | `Api::V1::IndustryJobsController#index` | jobs JSON, grouped by character |
| `POST /api/industry_jobs/update` | `Api::V1::IndustryJobsController#update` | triggers ESI sync |
| `GET /api/market_orders` | `Api::V1::MarketOrdersController#index` | orders JSON |
| `GET /api/planetary_colonies` | `Api::V1::PlanetaryColoniesController#index` | colonies JSON, grouped by character |
| `POST /api/planetary_colonies/update` | `Api::V1::PlanetaryColoniesController#update` | triggers ESI sync |
| `GET /api/planetary_commodities` | `Api::V1::PlanetaryCommoditiesController#index` | commodities JSON |
| `GET /api/planetary_commodities/:id` | `Api::V1::PlanetaryCommoditiesController#show` | single commodity JSON |
| `POST /api/planetary_commodities/update` | `Api::V1::PlanetaryCommoditiesController#update` | triggers price sync |
| `GET /api/characters` | `Api::V1::CharactersController#index` | user's characters |
| `DELETE /api/characters/:id` | `Api::V1::CharactersController#destroy` | removes character |

EVE SSO OAuth routes (`/login`, `/logout`) remain as full-page Rails endpoints (no API prefix) — they do page redirects, not JSON.

Remove the old `/settings` route and its Rails controller once `characters_controller` (`GET /api/characters`, `DELETE /api/characters/:id`) covers what the Settings page needs — no transitional JSON conversion needed for it.

Add an `Api::V1::BaseController` for auth (`before_action :require_authentication`, renders 401 JSON on failure); every `api/v1` controller inherits from it.

---

## Phase 3: React App Structure

```
app/frontend/
  entrypoints/
    application.tsx        ← Vite entry; imports app.css, renders <App />
  styles/
    theme/                 ← design system token CSS files (6)
    app.css                ← imports tokens + component styles
  components/              ← reusable primitives, used inside pages
    Brand.tsx, Button.tsx, ButtonIcon.tsx, ProfileImage.tsx
    Badge.tsx, StatusDot.tsx, Tag.tsx, Table.tsx, ProgressBar.tsx, Stat.tsx, Input.tsx, Select.tsx, Panel.tsx
  layouts/                 ← AppShell-only scaffolding, never used inside a page
    AppShell.tsx, Sidebar.tsx, NavItem.tsx, TopBar.tsx, UserDetails.tsx
  contexts/
    AuthContext.tsx
  pages/
    Login.tsx, Dashboard.tsx, IndustryJobs.tsx, MarketOrders.tsx, PlanetaryColonies.tsx, Commodities.tsx, Settings.tsx
  App.tsx                  ← root: session check, router, AppShell
```

`ProfileImage` covers what the design system calls `Avatar` — a narrow EVE-character-portrait component rather than a generic image container. Add a general `Avatar` primitive only if something beyond character portraits needs it (e.g. corporation logos on Settings).

Components get added as pages need them, not all upfront.

---

## Phase 4: Page-by-page Migration

Implement in this order (simplest → most complex, Dashboard last since it's an overview of the other pages):

1. **Login + auth gate** — `App.tsx` fetches `/api/session`, renders `Login.tsx` or `AppShell`
2. **AppShell** — Sidebar (nav items, user avatar at bottom), TopBar (page title, wallet balance)
3. **Commodities** — single read-only table, good first real page
4. **IndustryJobs** — table with progress bars, status dots, activity badges
5. **MarketOrders** — table with filter toggle (sell/buy), market diff coloring
6. **PlanetaryColonies** — colony cards with expiry timers
7. **Settings** — character list, add/remove/reauth actions
8. **Dashboard** — quick overview pulling from all the pages above

---

## Verification

1. `bin/dev` starts cleanly (Rails + Vite dev server)
2. Visiting `/` renders the Login screen with dark EVE design
3. Clicking EVE SSO link → auth flow → lands back at app dashboard
4. Each page loads real data from the API
5. Table sorting works (`Table.tsx` needs its own sort implementation decided when it's built)
6. `bundle exec rspec` — existing model/controller tests still pass
7. Character add/remove/reauth flows work from Settings page

---

## Cleanup

Delete any pre-migration Rails controllers/views no longer reachable from `config/routes.rb` (check each controller's actions against the route list, don't assume by name) — their JSON API equivalents already exist under `api/v1/`.
