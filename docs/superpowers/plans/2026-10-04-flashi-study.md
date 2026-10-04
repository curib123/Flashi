# Flashi AI Implementation Plan

> **For agentic workers:** Use superpowers:executing-plans to implement this plan in this session.

**Goal:** Refactor Flashi into a working offline study app with a secure backend.

**Architecture:** Next.js owns online business logic and Supabase writes. Flutter owns local presentation and study sessions backed by SQLite.

**Tech Stack:** Flutter, SQLite, Next.js, Supabase PostgreSQL/Auth/Storage, OpenAI Responses (`gpt-5.6-luna`), Start.io, Vercel.

**Spec:** `docs/superpowers/specs/2026-10-04-flashi-study-design.md`

## Global Constraints

- No assistant or chat features; no private credentials in mobile.
- Guest manual study works without backend configuration.
- Credits debit only on successful persisted generation; no fallback model.
- Versioned safe import, independent copies, transactional restoration.
- Existing clean blue Material 3 styling; no ads in active workflows.

## Review Focus

- Concurrent/repeated/abandoned generation: no double charge or stranded debit.
- Malformed or cross-user sources and packages: reject before mutation/AI call.
- Offline data and failed restore: preserve existing content and progress.
- Cross-device conflicts/deletions/account changes: retain unsynced edits.
- Session refresh, interrupted generation and file-open intent: recover safely.

### Task 1: API contracts, schema and generation

**Files:** `apps/api/src/lib/{study,uploads,generation,credits,http,auth,env}.ts`, `apps/api/src/app/api/v1/**/route.ts`, `supabase/migrations/**`, `apps/api/tests/**`.

**Interfaces:** `StudySet` contains typed questions; `/generate` accepts kind, questionTypes, count, difficulty, topics, source, idempotency key. `/config` contains only public configuration. `/auth/google`, `/auth/refresh`, `/auth/logout` mediate sessions. `/sync` uses entity IDs, base revisions, payloads and change cursors.

- [ ] Add failing regression tests for invalid MC answers, wrong count/type, foreign sources and failed/concurrent/idempotent SQL credits.
- [ ] Implement schemas, file validation, strict Luna generation, durable SQL reservations/ledger and backend authentication.
- [ ] Implement owned revision-based sync and persistent rate limiting.
- [ ] Run `npm test`, `npm run api:typecheck`, `npm run api:build`; expected all pass.
- [ ] Commit the verified backend and migrations.

### Task 2: Offline library and portable packages

**Files:** `apps/mobile/lib/domain/**`, `apps/mobile/lib/data/**`, `apps/mobile/test/**`.

**Interfaces:** Typed `StudySet`, `StudyQuestion`, `Subject`, `StudyAttempt`; `StudyRepository` transactional CRUD/restore and account-scoped sync state; `StudyPackage` strict codec and preview metadata.

- [ ] Add failing tests for package validation, duplicate IDs, invalid choices/pairs, malformed version, repository restore rollback, study grading and legacy migration.
- [ ] Implement typed data, SQLite repository, legacy migration, package preview/export/restore/import and mistake snapshots.
- [ ] Run `flutter test`; expected domain/repository tests pass.
- [ ] Commit offline storage and codec.

### Task 3: Mobile study workflows and backend integration

**Files:** `apps/mobile/lib/{main,app}.dart`, `apps/mobile/lib/features/**`, `apps/mobile/lib/core/**`, `apps/mobile/android/**`.

**Interfaces:** App state consumes repository/API; manual editor and generator produce editable sets; sessions produce attempts; account screen calls backend auth/sync/ledger; pack preview consumes validated package.

- [ ] Add failing widget tests for guest navigation, manual save, study/mistakes and small-screen layout.
- [ ] Remove obsolete UI/services/dependencies and wire manual editors, generation preview, flashcards, mixed quiz/exam, results, subjects and history.
- [ ] Wire session refresh/recovery, signed uploads, sync conflict UI, backup/share/import and Android file-open intents.
- [ ] Add centralized API configuration, consented Start.io banner gate and native runtime initialization.
- [ ] Run `flutter analyze`, `flutter test`, `flutter build apk --debug`; expected pass or explicit environment blocker.
- [ ] Commit tested mobile integration.

### Task 4: QA, CI and deployment

**Files:** `.github/workflows/**`, `README.md`, `docs/**`, `apps/api/.env.example`, `apps/mobile/config/**`.

- [ ] Document every variable, Google setup, database setup, API and sync protocol, portable format and release signing.
- [ ] Update monorepo CI to test API/database/mobile, build Android and support reproducible releases.
- [ ] Run all checks and review security/failure paths; fix critical findings with regression tests.
- [ ] Push source and create a reviewable PR. Deploy API to Vercel when credentials/project setup permit; verify health/config and set production build configuration only to the verified backend URL.
- [ ] Report verified outcomes and specific remaining credential/live-service blockers.
