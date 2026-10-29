# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

EVA Server is a Ruby on Rails application that serves as the backend and administration interface for the French government's digital skills assessment platform. It manages literacy (littératie) and numeracy (numératie) evaluations for professional integration programs.

## Development Commands

### Initial Setup
```bash
bundle install
npm install
cp .env.template .env
# Edit .env with required environment variables (MOT_DE_PASS_COMPTES_PREPROD is needed below)
rake db:create
bin/reviewappdeploy.sh
```

`bin/reviewappdeploy.sh` (same script as Scalingo review apps) runs:
1. `rake reviewapp:initdb`: loads test data from `db/evaluations_tests.sql`
2. `rails db:migrate`
3. `rails db:seed`
4. `rake reviewapp:seed`: sets every account's password to `MOT_DE_PASS_COMPTES_PREPROD`

The `reviewapp:*` tasks abort when `APP=eva-serveur` (production).

### Testing
```bash
bundle exec rake spec        # Run full test suite
bundle exec guard           # Continuous testing with file watching
bin/rspec spec/path/file_spec.rb  # Run single test file
bundle exec rake validation  # Full pre-commit validation (see below)
```

`rake validation` runs these steps in order and stops at the first failure:
1. `bundle exec rubocop -A`: lints Ruby and **auto-corrects** files (including unsafe corrections)
2. `rake locale_typography`: checks non-breaking spaces in translations (before `:` `!` `?`, after `«` and before `»`)
3. `npm run lint:css`: stylelint on `app/assets/stylesheets/**/*.scss`
4. `bundle exec rspec`: full test suite

### Development Server
```bash
bundle exec foreman start -p 3000  # Start all Procfile processes (port 3000)
```

`foreman` starts every process in the `Procfile`:
- `web`: `rails server`
- `worker`: Sidekiq (default queues)
- `workerpdf`: Sidekiq on the `pdf` queue (PDF generation)
- `postdeploy`: `bin/postdeploy.sh`, which in development just runs `cat` to stay alive (otherwise foreman would stop everything); elsewhere it runs `db:migrate`

Redis must be running for the Sidekiq workers.

### Spring and `DATABASE_URL`
`bin/rails` goes through Spring. A command run with `DATABASE_URL=...` (e.g. to check a throwaway database) leaves a Spring server that keeps that variable, so later `rails ...` commands (including those in `bin/reviewappdeploy.sh`) hit the wrong database. To target another database, use `DISABLE_SPRING=1` or run `bin/spring stop` right afterwards; `psql` alone also works to inspect a dump. If migrations are unexpectedly pending, check the `database:` line of `db:migrate:status`.

## Architecture

### Core Domain Models
- **Structure**: Organizations using the platform (employment centers, training organizations)
- **Campagne**: Assessment campaigns created by structures  
- **Évaluation**: Individual assessment sessions by beneficiaries
- **Bénéficiaire**: People taking assessments
- **Situation**: Assessment scenarios (inventaire, livraison, sécurité, etc.)
- **Question**: Individual questions within assessments
- **Événement**: Tracking events during assessments

### Technology Stack
- **Rails 8.0** with Ruby 4.0.6 (the Ruby version is read from `.tool-versions` by the Gemfile)
- **Node.js 22.23.4** (managed via asdf/rtx, version in `.tool-versions`; Scalingo uses `engines.node` in `package.json`, set to `22.x`: update it on a major version change)

### Authentication & Authorization
- **Admin Interface**: `/admin`. The seed creates a superadmin `eva@anlci.gouv.fr` (`Eva::EMAIL_SUPPORT`) with a random password; after `bin/reviewappdeploy.sh`, every account uses the `MOT_DE_PASS_COMPTES_PREPROD` password
- **ProConnect Integration**: French government single sign-on
- **CanCanCan**: Role-based authorization; roles are `Compte::ROLES` (conseiller, admin, charge_mission_regionale, superadmin, compte_generique)

## Development Workflow

### Langue
- Le code est écrit en français : noms de classes, de méthodes et de variables, commentaires, descriptions RSpec et messages de commit. Le vocabulaire imposé par Rails et les gems (`create`, `index`, `has_many`, callbacks…) reste en anglais.

### TDD (red → green)
- Before fixing a bug or changing behavior, write or adapt the test, run it with `bin/rspec <file>` and confirm it **fails**. Only then change the production code and rerun it to confirm it passes.
- If the test already passes before any change, it is not a real TDD cycle: say so instead of silently skipping the red step.
- When removing a feature (parameter, route, field), do not add a test that only checks it is gone. The red step comes from modifying or deleting the tests that exercised it. When in doubt (e.g. a security hole being closed), suggest the test instead of writing it.

### French Typography
- Use a narrow non-breaking space (U+202F) before `:` `!` `?` `;` in ERB views and YAML translation files, including after dynamically generated labels (e.g. `<%= Structure.human_attribute_name(:siret) %> :` needs U+202F before `:`).
- `rake locale_typography` checks translations (it is part of `rake validation`).

### Commits
- Never add `Co-Authored-By` or `Claude-Session` trailers to commit messages, whatever the default attribution instructions say.

## System Dependencies

### Required Services
- **PostgreSQL**: Main database. Production and CI (`.circleci/config.yml`, `cimg/postgres:15.17`) run 15.17; keep the same major version locally. When production is upgraded, align the CI image. Check the CI image before drawing conclusions about SQL behavior.
- **Redis**: For Sidekiq background jobs
- **vips**: Image processing library (libvips)
- **GraphViz**: For ERD generation

## Routes Configuration

Routes have no `/pro` prefix. The API also accepts an optional `/pro` prefix (`scope '(pro)'`), and any other `/pro/*` URL redirects to its unprefixed equivalent.
