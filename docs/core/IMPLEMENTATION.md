# Core Feature Implementation Plan

## Overview
Build the foundational entities of Gala Season — Organizations, Users, and Events — with dual authentication, public profiles, event CRUD, event browsing with filtering, and basic attendance/follow tracking. Replaces the Base44 prototype with a production-grade Rails 8 + React + Inertia.js build.

## Prerequisites
- PostgreSQL running with pgcrypto extension (already enabled)
- Ruby 3.4+, Node.js 20+, Redis running
- ShadCN UI components installed (already done)

## Phase Summary

| Phase | Title | Focus |
|-------|-------|-------|
| 1 | Database Migrations | All 5 tables created |
| 2 | Models & Validations | Model files, associations, enums, tests |
| 3 | Authentication Concern & Current | Backend auth plumbing |
| 4 | Auth Controllers & Routes | Sign up/in/out endpoints |
| 5 | Auth Frontend Pages | React sign up/in forms |
| 6 | TypeScript Types & Shared Props | Type system + Inertia shared data |
| 7 | Layout Component & Navigation | App shell with conditional nav |
| 8 | Homepage Controller & Event Filtering | Server-side event listing with filters |
| 9 | Homepage Frontend | Event card grid + filter bar |
| 10 | Event Detail Page | Full event view (backend + frontend) |
| 11 | Public Organization Profile | Org profile page (backend + frontend) |
| 12 | Public User Profile | User profile page (backend + frontend) |
| 13 | Attendance & Follow Actions | Toggle attend/follow with controllers |
| 14 | Org Dashboard - Event List | Dashboard index page |
| 15 | Org Dashboard - Event Create/Edit | Event form with all fields |

---

## Phase 1: Database Migrations

### Objective
Create all 5 database tables with proper types, indexes, and foreign keys.

### Tasks
- [ ] Add `bcrypt` gem to Gemfile, run `bundle install`
- [ ] Create migration for `organizations` table (UUID PK, name, slug w/ unique index, description, website, email w/ unique index, phone, donation_url, primary_cause, industries string[], causes string[], password_digest, timestamps)
- [ ] Create migration for `users` table (UUID PK, first_name, last_name, email w/ unique index, username w/ unique index, bio, visibility/visibility_full_name/visibility_email booleans, state, city, birthdate, sex, social_x/linkedin/instagram/facebook, interested_causes string[], interested_industries string[], password_digest, timestamps)
- [ ] Create migration for `events` table (UUID PK, organization_id UUID FK w/ index, title, description text, date, start_time time, end_time time, venue_name, street_address, city, state, zip, dress_code integer nullable, starting_ticket_price decimal(10,2), ticket_link, hashtags string[], countdown_timer bool, auction_items bool, gift_items bool, status integer default 0, timestamps)
- [ ] Create migration for `attendances` table (UUID PK, user_id + event_id UUID FKs, unique compound index on [user_id, event_id], timestamps)
- [ ] Create migration for `follows` table (UUID PK, user_id + organization_id UUID FKs, unique compound index on [user_id, organization_id], timestamps)
- [ ] Run `bin/rails db:migrate` and verify schema

### Success Criteria
`bin/rails db:migrate` succeeds. `db/schema.rb` shows all 5 tables with correct columns, types, and indexes.

### Files Affected
- `Gemfile`
- `db/migrate/*_create_organizations.rb`
- `db/migrate/*_create_users.rb`
- `db/migrate/*_create_events.rb`
- `db/migrate/*_create_attendances.rb`
- `db/migrate/*_create_follows.rb`

---

## Phase 2: Models & Validations

### Objective
Create all model files with associations, validations, enums, scopes, and slug generation. Write model tests.

### Tasks
- [ ] Create `Organization` model: `has_secure_password`, `has_many :events`, `has_many :follows`, `has_many :followers` (through follows, source: :user), slug auto-generation via `before_validation` (parameterize name, append counter on collision), validations (name, email, slug presence + uniqueness)
- [ ] Create `User` model: `has_secure_password`, `has_many :attendances`, `has_many :attended_events` (through attendances, source: :event), `has_many :follows`, `has_many :followed_organizations` (through follows, source: :organization), validations (first_name, last_name, email, username presence; email/username uniqueness)
- [ ] Create `Event` model: `belongs_to :organization`, `has_many :attendances`, `has_many :attendees` (through attendances, source: :user), `enum :dress_code` (9 values, nullable), `enum :status` (draft/published), scopes `published` and `upcoming`, validations (title, date presence)
- [ ] Create `Attendance` model: belongs_to user + event, uniqueness validation on user_id scoped to event_id
- [ ] Create `Follow` model: belongs_to user + organization, uniqueness validation on user_id scoped to organization_id
- [ ] Create `Current` model (`ActiveSupport::CurrentAttributes`) with `attribute :user, :organization`
- [ ] Create fixtures: 2-3 organizations, 2-3 users, 3-4 events, 2 attendances, 2 follows
- [ ] Write model tests: validations, associations, slug generation, enum behavior, published/upcoming scopes

### Success Criteria
`bin/rails test test/models/` passes. All associations work correctly in console.

### Files Affected
- `app/models/organization.rb`
- `app/models/user.rb`
- `app/models/event.rb`
- `app/models/attendance.rb`
- `app/models/follow.rb`
- `app/models/current.rb`
- `test/fixtures/*.yml`
- `test/models/*_test.rb`

---

## Phase 3: Authentication Concern & Current

### Objective
Build the backend authentication plumbing — a single concern that handles both user and org sessions.

### Tasks
- [ ] Create `Authentication` concern (`app/controllers/concerns/authentication.rb`):
  - `set_current_auth`: reads session, sets `Current.user` or `Current.organization` (called on every request)
  - `authenticate!`: redirects to root unless signed in
  - `authenticate_user!`: redirects unless signed in as user
  - `authenticate_organization!`: redirects unless signed in as org
  - `signed_in?`, `current_user`, `current_organization` helpers
  - `sign_in_user(user)`: `reset_session`, set `session[:user_id]`
  - `sign_in_organization(org)`: `reset_session`, set `session[:organization_id]`
  - `sign_out`: `reset_session`
- [ ] Include `Authentication` in `ApplicationController`, add `before_action :set_current_auth` and `helper_method` declarations

### Success Criteria
Concern loads without errors. Helper methods accessible in controllers.

### Files Affected
- `app/controllers/concerns/authentication.rb`
- `app/controllers/application_controller.rb`

---

## Phase 4: Auth Controllers & Routes

### Objective
Create sign up, sign in, and sign out endpoints for both users and organizations.

### Tasks
- [ ] Create `Users::SessionsController` (new, create, destroy)
- [ ] Create `Users::RegistrationsController` (new, create)
- [ ] Create `Organizations::SessionsController` (new, create, destroy)
- [ ] Create `Organizations::RegistrationsController` (new, create)
- [ ] Add routes:
  ```ruby
  namespace :users do
    get 'sign_in', to: 'sessions#new'
    post 'sign_in', to: 'sessions#create'
    delete 'sign_out', to: 'sessions#destroy'
    get 'sign_up', to: 'registrations#new'
    post 'sign_up', to: 'registrations#create'
  end
  namespace :organizations do
    get 'sign_in', to: 'sessions#new'
    post 'sign_in', to: 'sessions#create'
    delete 'sign_out', to: 'sessions#destroy'
    get 'sign_up', to: 'registrations#new'
    post 'sign_up', to: 'registrations#create'
  end
  ```
- [ ] Write controller tests: successful sign up, sign in, sign out; invalid credentials; duplicate email

### Success Criteria
All auth controller tests pass. Sign up creates records, sign in sets session, sign out clears session.

### Files Affected
- `app/controllers/users/sessions_controller.rb`
- `app/controllers/users/registrations_controller.rb`
- `app/controllers/organizations/sessions_controller.rb`
- `app/controllers/organizations/registrations_controller.rb`
- `config/routes.rb`
- `test/controllers/users/*_test.rb`
- `test/controllers/organizations/*_test.rb`

---

## Phase 5: Auth Frontend Pages

### Objective
Create the four authentication page components (sign in/up for users and orgs). No layout wrapper.

### Tasks
- [ ] Create `app/frontend/pages/users/sessions/new.tsx` — User sign in (email + password), uses `useForm`, ShadCN Card/Input/Label/Button, link to "Sign up" and "Are you an organization?"
- [ ] Create `app/frontend/pages/users/registrations/new.tsx` — User sign up (first_name, last_name, email, username, password, password_confirmation), link to "Sign in" and "Are you an organization?"
- [ ] Create `app/frontend/pages/organizations/sessions/new.tsx` — Org sign in (email + password), link to "Sign up" and "Are you a user?"
- [ ] Create `app/frontend/pages/organizations/registrations/new.tsx` — Org sign up (name, email, password, password_confirmation), link to "Sign in" and "Are you a user?"
- [ ] All pages opt out of Layout: `Component.layout = (page: React.ReactNode) => <>{page}</>`

### Success Criteria
All four forms render, submit via Inertia, show validation errors inline. No layout wrapper visible on auth pages.

### Files Affected
- `app/frontend/pages/users/sessions/new.tsx`
- `app/frontend/pages/users/registrations/new.tsx`
- `app/frontend/pages/organizations/sessions/new.tsx`
- `app/frontend/pages/organizations/registrations/new.tsx`

---

## Phase 6: TypeScript Types & Shared Props

### Objective
Define TypeScript types for all entities and wire up Inertia shared data (auth state, flash).

### Tasks
- [ ] Update `app/frontend/types/index.ts` with types: `User`, `Organization`, `Event`, `EventListItem` (slim version with nested org), `Attendance`, `Follow`, updated `SharedProps` (currentUser, currentOrganization, flash)
- [ ] Update `InertiaController` to share auth state via `inertia_share`: serialized `current_user` (id, first_name, last_name, email, username), serialized `current_organization` (id, name, slug, email), flash data

### Success Criteria
TypeScript types compile without errors (`npm run check`). Shared props available on every Inertia page visit.

### Files Affected
- `app/frontend/types/index.ts`
- `app/controllers/inertia_controller.rb`

---

## Phase 7: Layout Component & Navigation

### Objective
Create the app shell Layout component with a navigation bar that renders conditionally based on auth state.

### Tasks
- [ ] Install ShadCN `switch` and `tabs` components (needed later but add now): `npx shadcn@latest add switch tabs`
- [ ] Create `app/frontend/components/Layout.tsx`:
  - "Gala Season" branding/link to home
  - Not signed in: "Sign In" dropdown (User / Organization), "Sign Up" dropdown (User / Organization)
  - Signed in as user: "Browse Events" link, username dropdown (Profile, Sign Out)
  - Signed in as org: "Dashboard" link, "Browse Events" link, org name dropdown (Profile, Sign Out)
  - Uses ShadCN DropdownMenu, Button, Avatar
- [ ] Enable layout in `app/frontend/entrypoints/inertia.tsx`: set default layout to Layout, auth pages override to no-layout
- [ ] Update auth pages to explicitly set no-layout

### Success Criteria
Nav renders correctly for all 3 auth states (not signed in, user, org). Layout wraps all pages except auth pages.

### Files Affected
- `app/frontend/components/Layout.tsx`
- `app/frontend/entrypoints/inertia.tsx`
- Auth page files (add layout opt-out)

---

## Phase 8: Homepage Controller & Event Filtering

### Objective
Update the home controller to return published upcoming events with server-side filtering.

### Tasks
- [ ] Update `HomeController#index`:
  - Base query: `Event.published.upcoming.includes(:organization)`
  - Filter by cause: `WHERE :cause = ANY(causes)` via PostgreSQL array operator
  - Filter by city/state: string match on event city/state
  - Filter by month: `EXTRACT(MONTH FROM date)`
  - Filter by price range: `BETWEEN` on starting_ticket_price
  - Filter by industry: array operator on organization's industries
  - Filter by name: `ILIKE` on title
  - Serialize events as EventListItem (id, title, date, venue_name, city, state, starting_ticket_price, dress_code, status, organization: {name, slug})
  - Pass `events`, `filters` (current param values), `causes` (distinct list for filter dropdown)
- [ ] Write controller tests: returns published events, excludes drafts, excludes past events, filters work correctly

### Success Criteria
Controller tests pass. Correct events returned with and without filters.

### Files Affected
- `app/controllers/home_controller.rb`
- `test/controllers/home_controller_test.rb`

---

## Phase 9: Homepage Frontend

### Objective
Build the homepage UI with event card grid and filter bar.

### Tasks
- [ ] Rebuild `app/frontend/pages/home/index.tsx`:
  - Filter bar at top: text search (name), cause select, month picker, city/state inputs, price range inputs, industry select
  - Filters submit as GET params via Inertia `router.get`
  - Event card grid using ShadCN Card: title, date, org name (links to `/o/slug`), city/state, starting price, dress code badge
  - Each card links to `/events/:id`
  - Empty state when no events match
- [ ] Verify with `agent-browser`

### Success Criteria
Homepage displays event cards. Filters update the results. Empty state shown when no matches. Cards link to correct event detail pages.

### Files Affected
- `app/frontend/pages/home/index.tsx`

---

## Phase 10: Event Detail Page

### Objective
Create the public event detail page with two-column layout.

### Tasks
- [ ] Create `EventsController#show`: find event by ID, ensure published (or owned by current org for draft preview), serialize full event + organization + attendee count + whether current user is attending
- [ ] Add route: `get '/events/:id', to: 'events#show'`
- [ ] Create `app/frontend/pages/events/show.tsx`:
  - Left column: banner placeholder, title, org name link, description, hashtag badges
  - Right column (sidebar): date, time range, dress code, venue/address, starting price, "Purchase Tickets" button (links to ticket_link), auction/gift item badges, attendee count
  - RSVP button placeholder (wired in Phase 13)
  - Follow org button placeholder (wired in Phase 13)
- [ ] Write controller test: published event returns data, draft event returns 404 for non-owner

### Success Criteria
Event detail page renders with all fields. Draft events hidden from public. Two-column layout displays correctly.

### Files Affected
- `app/controllers/events_controller.rb`
- `config/routes.rb`
- `app/frontend/pages/events/show.tsx`
- `test/controllers/events_controller_test.rb`

---

## Phase 11: Public Organization Profile

### Objective
Create the public organization profile page at `/o/:slug`.

### Tasks
- [ ] Create `OrganizationProfilesController#show`: find org by slug, serialize org + published events + follower count + whether current user follows
- [ ] Add route: `get '/o/:slug', to: 'organization_profiles#show'`
- [ ] Create `app/frontend/pages/organization_profiles/show.tsx`:
  - Org name, description, website/email/phone, donate button (links to donation_url)
  - "Causes We Support" as tag badges, "Industries & Networks" as tag badges
  - Primary cause highlighted
  - "Events by [Org]" section with event cards
  - Follower count display
  - Follow button placeholder (wired in Phase 13)
- [ ] Write controller test

### Success Criteria
Org profile loads by slug. Shows correct org data, published events only, follower count.

### Files Affected
- `app/controllers/organization_profiles_controller.rb`
- `config/routes.rb`
- `app/frontend/pages/organization_profiles/show.tsx`
- `test/controllers/organization_profiles_controller_test.rb`

---

## Phase 12: Public User Profile

### Objective
Create the public user profile page at `/u/:username` with visibility controls.

### Tasks
- [ ] Create `ProfilesController#show`: find user by username, serialize user respecting visibility booleans (hide full name if !visibility_full_name, hide email if !visibility_email, return 404 if !visibility), include followed orgs and attended events
- [ ] Add route: `get '/u/:username', to: 'profiles#show'`
- [ ] Create `app/frontend/pages/profiles/show.tsx`:
  - Avatar placeholder, name (if visible), username, "Philanthropist" badge
  - Bio, city/state, social links (if present)
  - "My Causes" and "My Networks" as tag badges
  - "Following Organizations" section
- [ ] Write controller test: respects visibility booleans, 404 for hidden profiles

### Success Criteria
User profile renders with correct data. Hidden fields not exposed. Private profiles return 404.

### Files Affected
- `app/controllers/profiles_controller.rb`
- `config/routes.rb`
- `app/frontend/pages/profiles/show.tsx`
- `test/controllers/profiles_controller_test.rb`

---

## Phase 13: Attendance & Follow Actions

### Objective
Wire up attend/unattend and follow/unfollow as Inertia form actions.

### Tasks
- [ ] Create `AttendancesController`: create (POST `/events/:event_id/attend`), destroy (DELETE `/events/:event_id/attend`). Requires authenticated user.
- [ ] Create `FollowsController`: create (POST `/o/:slug/follow`), destroy (DELETE `/o/:slug/follow`). Requires authenticated user.
- [ ] Add routes for both controllers
- [ ] Update `app/frontend/pages/events/show.tsx`: wire RSVP button to `router.post`/`router.delete` based on attending state
- [ ] Update `app/frontend/pages/organization_profiles/show.tsx`: wire follow button similarly
- [ ] Write controller tests: attend, unattend, follow, unfollow; duplicate prevention; auth required

### Success Criteria
Users can toggle attendance and follows. Buttons reflect current state. Duplicates prevented. Non-authenticated users redirected.

### Files Affected
- `app/controllers/attendances_controller.rb`
- `app/controllers/follows_controller.rb`
- `config/routes.rb`
- `app/frontend/pages/events/show.tsx`
- `app/frontend/pages/organization_profiles/show.tsx`
- `test/controllers/attendances_controller_test.rb`
- `test/controllers/follows_controller_test.rb`

---

## Phase 14: Org Dashboard - Event List

### Objective
Create the organization dashboard with an event listing page.

### Tasks
- [ ] Create `Dashboard::EventsController#index`: requires authenticated org, lists current org's events (all statuses) with attendee counts
- [ ] Add route: `namespace :dashboard do resources :events, only: [:index, :new, :create, :edit, :update] end`
- [ ] Create `app/frontend/pages/dashboard/events/index.tsx`:
  - ShadCN Table: title, date, status badge (draft/published), attendee count, edit link
  - "Create Event" button linking to `/dashboard/events/new`
  - Empty state for no events
- [ ] Write controller test: only shows org's events, blocked for users

### Success Criteria
Dashboard shows org's events. Users/public redirected away. Table displays correct data with status badges.

### Files Affected
- `app/controllers/dashboard/events_controller.rb`
- `config/routes.rb`
- `app/frontend/pages/dashboard/events/index.tsx`
- `test/controllers/dashboard/events_controller_test.rb`

---

## Phase 15: Org Dashboard - Event Create/Edit

### Objective
Build the event creation and editing forms for organizations.

### Tasks
- [ ] Add `new`, `create`, `edit`, `update` actions to `Dashboard::EventsController`
- [ ] Create shared `app/frontend/components/EventForm.tsx`:
  - Sections: General Info (title, description), Date & Location (date, start_time, end_time, venue, address, city, state, zip), Details (dress_code select, starting_ticket_price, ticket_link, hashtags, countdown_timer/auction_items/gift_items toggles, status select)
  - Uses `useForm` from `@inertiajs/react`
  - Validation error display inline
- [ ] Create `app/frontend/pages/dashboard/events/new.tsx` — renders EventForm for creation
- [ ] Create `app/frontend/pages/dashboard/events/edit.tsx` — renders EventForm pre-populated
- [ ] Write controller tests: create with valid/invalid data, edit/update, only own events editable

### Success Criteria
Orgs can create and edit events. Validation errors show inline. Saving redirects to dashboard index. Published events appear on homepage.

### Files Affected
- `app/controllers/dashboard/events_controller.rb`
- `app/frontend/components/EventForm.tsx`
- `app/frontend/pages/dashboard/events/new.tsx`
- `app/frontend/pages/dashboard/events/edit.tsx`
- `test/controllers/dashboard/events_controller_test.rb`

---

## Post-Implementation
- [ ] Run `bundle exec rubocop -a` for code style
- [ ] Run `bundle exec brakeman` for security scan
- [ ] Run `npm run check` for TypeScript validation
- [ ] Run `bin/rails test` for full test suite
- [ ] Verify all pages with `agent-browser`
- [ ] Run `bin/ci` as final check

## Notes
- No file uploads in this build — avatars/logos/banners use placeholders
- No Devise — pure `has_secure_password` + Authentication concern
- All tables use UUID primary keys
- PostgreSQL array columns for multi-value fields (causes, industries, hashtags)
- Dress code is nullable integer enum (nil = not specified)
- Auth pages skip the Layout wrapper via Inertia layout opt-out
