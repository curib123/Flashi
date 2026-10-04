# Flashi AI

**Turn Notes Into Knowledge.**

Flashi AI is a focused study application for turning notes into editable flashcards, quizzes, and mock-exam material.

## Product flow

**Upload → Generate → Practice → Review → Improve → Share**

There is no general-purpose AI chat assistant.

## Monorepo

- `apps/mobile` — Flutter Android app: SQLite offline library, manual creation, practice/results, safe backup/import, Google sign-in client flow, and API consumption.
- `apps/api` — Next.js backend for Vercel: authentication mediation, GPT-5.6 Luna generation, upload authorization, credits, synchronization, and runtime configuration.
- `supabase` — PostgreSQL/storage schema and backend bootstrap.

## AI generation

The server is locked to `gpt-5.6-luna`. Supported study types include flashcards, multiple choice, identification, true/false, definition, fill-in-the-blank, matching, question-and-answer, and enumeration.

Sources can be typed notes/topics, PDF and supported document files, screenshots, photos, and handwritten/printed note images.

Private credentials stay on the backend. Flutter never receives the OpenAI key or Supabase secret/service key.

## Offline and portability

Manual study works without an account or network connection. Generated study sets are saved to SQLite and remain available offline.

Portable `.flashi` packages are versioned and strictly validated. Users can create backups, share them, import a copy, or transactionally restore a backup.

## Ads

Start.io is configured for non-disruptive monetization only. Return and splash ads are disabled. The Flutter app only supports a server-enabled, user-opted-in banner on the library screen; study, generation, quiz, and result flows stay ad-free.

## Development

1. Copy `apps/api/.env.example` to `apps/api/.env.local`.
2. Prepare Supabase with the files in `supabase/`.
3. Run `npm ci` and `npm run api:dev`.
4. Run Flutter from `apps/mobile` with the public `API_BASE_URL` and `GOOGLE_WEB_CLIENT_ID` build defines.
5. Keep `OPENAI_API_KEY`, Supabase secret/service keys, rate-limit secrets, and cron secrets server-side only.

CI validates API tests/typecheck/build plus Flutter formatting, analysis, tests, and an Android debug APK build.
