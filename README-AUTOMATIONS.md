# Salman-Bot Automation Builder

The static builder is `automations.html`; the Ruby on Rails API remains a separate service.

## API configuration

Set these server-side environment variables:
- `SALMAN_API_TOKEN`: long random bearer token required by automation and assistant endpoints.
- `OPENAI_API_KEY`: provider key, stored only on the server.
- `OPENAI_MODEL`: optional model name (defaults to `gpt-4o-mini`).
- `DATABASE_URL`, `FRONTEND_ORIGIN`, `RAILS_ENV=production`.

Never commit provider keys or the bearer token. The builder stores the bearer token in sessionStorage for the current browser tab only. For a public multi-user product, add real user authentication and per-user authorization before deployment.

## Supported workflow steps

The first safe execution engine supports:
- `log`: record a short message in the run result.
- `set_value`: set a named workflow variable.
- `condition`: compare a variable with an expected value.

It intentionally does not execute generated Ruby, shell commands, arbitrary URLs, or arbitrary code. AI output is constrained and validated before it becomes an editable draft.

## Scheduling

One-time scheduled workflows store `next_run_at`. Configure a trusted scheduler on the server to run:

```sh
bundle exec rake automations:run_due
```

The first version pauses a scheduled workflow after one successful run. Repeating schedules and external integrations require dedicated adapters and authorization.

## Migration

Run `bundle exec rails db:migrate` during deployment.
