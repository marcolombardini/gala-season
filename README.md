# Gala Season

## Requirements

- Ruby 3.4+
- PostgreSQL
- Redis
- Node.js 20+

## Mac Setup

```bash
brew install postgresql@17 redis node
brew services start postgresql@17
brew services start redis
```

Install Ruby 3.4+ via [rbenv](https://github.com/rbenv/rbenv):

```bash
brew install rbenv
rbenv install 3.4.5
rbenv local 3.4.5
```

Install dependencies and create the database:

```bash
bundle install
npm install
cp .env.example .env
bin/rails db:create db:migrate
```

## Development

```bash
bin/dev
```

Starts Puma (port 3000), Vite dev server, and Sidekiq.

- App: http://localhost:3000
- Sidekiq dashboard: http://localhost:3000/sidekiq

## Stack

- **Backend:** Rails 8, PostgreSQL, Sidekiq 8
- **Frontend:** React, TypeScript, Inertia.js, Tailwind CSS 4, Vite
- **Cache/Sessions/Jobs:** Redis

## Seed Data

Populate the database with sample organizations, users, and events for testing:

```bash
bin/rails db:seed
```

Safe to run multiple times. To clear all data and re-seed from scratch:

```bash
SEED_RESET=1 bin/rails db:seed
```

All seed accounts use password `password`.

## Testing

```bash
bin/rails test
```

## Linting

```bash
bundle exec rubocop
bundle exec brakeman -q
```
