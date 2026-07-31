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
2. On 401, render the Login screen (from the UI kit's `Login.jsx`)
3. User clicks "Log in with EVE Online" → full-page navigation to EVE SSO URL
4. EVE OAuth → Rails `/login` callback → Rails sets session → Rails redirects to `/` (React root)
5. React mounts again → `GET /api/session` → 200 → renders app

---

## Phase 3: React App Structure

`app/frontend/components/` still needs (added as pages need them):

- [ ] Badge.tsx
- [ ] StatusDot.tsx
- [ ] Tag.tsx
- [ ] Table.tsx
- [ ] ProgressBar.tsx
- [ ] Stat.tsx
- [ ] Input.tsx
- [ ] Select.tsx
- [ ] Panel.tsx

---

## Phase 4: Page-by-page Migration

Implement in this order (simplest → most complex, Dashboard last since it's an overview of the other pages):

1. [x] **Login + auth gate** — `App.tsx` fetches `/api/session`, renders `Login.tsx` or `AppShell`
2. [x] **AppShell** — Sidebar (nav items, user avatar at bottom), TopBar (page title, wallet balance)
3. [ ] **Commodities** — single read-only table, good first real page
4. [ ] **IndustryJobs** — table with progress bars, status dots, activity badges
5. [ ] **MarketOrders** — table with filter toggle (sell/buy), market diff coloring
6. [ ] **PlanetaryColonies** — colony cards with expiry timers
7. [ ] **Settings** — character list, add/remove/reauth actions
8. [ ] **Dashboard** — still a one-line stub; quick overview pulling from all the pages above

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

- [ ] Delete any pre-migration Rails controllers/views no longer reachable from `config/routes.rb` (check each controller's actions against the route list, don't assume by name) — their JSON API equivalents already exist under `api/v1/`.
