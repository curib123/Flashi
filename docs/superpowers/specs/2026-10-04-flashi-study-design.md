# Flashi AI study application

The user's product brief is the source of truth. Flashi AI turns notes into editable flashcards, quizzes and mock exams; guest manual creation and saved study content work offline. The primary tagline is **Turn Notes Into Knowledge.** The supporting tagline is **Upload. Generate. Practice. Remember.**

## Architecture and contracts

Keep `apps/mobile` (Flutter Android) and `apps/api` (Next.js App Router on Node 22+). No general assistant, client AI SDK, client credit authority or Supabase service credentials. Use the existing blue Material 3 design system. Introduce typed study sets/questions/subjects/attempts and transactional SQLite persistence. Migrate saved legacy Hive quiz sets once without deleting the original boxes. Retain Hive only for migration.

Next.js owns Google ID-token exchange, token refresh/logout, configuration, Supabase authorization, signed uploads, generation, ledger and synchronization. Flutter acquires Google tokens through native sign-in, persists the backend session in platform secure storage and makes authenticated HTTPS API requests. Guests need neither credentials nor network.

## Generation and credits

Pin the single supported model to `gpt-5.6-luna`. Supply text, PDFs/documents or images through Responses API inputs, with strict structured output and semantic validation. Include all requested question types, count 1–100, topic filters and Easy/Medium/Hard difficulty. Validate file extension/MIME, authoritative stored upload metadata and actual bytes; accept only owned uploads. Do not accept external source URLs.

Use an idempotency UUID and request hash. Reserve credits under a wallet row lock, persist a successful validated result and debit credits in the same SQL transaction. Failed/expired operations release reservations without any debit. Persist results for interrupted-client recovery. Only service-role RPCs modify credits. Remove client-completion reward endpoints; a future credit grant requires verified provider evidence. Use database-backed rate limits.

## Offline study and portable data

Sets contain independent UUID questions, kind deck/quiz/exam, subject, creator, difficulty, explanation and topic. Matching questions contain structured pairs. Local study sessions save question-level answer snapshots, scores, mistakes and weak topics. Exam mode defers answers until completion and supports a timer. Flashcards use explicit remembered/again self-assessment; free text accepts exact normalized answers and provides explicit self-grading for descriptive responses.

A Flashi `.flashi` package is bounded UTF-8 JSON with format marker, version, package type, metadata and typed data. Backups include subjects, sets and attempts. Packs include selected sets and related subjects, omit account credentials/credits, and create new independent IDs on duplication/import. Strict validation rejects unknown fields, incompatible versions, unsafe references, malformed nested content, excess sizes and orphan progress. Preview metadata before import; replace/duplicate/cancel choices; restore merges or replaces atomically after validation. Sharing uses the native share sheet; Android VIEW/SEND intents feed the same preview/import path.

## Synchronization and advertisements

User-owned Supabase entities support optimistic revisions, tombstones and server-assigned monotonic change sequence cursors. A cloud sync is explicit, sends local changes in bounded batches, retains unsent edits on errors, and offers conflict resolution. Switching accounts retains local study content; cloud revision metadata is account-scoped. No automatic upload of local content on sign-in.

Centralize Start.io configuration and ad gating. Only optional, consented library banners; disable return/splash ads and all interstitials. Suppress banners while any study/editor/import/generation/result route is open. Remote config contains App ID and placement flags; Android native bridge supports deferred runtime initialization. Ads fail closed when offline/unconfigured or consent is absent. No credit awards from untrusted SDK callbacks.

## Verification and operations

Exercise actual SQL wallet reservation/finalization/failure/replay/RLS and optimistic sync through a local PostgreSQL-compatible test runtime. Unit/integration tests cover malformed sources and generated output, offline persistence, migration, all question types, corrupted packs and restore rollback; widget tests cover manual creation, study/results and navigation at small widths. Backend typecheck/build, Flutter analyze/test and Android build run in CI. Deploy only verified source. Live Google/OpenAI/Supabase/Start.io verification requires the owner's project credentials; missing credentials are explicit setup blockers, never replaced with fake services or another model.
