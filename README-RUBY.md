# Salman Bot — Ruby API

This repository keeps the static ChatGPT-style frontend on GitHub Pages and adds a separate Ruby on Rails API service.

## Architecture

- **Frontend:** existing HTML/CSS/JavaScript site, hosted on GitHub Pages.
- **Backend:** Ruby on Rails 8 API, deployable as an independent web service.
- **Database:** PostgreSQL is configured through `DATABASE_URL`.
- **Python:** intentionally not required in the initial backend. Add a separate Python service only if a concrete capability needs its ecosystem.

## Local setup

Requirements: Ruby 3.3+, Bundler, and PostgreSQL.

1. Copy `.env.example` to `.env` and configure `DATABASE_URL`.
2. Install dependencies: `bundle install`.
3. Start the API: `bundle exec rails server`.
4. Check health: `GET /api/v1/health` (or `GET /up`).

Example response:

```json
{"status":"ok","service":"salman-bot-api","version":"1","ruby":"3.3.6","timestamp":"..."}
```

## Deployment

Deploy this directory as a separate Ruby web service (for example, Render, Fly.io, or a VPS), attach PostgreSQL, and set:

- `RAILS_ENV=production`
- `DATABASE_URL`
- `FRONTEND_ORIGIN` to the exact GitHub Pages origin
- `RAILS_MASTER_KEY` only if encrypted Rails credentials are introduced

GitHub Pages cannot execute Ruby. It continues serving the static frontend; the Rails API must have its own HTTPS URL.

## Security and current scope

- No provider API keys or personal tokens belong in Git.
- CORS is restricted by `FRONTEND_ORIGIN` in deployment; do not leave it as `*` for a public production deployment.
- This first integration establishes the Rails runtime and health endpoint. Existing browser-side provider integrations remain unchanged until a secure server-side provider adapter and authentication/rate-limiting policy are implemented.
- Do not store conversation content on the server until retention, deletion, and authentication behavior are designed.

## Checks

Run `bundle exec rails routes` and `bundle exec rails runner 'puts Rails.version'` after installing dependencies.
