# Supabase setup

Flashi uses Supabase for Google authentication, server credit accounting, generation metadata, and temporary private study-source uploads.

1. Create or choose a Supabase project.
2. Run `bootstrap.sql` in SQL Editor.
3. Enable Google in Authentication → Providers and configure the Google OAuth clients.
4. Keep `study-sources` private.
5. Mobile receives only the project URL + publishable key.
6. `SUPABASE_SECRET_KEY` belongs only in Next.js/Vercel.

The public business tables deliberately grant no access to `anon` or `authenticated`; the Next.js API is authoritative.

After linking the Supabase CLI, create the real migration with `supabase migration new flashi_backend_core`, move the reviewed SQL into it, run database advisors, and commit the generated migration.
