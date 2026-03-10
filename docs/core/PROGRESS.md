# Core Feature Progress

## Status: Phase 12 - Completed

## Quick Reference
- Research: `docs/core/RESEARCH.md`
- Implementation: `docs/core/IMPLEMENTATION.md`

---

## Phase Progress

### Phase 1: Database Migrations
**Status:** Completed

#### Tasks Completed
- Added `bcrypt` gem to Gemfile, ran `bundle install`
- Created migration for `organizations` table (UUID PK, all fields, unique indexes on slug/email, GIN indexes on industries/causes)
- Created migration for `users` table (UUID PK, all fields, unique indexes on email/username, GIN indexes on interested_causes/interested_industries)
- Created migration for `events` table (UUID PK, organization FK, all fields, GIN index on hashtags)
- Created migration for `attendances` table (UUID PK, user/event FKs, unique compound index)
- Created migration for `follows` table (UUID PK, user/organization FKs, unique compound index)
- Ran `bin/rails db:migrate` — all 5 migrations applied successfully
- Verified `db/schema.rb` — all tables, columns, indexes, and foreign keys correct

#### Decisions Made
- GIN indexes on all 5 array columns (industries, causes, interested_causes, interested_industries, hashtags)
- dress_code is nullable integer with no default (nil = not specified)
- status has default: 0, null: false (every event must have a status)

#### Blockers
- (none)

---

### Phase 2: Models & Validations
**Status:** Completed

#### Tasks Completed
- Created `Organization` model with `has_secure_password`, associations, validations, and slug auto-generation (with collision handling)
- Created `User` model with `has_secure_password`, associations, and validations
- Created `Event` model with `belongs_to :organization`, enums (dress_code, status), `published` and `upcoming` scopes, validations
- Created `Attendance` model with belongs_to associations and uniqueness validation
- Created `Follow` model with belongs_to associations and uniqueness validation
- Created `Current` model (`ActiveSupport::CurrentAttributes`) with user and organization attributes
- Created fixtures: 2 organizations, 2 users, 3 events (published upcoming, published past, draft), 2 attendances, 2 follows
- Created model tests: 35 tests, 92 assertions, all passing
- Rubocop clean on all new files

#### Decisions Made
- Slug generation uses `before_validation` on create, parameterizes name, appends counter on collision
- `upcoming` scope uses Ruby range syntax `where(date: Date.current..)`
- Fixtures use Rails auto-generated deterministic UUIDs (no explicit IDs)

#### Blockers
- (none)

---

### Phase 3: Authentication Concern & Current
**Status:** Completed

#### Tasks Completed
- Created `Authentication` concern with dual auth support (user + organization sessions)
- Implemented `set_current_auth`, `authenticate!`, `authenticate_user!`, `authenticate_organization!`, `signed_in?`, `current_user`, `current_organization`, `sign_in_user`, `sign_in_organization`, `sign_out`
- Included `Authentication` in `ApplicationController`
- Wired up `inertia_share` in `InertiaController` to share current_user and current_organization props
- Created integration test for unauthenticated requests plus regression coverage for switching auth contexts
- All 40 tests passing, rubocop clean

#### Decisions Made
- `before_action :set_current_auth` and `helper_method` declarations live in concern's `included` block
- `sign_in_*` methods call `reset_session` first to prevent session fixation
- `sign_out` calls `Current.reset` to clear thread-local attributes
- All auth redirects go to `root_path` for now (no login page yet)
- Inertia shared data exposes minimal user/org fields (id, name fields, email, username/slug)

#### Blockers
- (none)

---

### Phase 4: Auth Controllers & Routes
**Status:** Completed

#### Tasks Completed
- Created `Users::SessionsController` (new, create, destroy) — sign in/out for users
- Created `Users::RegistrationsController` (new, create) — sign up for users
- Created `Organizations::SessionsController` (new, create, destroy) — sign in/out for orgs
- Created `Organizations::RegistrationsController` (new, create) — sign up for orgs
- Added namespaced routes for all auth endpoints (users/sign_in, users/sign_up, users/sign_out, organizations/sign_in, organizations/sign_up, organizations/sign_out)
- Created controller tests: 18 tests, 70 assertions, all passing
- Rubocop clean on all new files

#### Decisions Made
- Controllers inherit from `InertiaController` (not `ApplicationController` directly)
- Failed sign-in uses redirect with Inertia errors (not re-render) for cleaner URL handling
- Failed registration also redirects back with Inertia errors
- Used `params.expect` (Rails 8 style) instead of `params.require.permit` per rubocop
- Inertia page names: `Users/Sessions/New`, `Users/Registrations/New`, `Organizations/Sessions/New`, `Organizations/Registrations/New`

#### Blockers
- (none)

---

### Phase 5: Auth Frontend Pages
**Status:** Completed

#### Tasks Completed
- Created `app/frontend/pages/Users/Sessions/New.tsx` — user sign in (email + password), error display, links to sign up and org sign in
- Created `app/frontend/pages/Users/Registrations/New.tsx` — user sign up (first_name, last_name, email, username, password, password_confirmation), inline field errors
- Created `app/frontend/pages/Organizations/Sessions/New.tsx` — org sign in (email + password), error display, links to sign up and user sign in
- Created `app/frontend/pages/Organizations/Registrations/New.tsx` — org sign up (name, email, password, password_confirmation), inline field errors
- All pages use ShadCN Card/Input/Label/Button, Inertia `useForm`, centered card layout
- TypeScript compiles cleanly (`npm run check`)
- All 58 tests pass (170 assertions)
- All four pages verified rendering and form submission via agent-browser

#### Decisions Made
- Session errors use `usePage().props.errors` with `Record<string, string>` type (since `errors.base` isn't part of form data shape)
- Registration forms keep flat client-side field keys, then transform payloads to `user` / `organization` on submit so `useForm` error keys match Rails model errors
- Consistent centered card design matching existing home page pattern
- Links between user/org auth forms for easy switching

#### Blockers
- (none)

---

### Phase 6: TypeScript Types & Shared Props
**Status:** Completed

#### Tasks Completed
- Updated `app/frontend/types/index.ts` with full entity types: User, Organization, Event, EventListItem, Attendance, Follow
- Updated FlashData to include `success` field
- Added SharedProps type with currentUser, currentOrganization, and flash
- Added flash sharing to `InertiaController` via `inertia_share`
- TypeScript compiles cleanly (`npm run check`)
- All 58 tests pass (170 assertions)

#### Decisions Made
- `starting_ticket_price` typed as `string | null` (Rails decimals serialize as strings in JSON)
- `dress_code` typed as `string | null` (Rails enums serialize as string names)
- `Event.status` uses union type `'draft' | 'published'` for type safety
- Flash shares `:notice`, `:alert`, and `:success` keys

#### Blockers
- (none)

---

### Phase 7: Layout Component & Navigation
**Status:** Completed

#### Tasks Completed
- Installed ShadCN `switch` and `tabs` components for later phases
- Created `app/frontend/components/Layout.tsx` with conditional nav for 3 auth states (anonymous, user, org)
- Wired default layout in `app/frontend/entrypoints/inertia.tsx` using `page.default.layout ||=`
- Added layout opt-out to all 4 auth pages via `Component.layout = (page) => page`
- Updated home page to remove redundant `min-h-screen`/`bg-background` wrapper
- Fixed SharedProps type keys to match Rails snake_case (`current_user`, `current_organization`)
- Flash message banners (success/alert/notice) rendered below nav
- All 58 tests pass (170 assertions), TypeScript clean
- Verified all 3 nav states + auth page layout opt-out in browser

#### Decisions Made
- SharedProps keys use snake_case to match Rails `as_json` output (`current_user` not `currentUser`)
- Layout destructures with rename: `const { current_user: currentUser } = usePage<SharedProps>().props`
- Sign out uses `router.delete()` for proper DELETE request
- DropdownMenuItem uses `asChild` with Inertia `Link` for client-side navigation
- Avatar fallback: user initials (first+last), org first letter
- Flash banners are simple colored divs (green/red/blue) below nav, no auto-dismiss

#### Blockers
- (none)

---

### Phase 8: Homepage Controller & Event Filtering
**Status:** Completed

#### Tasks Completed
- Updated `HomeController#index` with base query `Event.published.upcoming.includes(:organization)` ordered by date ASC
- Added server-side filtering: text search (q), city (ILIKE), state (exact), month (EXTRACT), price range (min/max), cause (ANY on org causes array), industry (ANY on org industries array)
- Serialized events as EventListItem shape (id, title, date, venue_name, city, state, starting_ticket_price, dress_code, status, organization: {name, slug})
- Passed filter params, causes list, and industries list to frontend
- Created 15 controller tests (62 assertions) covering: published/upcoming filtering, draft/past exclusion, all 8 filter types, empty results, filter param passthrough, causes/industries dropdown data, serialization shape
- Rubocop clean, all 72 tests passing (231 assertions)

#### Decisions Made
- Extracted filtering into private methods (`apply_text_filters`, `apply_location_filters`, `apply_date_and_price_filters`, `apply_month_filter`, `apply_organization_filters`) to satisfy rubocop complexity cops
- Used Rails range syntax for price filters (`where(starting_ticket_price: min..)`) per rubocop
- Causes/industries lists built via `Organization.pluck(:causes).flatten.uniq.sort` — no new scopes needed
- Inertia test helper parses `<script data-page="app">` JSON from HTML response (no X-Inertia header needed)
- Added rubocop config: `Metrics/ClassLength` excluded for test files, `Minitest/MultipleAssertions` max raised to 12

#### Blockers
- (none)

---

### Phase 9: Homepage Frontend
**Status:** Completed

#### Tasks Completed
- Rebuilt `app/frontend/pages/home/index.tsx` with full homepage UI
- Filter bar: text search, cause select, industry select, month select, city/state inputs, price range inputs, Search + Clear buttons
- Filters submit as GET params via `router.get('/', params, { preserveState: true })`
- Event card grid (3-col lg, 2-col md, 1-col sm) using ShadCN Card
- Cards show: title, org name (linked to `/o/slug`), formatted date, venue/city/state, price, dress code badge
- Each card links to `/events/:id`
- Empty state with "No events found" and "Clear filters" button when no matches
- Enter key submits filters from text inputs
- TypeScript compiles cleanly, all 72 tests pass (231 assertions)
- Verified rendering in browser: filter bar, event card, links all correct

#### Decisions Made
- Search button approach (not auto-submit) to avoid server round-trips per keystroke
- ShadCN Select uses `"all"` sentinel for "no selection" (empty string not supported), stripped before submitting
- Filter state managed with `useState` initialized from `filters` prop (not `useForm`, which is for POST forms)
- Date formatted with `toLocaleDateString('en-US', ...)` with `T00:00:00` suffix to avoid timezone offset issues
- Price formatted as "From $X" / "Free" / "Price TBD"
- Dress code label: underscores replaced with spaces, title-cased
- Card hover uses `hover:border-foreground/20` for subtle interaction feedback
- Org name link inside card uses `stopPropagation` to prevent card navigation

#### Blockers
- (none)

---

### Phase 10: Event Detail Page
**Status:** Completed

#### Tasks Completed
- Created `EventsController#show` with full event serialization, org serialization, attendee count, and is_attending flag
- Added `rescue_from ActiveRecord::RecordNotFound` that redirects to root with alert flash
- Draft visibility: only owning organization can see drafts, everyone else gets redirected
- Added route `get '/events/:id', to: 'events#show', as: :event`
- Added `DetailOrganization` TypeScript type for expanded org shape
- Created `app/frontend/pages/events/show.tsx` with two-column layout (main + sidebar card)
- Left column: banner placeholder, title, org link, description, hashtag badges
- Right column: date, time range, venue/address, dress code badge, price, purchase tickets button, auction/gift badges, attendee count, disabled RSVP + follow placeholders
- Wrote 10 controller tests (47 assertions): published/draft visibility, attendee count, is_attending, non-existent event
- All 82 tests passing (278 assertions), rubocop clean, TypeScript clean
- Verified in browser: homepage card links work, detail page renders correctly

#### Decisions Made
- `rescue_from ActiveRecord::RecordNotFound` redirects to root (no dedicated 404 page — keeps it simple)
- Time fields come from Rails as ISO strings (`2000-01-01T18:00:00.000Z`), parsed with `new Date()` and formatted with `timeZone: 'UTC'`
- RSVP and Follow buttons rendered as disabled placeholders (wired in Phase 13)
- "Back to events" link at top for navigation
- Rubocop I18n locale text cop disabled inline for the single flash message string

#### Blockers
- (none)

---

### Phase 11: Public Organization Profile
**Status:** Completed

#### Tasks Completed
- Created `OrganizationProfilesController#show` with slug lookup, org serialization, published event listing, follower count, is_following flag
- Added route `get '/o/:slug'` → `organization_profiles#show`
- Added `phone` to `DetailOrganization` TypeScript type and EventsController org serialization
- Created `app/frontend/pages/organization_profiles/show.tsx` with org header, contact info, donate button, causes/industries badges, event card grid, follower count, follow placeholder
- Primary cause highlighted with default badge variant vs secondary for others
- Wrote 8 controller tests (29 assertions) covering: valid slug, field serialization, published-only events, draft exclusion, follower count, is_following states, non-existent slug redirect
- All 90 tests passing (307 assertions), rubocop clean, TypeScript clean
- Verified in browser: org profile renders, homepage org link navigates correctly

#### Decisions Made
- Controller name `OrganizationProfilesController` (not `OrganizationsController`) to match implementation plan and avoid confusion with org auth controllers
- Reused `serialize_events` pattern from HomeController for event cards
- Follow button rendered as disabled placeholder (wired in Phase 13)
- Website displayed with protocol stripped for cleaner display
- Contact info (website, email, phone) shown in horizontal row below description

#### Blockers
- (none)

---

### Phase 12: Public User Profile
**Status:** Completed

#### Tasks Completed
- Created `ProfilesController#show` with username lookup, visibility gate, and conditional field serialization
- Added route `get '/u/:username'` → `profiles#show`
- Added `DetailUser` TypeScript type to `app/frontend/types/index.ts`
- Created `app/frontend/pages/profiles/show.tsx` with avatar placeholder, name/username/Philanthropist badge, bio, city/state, social links, causes/networks badges, followed orgs, attended events
- Wrote 9 controller tests (36 assertions) covering: valid username, field serialization, visibility=false 404, visibility_full_name hiding, visibility_email hiding, followed orgs, published-only attended events, non-existent username
- All 99 tests passing (344 assertions), rubocop clean, TypeScript clean

#### Decisions Made
- Controller named `ProfilesController` (not `UserProfilesController`) per implementation plan
- Visibility gate raises `ActiveRecord::RecordNotFound` (reuses existing rescue_from handler)
- Name fields set to nil when `visibility_full_name` is false (not omitted — frontend checks for null)
- Attended events filtered to published + upcoming only (no past events shown)
- Avatar shows initials when name visible, "?" when hidden

#### Blockers
- (none)

---

### Phase 13: Attendance & Follow Actions
**Status:** Not Started

#### Tasks Completed
- (none yet)

#### Decisions Made
- (none yet)

#### Blockers
- (none)

---

### Phase 14: Org Dashboard - Event List
**Status:** Not Started

#### Tasks Completed
- (none yet)

#### Decisions Made
- (none yet)

#### Blockers
- (none)

---

### Phase 15: Org Dashboard - Event Create/Edit
**Status:** Not Started

#### Tasks Completed
- (none yet)

#### Decisions Made
- (none yet)

#### Blockers
- (none)

---

## Session Log

### 2026-03-10
- Phase 1 completed: All 5 database tables created with proper indexes and foreign keys
- Added bcrypt gem for password hashing support
- Phase 2 completed: All 6 models created with associations, validations, enums, scopes, and tests (35 tests, 92 assertions)
- Phase 3 completed: Authentication concern created with dual auth, included in ApplicationController, Inertia shared data wired up (40 tests, 100 assertions)
- Phase 4 completed: Auth controllers and routes for users and organizations (58 total tests, 170 assertions)
- Phase 5 completed: Four auth React pages created (user sign in/up, org sign in/up), all verified in browser
- Phase 6 completed: TypeScript types for all entities, SharedProps with auth state + flash, flash sharing in InertiaController
- Phase 7 completed: Layout component with conditional nav (anonymous/user/org), ShadCN switch+tabs installed, auth page layout opt-out, SharedProps keys fixed to snake_case
- Phase 8 completed: HomeController updated with event filtering (8 filter types), 15 tests (62 assertions), rubocop clean
- Phase 9 completed: Homepage frontend rebuilt with filter bar (8 filter types) and event card grid, verified in browser
- Phase 10 completed: Event detail page with EventsController#show, two-column React page, draft visibility, 10 tests (82 total, 278 assertions)
- Phase 11 completed: Public org profile page at `/o/:slug` with OrganizationProfilesController, React page with causes/industries/events, 8 tests (90 total, 307 assertions)
- Phase 12 completed: Public user profile page at `/u/:username` with ProfilesController, visibility controls, React page with causes/networks/followed orgs/events, 9 tests (99 total, 344 assertions)

---

## Files Changed
- `app/controllers/home_controller.rb` — updated with event filtering and serialization
- `test/controllers/home_controller_test.rb` — expanded with 15 tests covering all filter types
- `.rubocop.yml` — added Metrics/ClassLength test exclusion and Minitest/MultipleAssertions max
- `app/frontend/components/Layout.tsx` — new (app shell with conditional nav)
- `app/frontend/entrypoints/inertia.tsx` — wired default layout
- `app/frontend/pages/Users/Sessions/New.tsx` — added layout opt-out
- `app/frontend/pages/Users/Registrations/New.tsx` — added layout opt-out
- `app/frontend/pages/Organizations/Sessions/New.tsx` — added layout opt-out
- `app/frontend/pages/Organizations/Registrations/New.tsx` — added layout opt-out
- `app/frontend/pages/home/index.tsx` — removed redundant wrapper styles
- `app/frontend/types/index.ts` — fixed SharedProps to use snake_case keys; expanded with User, Organization, Event, EventListItem, Attendance, Follow, SharedProps types
- `app/controllers/inertia_controller.rb` — added flash to inertia_share
- `app/frontend/pages/Users/Sessions/New.tsx` — new (user sign in form)
- `app/frontend/pages/Users/Registrations/New.tsx` — new (user sign up form)
- `app/frontend/pages/Organizations/Sessions/New.tsx` — new (org sign in form)
- `app/frontend/pages/Organizations/Registrations/New.tsx` — new (org sign up form)
- `app/controllers/users/sessions_controller.rb` — new (user sign in/out)
- `app/controllers/users/registrations_controller.rb` — new (user sign up)
- `app/controllers/organizations/sessions_controller.rb` — new (org sign in/out)
- `app/controllers/organizations/registrations_controller.rb` — new (org sign up)
- `config/routes.rb` — added namespaced auth routes
- `test/controllers/users/sessions_controller_test.rb` — new
- `test/controllers/users/registrations_controller_test.rb` — new
- `test/controllers/organizations/sessions_controller_test.rb` — new
- `test/controllers/organizations/registrations_controller_test.rb` — new
- `app/controllers/concerns/authentication.rb` — new (Authentication concern)
- `app/controllers/application_controller.rb` — added `include Authentication`
- `app/controllers/inertia_controller.rb` — wired up `inertia_share` with auth data
- `test/controllers/concerns/authentication_test.rb` — new (smoke + regression tests)
- `Gemfile` — added bcrypt gem
- `db/migrate/20260310190253_create_organizations.rb` — new
- `db/migrate/20260310190255_create_users.rb` — new
- `db/migrate/20260310190258_create_events.rb` — new
- `db/migrate/20260310190302_create_attendances.rb` — new
- `db/migrate/20260310190307_create_follows.rb` — new
- `db/schema.rb` — auto-updated
- `app/models/current.rb` — new
- `app/models/organization.rb` — new
- `app/models/user.rb` — new
- `app/models/event.rb` — new
- `app/models/attendance.rb` — new
- `app/models/follow.rb` — new
- `test/fixtures/organizations.yml` — new
- `test/fixtures/users.yml` — new
- `test/fixtures/events.yml` — new
- `test/fixtures/attendances.yml` — new
- `test/fixtures/follows.yml` — new
- `test/models/organization_test.rb` — new
- `test/models/user_test.rb` — new
- `test/models/event_test.rb` — new
- `test/models/attendance_test.rb` — new
- `test/models/follow_test.rb` — new

- `app/controllers/events_controller.rb` — new (event detail show action with draft visibility)
- `config/routes.rb` — added event show route
- `app/frontend/types/index.ts` — added DetailOrganization type
- `app/frontend/pages/events/show.tsx` — new (event detail page with two-column layout)
- `test/controllers/events_controller_test.rb` — new (10 tests, 47 assertions)

- `app/controllers/organization_profiles_controller.rb` — new (public org profile with slug lookup)
- `config/routes.rb` — added `/o/:slug` route
- `app/frontend/types/index.ts` — added `phone` to DetailOrganization
- `app/frontend/pages/organization_profiles/show.tsx` — new (org profile page with causes, industries, events)
- `app/controllers/events_controller.rb` — added `phone` to org serialization
- `test/controllers/organization_profiles_controller_test.rb` — new (8 tests, 29 assertions)

## Architectural Decisions
(Major technical decisions and rationale)

## Lessons Learned
(What worked, what didn't, what to do differently)
