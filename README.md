# Flashi

Flashi is an offline-first flashcard and quiz study app.

## Monorepo

- `apps/mobile` — Flutter app. Manual study sets and review remain offline.
- `apps/api` — Next.js API for Vercel. Owns AI generation, auth validation, credits, upload authorization, and runtime ad configuration.
- `supabase` — Supabase database/storage bootstrap.

## Scope

There is no general-purpose AI chat assistant. Flashi supports manual and AI-generated study sets for multiple choice, identification, true/false, definition, fill-in-the-blank, and enumeration. AI sources can be a topic, PDF/DOC/DOCX, or study-note image.

The backend is locked to `gpt-5.6-luna`.

## Development

1. Copy `apps/api/.env.example` to `apps/api/.env.local`.
2. Prepare Supabase using `supabase/README.md`.
3. Never put `OPENAI_API_KEY` or `SUPABASE_SECRET_KEY` in Flutter.
4. Run `npm install` and `npm run api:dev`.
5. Run Flutter from `apps/mobile`.

The mobile API URL is a build define. Development defaults to the Android emulator host; later pass the Vercel URL with `--dart-define=API_BASE_URL=https://...`.
