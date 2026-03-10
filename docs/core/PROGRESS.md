# Core Feature Progress

## Status: Phase 3 - Completed

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
**Status:** Not Started

#### Tasks Completed
- (none yet)

#### Decisions Made
- (none yet)

#### Blockers
- (none)

---

### Phase 5: Auth Frontend Pages
**Status:** Not Started

#### Tasks Completed
- (none yet)

#### Decisions Made
- (none yet)

#### Blockers
- (none)

---

### Phase 6: TypeScript Types & Shared Props
**Status:** Not Started

#### Tasks Completed
- (none yet)

#### Decisions Made
- (none yet)

#### Blockers
- (none)

---

### Phase 7: Layout Component & Navigation
**Status:** Not Started

#### Tasks Completed
- (none yet)

#### Decisions Made
- (none yet)

#### Blockers
- (none)

---

### Phase 8: Homepage Controller & Event Filtering
**Status:** Not Started

#### Tasks Completed
- (none yet)

#### Decisions Made
- (none yet)

#### Blockers
- (none)

---

### Phase 9: Homepage Frontend
**Status:** Not Started

#### Tasks Completed
- (none yet)

#### Decisions Made
- (none yet)

#### Blockers
- (none)

---

### Phase 10: Event Detail Page
**Status:** Not Started

#### Tasks Completed
- (none yet)

#### Decisions Made
- (none yet)

#### Blockers
- (none)

---

### Phase 11: Public Organization Profile
**Status:** Not Started

#### Tasks Completed
- (none yet)

#### Decisions Made
- (none yet)

#### Blockers
- (none)

---

### Phase 12: Public User Profile
**Status:** Not Started

#### Tasks Completed
- (none yet)

#### Decisions Made
- (none yet)

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

---

## Files Changed
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

## Architectural Decisions
(Major technical decisions and rationale)

## Lessons Learned
(What worked, what didn't, what to do differently)
