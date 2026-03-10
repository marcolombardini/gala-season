# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About Gala Season
The name of this project is "Gala Season". Gala Season is a Rails 8 + React web application to browse, discover, and attend exclusive charitable gala events. It uses Inertia.js to bridge the Rails backend with a React frontend for a seamless SPA-like experience.

## Development Commands

### Database Commands

```bash
bundle exec rails db:create     # Create development and test databases
bundle exec rails db:migrate    # Run pending migrations
bundle exec rails db:rollback   # Rollback last migration
bundle exec rails db:seed       # Load seed data
bundle exec rails db:setup      # Create, load schema, and seed database
bundle exec rails db:reset      # Drop, create, migrate, and seed database
```

### Testing & Code Quality

```bash
bundle exec rubocop             # Run Ruby linter
bundle exec rubocop -a          # Auto-fix Ruby linting issues
bundle exec brakeman            # Run security analysis
npm run check                   # TypeScript type checking
```

**Important:** `bin/rails test` crashes with a system-level Ruby memory error when run with parallel workers. Always disable parallelization:
```bash
PARALLEL_WORKERS=1 bin/rails test
```

### Rails Commands

```bash
bundle exec rails console       # Start Rails console
bundle exec rails c             # Shorthand for console
bundle exec rails routes        # Show all application routes
bundle exec rails generate      # List available generators
```

### Installation & Build

```bash
bundle install                  # Install Ruby dependencies
npm install                     # Install JavaScript dependencies
bundle exec rails assets:precompile  # Build assets for production
```

### Using agent-browser
For any frontend changes, verify using:
```bash
agent-browser open http://localhost:$CONDUCTOR_PORT  # Navigate to page
agent-browser snapshot -i                             # Get interactive elements
agent-browser click @e1                               # Interact with elements
agent-browser fill @e2 "text"                         # Fill form fields
```

## Architecture Overview

### Tech Stack

- **Rails ~8.1** with PostgreSQL - Server-side framework and database
- **Inertia.js ~2.3** - Bridges Rails and React for SPA-like experience without API
- **React ~19.2** - Frontend UI framework
- **Vite ~7** - JavaScript bundler with HMR
- **Tailwind CSS ~4** - Utility-first CSS framework
- **Sidekiq 8** - Background job processing with scheduled jobs via sidekiq-scheduler
- **Redis** - Sessions, caching, and job queue

### Key Architectural Patterns

1. **Inertia.js Pattern**: Controllers render Inertia responses instead of JSON APIs:

   ```ruby
   render inertia: 'ComponentName', props: { data: value }
   ```

   Shared data is provided via ApplicationController's `inertia_share`.

2. **Authentication System**:
   - Rails 8 authentication system
   - BCrypt password hashing via `has_secure_password`
   - Password reset functionality with token expiration
   - `Authentication` concern handles authentication logic

3. **Frontend Structure**:
   - Pages: `app/frontend/pages/` - Inertia page components (organized by feature)
   - Components: `app/frontend/components/` - Reusable React components
   - Entry points: `app/frontend/entrypoints/` - Vite entry files
   - Types: `app/frontend/types/` - TypeScript definitions
   - Authentication pages don't use Layout wrapper
   - **ShadCN Components**: We use ShadCN UI components. When a necessary component is not yet added:
     1. First search available components at: https://ui.shadcn.com/docs/components
     2. Add the component with: `npx shadcn@latest add [ComponentName]`
     3. Components are installed to `app/frontend/components/ui/`

4. **Database Architecture**:
   - PostgreSQL
   - UUID primary keys using pgcrypto extension
   - JSONB columns for flexible metadata storage
   - Encrypted fields for sensitive data (OAuth tokens)

### Development Workflow

All development should be done with red/green/refactor test-driven development.

1. **Creating New Features**:
   - Generate controller: `bundle exec rails generate controller NAME`
   - Add React page component in `app/frontend/pages/`
   - Define routes in `config/routes.rb`
   - Pass data as Inertia props from controller

2. **Form Handling**:
   - Use Inertia's `useForm` hook for form state
   - Handle errors via props: `errors: model.errors.to_hash(true)`
   - Show success via flash: `flash: { success: "Message" }`

3. **Background Jobs**:
   - Use specific queues: `default`, `mailers`, etc
   - Test jobs with: `bundle exec rails runner "JobName.perform_now(args)"`
   - Monitor via Sidekiq web UI at `/sidekiq`

### Important Configuration Files

- `config/initializers/inertia_rails.rb` - Inertia configuration
- `vite.config.ts` - Vite bundler configuration
- `config/vite.json` - Rails-specific Vite settings
- `Procfile.dev` - Development process management
- `config/sidekiq.yml` - Sidekiq queue configuration

## Common Rails Generators

```bash
bundle exec rails generate controller NAME [action action]
bundle exec rails generate model NAME [field:type field:type]
bundle exec rails generate migration NAME
bundle exec rails generate job NAME
```

## Testing Philosophy

### Testing Commands

- `bin/rails test` - Run all tests
- `bin/rails test:db` - Run tests with database reset
- `bin/rails test:system` - Run system tests only (use sparingly - they take longer)
- `bin/rails test test/models/account_test.rb` - Run specific test file
- `bin/rails test test/models/account_test.rb:42` - Run specific test at line
- `bin/ci` - this runs all tests and other CI. This is the prerequisite to merging to `main`

### General Testing Rules

- **ALWAYS use Minitest + fixtures** (NEVER RSpec or factories)
- Keep fixtures minimal (2-3 per model for base cases)
- Create edge cases on-the-fly within test context
- Use Rails helpers for large fixture creation needs

### Test Quality Guidelines

- **Write minimal, effective tests** - system tests extremely sparingly, only for application critical flows
- **Only test critical and important code paths**
- **Test boundaries correctly:**
  - Commands: test they were called with correct params
  - Queries: test output
  - Don't test implementation details of other classes

### Testing Examples

```ruby
# GOOD - Testing critical domain business logic
test "good test example" do
  DomainModel.any_instance.expects(:some_operation).returns([]).once
  assert_difference "DomainModel.count", 2 do
    DomainModel.do_something
  end
end

# BAD - Testing ActiveRecord functionality
test "bad low value test" do
  record = DomainModel.new(attr1: "value1", attr2: "value2")
  assert record.save
end
```

### Stubs and Mocks

- Use `mocha` gem and VCR for external services (only in the providers layer)
- Prefer `OpenStruct` for mock instances
- Only mock what's necessary

The test runner automatically starts the Rails server in test mode.

## Code Maintenance

- Run `bundle exec rubocop -a` after significant code changes
- Use `.rubocop.yml` for style configuration
- Security scanning with `bundle exec brakeman`

## Database Schema Notes

- All tables use UUID primary keys (pgcrypto extension)
- Timestamps use `timestamptz` for timezone awareness
- JSONB columns for flexible metadata storage
- Comprehensive indexing strategy for performance
- Encrypted fields for sensitive data (OAuth tokens, API keys)

## Look up documentation with Context7

When code examples, setup or configuration steps, or library/API documentation are requested, use the Context7 mcp server to get the information.

## Code Guidelines

- Always use Tailwind classes instead of inline styles
- Before git committing and pushing any code, run rubocop with autofix
- Always use minitest
- All React components and views should be TSX
- Ask lots of clarifying questions when planning. The more the better. Make extensive use of AskUserQuestionTool to gather requirements and specifications. You can't ask too many questions.
- Do not use Kamal or Docker
- Do not use Rails "solid_*" components/systems
- When something new is added that will need some type of setup, ensure it's added to @README.md
