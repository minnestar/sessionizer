# Sessionizer - AI Coding Guide

Unconference scheduling app for Minnebar. Rails 7.2, Ruby 3.4.1, PostgreSQL.

## Stack

- **Auth**: Authlogic (participants via `UserSessionsController`) + Devise (admin users via ActiveAdmin)
- **Admin**: ActiveAdmin 4 (beta) with CanCanCan authorization - resources in `app/admin/`
- **Views**: ERB templates (some legacy HAML exists)
- **CSS**: Tailwind CSS v4
- **Testing**: RSpec, FactoryBot, Shoulda matchers, Capybara with headless Chrome
- **Deployment**: Heroku with Unicorn

## Code Style

- Use **double quotes** for all Ruby strings
- **No em dashes or en dashes** anywhere - use regular hyphens only
- Follow existing patterns in models: scopes, `has_many`/`belongs_to`, `validates`

## Views

- Write new view templates in **ERB** (`.html.erb`)
- ActiveAdmin views use the ActiveAdmin DSL, not standalone templates
- After changing Tailwind classes in admin views, rebuild CSS with `npm run build:css`

## Testing

- Run tests: `rails spec` (or `bundle exec rspec spec/path/to/spec.rb`)
- Headless Chrome by default; `HEADED=1 rails spec` to see the browser
- Factories in `spec/factories/` (individual files) and `spec/factories.rb` (shared sequences)
- Use `let` and `create`/`build` from FactoryBot (included globally)
- Use Shoulda matchers for association/validation one-liners
- Feature specs use `spec/support/authentication_support.rb` for sign-in helpers

## Migrations

- Use **ActiveRecord queries** in data migrations, not raw SQL
  - Good: `Model.find_or_create_by!(name: "x")`, `Model.update_all(col: val)`
  - Bad: `execute("INSERT INTO ...")`
- See `db/migrate/20260319035803_backfill_event_categories.rb` for an example

## Key Architecture

- `Event.current_event` - returns the latest event; many queries scope to this
- `lib/scheduling/` - simulated annealing algorithm for auto-scheduling sessions into rooms/timeslots
- `lib/recommender.rb` - session recommendation engine based on attendance similarity
- `app/models/settings.rb` - app-wide singleton settings
- `config.time_zone` is Central Time (US & Canada)

## Ongoing Migration

- Many operational tasks historically live in `lib/tasks/app.rake` (seeding, scheduling, etc.)
- We are gradually moving these to be runnable from the ActiveAdmin panel instead of the CLI
- When adding new admin functionality, prefer ActiveAdmin actions over new rake tasks

## Don't

- Don't run Rails generators or CLI commands - provide the command for the human to run
- Don't use `rails generate` output as-is without reviewing it
- Don't add new gems without discussing first
- Don't use raw SQL in migrations
