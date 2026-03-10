# Core Feature Research

## Overview
Establish the three foundational entities of Gala Season — Organizations, Users, and Events — with dual authentication, public profiles, event CRUD, event browsing with filtering, and basic attendance tracking. This is the ground-floor build replacing a Base44 vibecoded prototype.

## Problem Statement
Gala Season needs a production-grade foundation. The current site (galaseason.com) was built with Base44 and lacks the quality, flexibility, and maintainability needed to grow. We're rebuilding from scratch on Rails 8 + React + Inertia.js with proper data modeling, authentication, and UI.

The core must establish:
- Two separate authenticatable user types (organizations and individual users)
- Event creation/management by organizations
- Event discovery and attendance by users
- Public profiles for both user types

## User Stories / Use Cases

### Organizations
- Sign up with org name, email, password
- Sign in to a dashboard to manage events
- Create events with full details (date, venue, dress code, pricing, etc.)
- Save events as draft or publish them
- Edit and delete their own events
- Have a public profile page showing their info and upcoming events (`/o/org-slug`)
- See follower count on their profile

### Users
- Sign up with name, email, username, password
- Sign in to browse and discover events
- Filter events by name, cause, month, location, ticket price range, industry
- RSVP / mark attendance for events
- Follow organizations to stay connected
- Have a public profile page with configurable visibility (`/u/username`)
- Control what's visible: full name, email, profile itself
- Profile shows causes, networks/industries, and followed organizations

### Public Visitors
- Browse upcoming events on the homepage (browse-first experience)
- View event details
- View public organization and user profiles

## Technical Research

### Dual Authentication Approach

**Recommended: Single session, two keys.** Not Devise — use Rails 8's built-in `has_secure_password` since both models are simple email+password auth.

- Store `user_id` OR `organization_id` in session (never both simultaneously)
- Single `Authentication` concern on `ApplicationController` checks both session keys
- `Current` model with `Current.user` and `Current.organization`
- Separate sign-in/sign-up routes namespaced by type
- `reset_session` on sign-in prevents session fixation

**Why not Devise?** Overkill for this use case. `has_secure_password` + a simple concern is ~40 lines and gives us exactly what we need. No gem dependency, no generator magic.

**Why not STI/polymorphic?** Organizations and users have completely different fields, different dashboards, different capabilities. Separate tables is cleaner.

### Required Technologies
- **bcrypt gem** — needed for `has_secure_password` (currently missing from Gemfile)
- **Active Storage** — skipped for now; logo/avatar/banner fields omitted from initial migrations
- **PostgreSQL arrays** — for multi-value fields (industries, causes, hashtags, interested_causes, etc.)
- **GIN indexes** — for efficient querying on array columns

### Data Requirements

#### Organizations Table
| Field | Type | Constraints |
|-------|------|-------------|
| id | uuid | PK |
| name | string | not null |
| slug | string | not null, unique (auto-generated from name) |
| description | text | |
| website | string | |
| email | string | not null, unique |
| phone | string | |
| donation_url | string | |
| primary_cause | string | |
| industries | string[] | default: [] |
| causes | string[] | default: [] |
| password_digest | string | not null |

#### Users Table
| Field | Type | Constraints |
|-------|------|-------------|
| id | uuid | PK |
| first_name | string | not null |
| last_name | string | not null |
| email | string | not null, unique |
| username | string | not null, unique |
| bio | text | |
| visibility | boolean | default: true |
| visibility_full_name | boolean | default: true |
| visibility_email | boolean | default: false |
| state | string | |
| city | string | |
| birthdate | date | |
| sex | string | |
| social_x | string | |
| social_linkedin | string | |
| social_instagram | string | |
| social_facebook | string | |
| interested_causes | string[] | default: [] |
| interested_industries | string[] | default: [] |
| password_digest | string | not null |

#### Events Table
| Field | Type | Constraints |
|-------|------|-------------|
| id | uuid | PK |
| organization_id | uuid | FK, not null |
| title | string | not null |
| description | text | |
| date | date | not null |
| start_time | time | |
| end_time | time | |
| venue_name | string | |
| street_address | string | |
| city | string | |
| state | string | |
| zip | string | |
| dress_code | integer | nullable (enum) |
| starting_ticket_price | decimal(10,2) | |
| ticket_link | string | |
| hashtags | string[] | default: [] |
| countdown_timer | boolean | default: false |
| auction_items | boolean | default: false |
| gift_items | boolean | default: false |
| status | integer | not null, default: 0 (enum: draft/published) |

**Dress code enum values:** black_tie, black_tie_optional, cocktail_attire, business_casual, formal, corporate, corporate_festive, festive, festive_black_tie

Nullable field — no default. `nil` means not specified.

**Status enum values:** draft (0), published (1)

#### Attendances Table (join table)
| Field | Type | Constraints |
|-------|------|-------------|
| id | uuid | PK |
| user_id | uuid | FK, not null |
| event_id | uuid | FK, not null |
| unique index on [user_id, event_id] |

#### Follows Table (user follows organization)
| Field | Type | Constraints |
|-------|------|-------------|
| id | uuid | PK |
| user_id | uuid | FK, not null |
| organization_id | uuid | FK, not null |
| unique index on [user_id, organization_id] |

### URL Architecture

| URL | Purpose |
|-----|---------|
| `/` | Homepage — browse upcoming events with filters |
| `/events/:id` | Public event detail |
| `/u/:username` | Public user profile |
| `/o/:slug` | Public org profile |
| `/users/sign_up` | User registration |
| `/users/sign_in` | User sign in |
| `/organizations/sign_up` | Org registration |
| `/organizations/sign_in` | Org sign in |
| `/dashboard/events` | Org event management |
| `/dashboard/events/new` | Create event |
| `/dashboard/events/:id/edit` | Edit event |

## UI/UX Considerations

### Homepage (Browse-First)
- Grid/list of upcoming event cards
- Filter bar: name search, cause, month picker, location (city/state), ticket price range, industry
- Each card shows: title, date, venue, city/state, starting price, org name
- Clicking a card goes to event detail page

### Event Detail Page
- Two-column layout: main content left, details sidebar right
- **Main column**: Banner placeholder, title, org name link, "About the Event" description, cause/industry tags
- **Sidebar**: Date, time, dress code, venue/address, starting price, "Purchase Tickets" CTA (links to ticket_link), auction/gift item badges, RSVP button for signed-in users
- Follow org button if signed in as user

### Auth Pages
- Clean, centered card forms
- Separate pages for user vs org sign-up/sign-in
- Links to switch between user/org auth ("Are you an organization?")
- No layout wrapper on auth pages (standalone)

### Dashboard (Org)
- Event list table with edit/delete actions, status badges (draft/published)
- Create event form with all fields, sectioned layout (General Info, Date & Location, Details)
- Save as Draft or Publish actions
- Single long form (matching existing site pattern)

### Public Profiles
- **User profile** (`/u/username`): Avatar placeholder, name (if visible), "Philanthropist" badge, bio, city/state, social links, "My Causes" and "My Networks" as tag pills, "Following Organizations" section
- **Org profile** (`/o/slug`): Logo placeholder, name, description, website/email/phone, donate button, "Causes We Support" and "Industries & Networks" as tag pills, "Events by [Org]" section, Follow button, follower count

### Nav Bar
- Conditional rendering based on auth state:
  - Not signed in: "Sign In" dropdown (User / Organization), "Sign Up" dropdown
  - Signed in as user: "Browse Events", profile link, sign out
  - Signed in as org: "Dashboard", "Browse Events", profile link, sign out

## Integration Points

### Existing Codebase
- **`InertiaController`** (`app/controllers/inertia_controller.rb`) — base controller with shared data; needs auth data added
- **`inertia.tsx`** (`app/frontend/entrypoints/inertia.tsx`) — needs default layout wiring
- **ShadCN components** already available: avatar, badge, button, card, dialog, dropdown-menu, input, label, select, separator, table, textarea, tooltip
- **ShadCN components to add**: switch (boolean toggles), tabs (profile pages)
- **`cn()` utility** (`app/frontend/lib/utils.ts`) — class merging helper
- **TypeScript types** (`app/frontend/types/index.ts`) — needs expansion for User, Org, Event, Auth types

### Event Filtering
- Server-side filtering via query params on `EventsController#index`
- PostgreSQL array operators (`@>`, `&&`) for cause/industry filtering
- Price range filtering with `BETWEEN`
- Month filtering with `EXTRACT(MONTH FROM date)`
- Location filtering on city/state string match

## Risks and Challenges

1. **Dual auth session conflicts** — If a user and org share an email, they could theoretically sign into the wrong type. Mitigated by separate session keys and separate sign-in pages.
2. **Slug collisions** — Auto-generating slugs from org names could collide. Handle by appending a counter suffix if slug exists.
3. **Array field querying performance** — GIN indexes on PostgreSQL arrays handle this well, but worth monitoring as data grows.
4. **No file uploads yet** — Logo, avatar, and banner_image fields are deferred. Profile pages will need placeholder/initials avatars.

## Observations from Existing Site (Screenshots)

### Organization Profile Page
- Header: logo, org name, "Verified" badge, Share button, "Follow Events" button
- Description text, then contact row: website, email, phone, "Donate" CTA button
- "Causes We Support" and "Industries & Networks" displayed as tag pills
- "Events by [Org Name]" section below with event cards (banner image, title)

### Organization Profile Edit Form
- Causes selection: checkboxes (up to 5), plus custom causes (up to 3) as tag inputs
- Industries selection: checkboxes (up to 7), plus custom industries (up to 3) as tag inputs
- Primary Cause dropdown ("This will be displayed on event cards")
- Standard text fields for name, logo URL, description, website, email, phone, donation URL

### Event Creation Form
- Sectioned layout: "General Information" (title, description), "Date & Location" (date picker, start/end time dropdowns, venue, address, city, state dropdown, zip), "Details" (dress code dropdown, price, ticket link, hashtags text field, three checkboxes with helper text, banner image upload)
- Bottom actions: Preview, Save Draft, Submit Event
- Events have a **draft/published workflow** — "All submissions are reviewed for quality and relevance"

### User Profile Page
- Avatar, full name, "Philanthropist" badge, Share/Follow buttons
- "My Causes" and "My Networks" as tag pill sections
- "Following Organizations" section listing orgs they follow

### Event Detail Page
- Two-column layout: main content left, details sidebar right
- Main: banner image, title, org name link, "About the Event" description, "Hosted by" / "Entertainment" sections, embedded map
- Sidebar: date, time, venue/address, price, "Purchase Tickets" CTA (repeated for multiple ticket tiers), "View Auction", "Share Event", "Save Event", "Add to Calendar" buttons, cause/industry tags
- Bottom: "Enter Raffle" and "Donate" buttons

### Footer / Site Map
- Sections: Account, The Season (Upcoming/Popular Causes/Live Auctions/Past Events), For Organizers (Create Event/Listing Benefits/Plans & Pricing/How to Add/Community Guidelines), Company (About/Contact/Blog/Support), Event Services (Browse All/Join Directory), Resources (Tax Deduction Calculator/Donor Acknowledgement Letter/Revenue Planner/Budget Planner/Sponsorship Builder/Announcement Planner/Seating Chart Planner)

### Key Patterns to Note for Core Build
- **Cause/industry limits**: Orgs can select up to 5 causes + 3 custom, up to 7 industries + 3 custom
- **Event draft state**: Events have draft/published status (not just CRUD)
- **Follow relationship**: Users can follow organizations
- **"Philanthropist" label**: Users are branded as philanthropists on the platform
- **Multiple ticket tiers**: Event detail shows multiple venue/price options in sidebar (future feature, not core)
- **Save/Share/Calendar**: Event interaction buttons (future feature)

## Decisions Made

- **Event status**: Yes — add `status` enum (draft/published) to events table
- **Follows**: Yes — add `follows` join table (user follows organization) in core
- **Cause/industry limits**: No caps enforced in the database — just string arrays, keep it simple
- **File uploads**: Deferred — no Active Storage setup in core
- **Homepage**: Browse-first, showing upcoming published events with filtering
- **Dress code**: Nullable field, enum values: black_tie, black_tie_optional, cocktail_attire, business_casual, formal, corporate, corporate_festive, festive, festive_black_tie
- **Authentication**: `has_secure_password` with single Authentication concern, not Devise

## Open Questions

None — all decisions made.

## References

- [Rails 8 has_secure_password](https://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html)
- [PostgreSQL Array Functions](https://www.postgresql.org/docs/current/functions-array.html)
- [Inertia.js Shared Data](https://inertia-rails.dev/guide/shared-data)
- [ShadCN UI Components](https://ui.shadcn.com/docs/components)
- Research on galaseason.com, charitable event platforms, and dress code conventions
