# Tech Debt

---

## Frontend

- [ ] **Add zod validation at API boundaries** — API responses are currently trusted via `as` type assertions (e.g. `camelize(data) as Counters` in `useSidebarCounters`). Once page functionality is done, add zod: one schema per response type, derive the TS types via `z.infer`, and replace assertions with `Schema.parse()` so malformed responses throw instead of leaking `undefined` into state.

- [ ] **Sync ESI button has no in-flight state** — rapid clicks fire redundant `POST /api/sync` requests (harmless to ESI thanks to the backend 5-min cache guard) and give the user no feedback that a sync is running. Disable the button while the request is in flight.

- [ ] **`Login.tsx` conflates "not logged in" with "request failed"** — the `GET /api/session` handler only branches on `status === 200`; any other status (including a 500) falls into the same `else` as the expected `401` and just shows the login button with no explanation. Split into three branches — `200` redirect, `401` set `loginUrl`, else set an `error` state and render it — so an actual failure doesn't look like a silent, unexplained login prompt.

## Backend

- [ ] **`annotate` gem is broken on Ruby 3.3** — `annotate` 2.6.5 calls `File.exists?`, removed in Ruby 3.2+, so `bundle exec annotate` crashes and model schema headers must be updated by hand. Successor gem is `annotaterb`.

- [ ] **`User.find_or_register` does not handle bad OAuth code** — `app/models/user.rb:36`. If EVE SSO returns an invalid or expired `code`, `ESI.authenticate(code)` will raise or return an unexpected response, causing an unhandled exception in `Users::SessionsController#new`. Needs a rescue block that redirects the user back to the login screen with an error message.
